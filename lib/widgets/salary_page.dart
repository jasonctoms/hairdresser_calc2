import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/translations.dart';
import 'package:hairdresser_calc2/extensions/int_extensions.dart';
import 'package:hairdresser_calc2/providers/salary_provider.dart';
import 'package:hairdresser_calc2/widgets/commission_dialog.dart';
import 'package:hairdresser_calc2/widgets/incdec_widget.dart';
import 'package:provider/provider.dart';

const salaryBox = "salaryBoxKey";
enum GoalSelection { GROSS, NET, SALARY }

class SalaryPage extends StatefulWidget {
  SalaryPage({Key key}) : super(key: key);

  @override
  _SalaryPageState createState() => _SalaryPageState();
}

class _SalaryPageState extends State<SalaryPage> {
  bool _showIntakeValidationError = false;
  final _intakeFieldKey = GlobalKey(debugLabel: 'currentIntake');
  final _intakeController = TextEditingController();
  final _intakeFocus = FocusNode();

  bool _showGoalValidationError = false;
  final _goalFieldKey = GlobalKey(debugLabel: 'goal');
  final _goalController = TextEditingController();
  final _goalFocus = FocusNode();
  GoalSelection _goalSelection = GoalSelection.GROSS;

  @override
  void dispose() {
    _intakeFocus.dispose();
    _goalFocus.dispose();
    _intakeController.dispose();
    _goalController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    initTextFields();
    _intakeFocus.addListener(onIntakeFocusChange);
    _goalFocus.addListener(onGoalFocusChange);
  }

  initTextFields() {
    _intakeController.text = context.read<SalaryProvider>().todaysIntake.toString();
    _goalController.text = context.read<SalaryProvider>().goalGross.toString();
  }

  onIntakeFocusChange() {
    if (_intakeFocus.hasFocus) {
      _intakeController.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _intakeController.text.length,
      );
    }
  }

  onGoalFocusChange() {
    if (_goalFocus.hasFocus) {
      _goalController.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _goalController.text.length,
      );
    }
  }

  updateTodaysIntake(String input) {
    if (input == null || input.isEmpty) {
      _showIntakeValidationError = false;
      context.read<SalaryProvider>().updateTodaysIntake(0);
    } else {
      try {
        final inputInt = int.parse(input);
        _showIntakeValidationError = false;
        context.read<SalaryProvider>().updateTodaysIntake(inputInt);
      } on Exception catch (e) {
        print('Error: $e');
        _showIntakeValidationError = true;
      }
    }
  }

  int remainingIntake() {
    var goalGross = context.watch<SalaryProvider>().goalGross;
    var monthsIntake = context.watch<SalaryProvider>().monthsIntake;
    if (goalGross == null || monthsIntake == null)
      return 0;
    else
      return goalGross - monthsIntake;
  }

  int amountNeededPerDay() {
    var daysLeft = context.watch<SalaryProvider>().daysLeft;
    if (daysLeft == null)
      return 0;
    else
      return (remainingIntake() / daysLeft).round();
  }

  int salaryWithCurrentIntake() {
    var commissionValue = context.watch<SalaryProvider>().commissionValue;
    var monthsIntake = context.watch<SalaryProvider>().monthsIntake;
    if (monthsIntake == null || commissionValue == null)
      return 0;
    else
      return (monthsIntake * 0.8 * commissionValue).round();
  }

  @override
  Widget build(BuildContext context) {
    final daysLeft = IncDecWidget(
      titleOnTop: true,
      title: Translations.of(context).daysLeft,
      value: context.watch<SalaryProvider>().daysLeft,
      incrementFunction: () => context.read<SalaryProvider>().addDay(),
      decrementFunction: () => context.read<SalaryProvider>().subtractDay(),
    );

    final commission = Row(
      children: [
        Text(Translations.of(context).commission),
        Padding(padding: EdgeInsets.only(right: 2.0)),
        TextButton(
          onPressed: () {
            showDialog<String>(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) {
                  return CommissionDialog(commission: "${context.read<SalaryProvider>().commissionValue * 100}%");
                });
          },
          child: Text(
            "${context.watch<SalaryProvider>().commissionValue * 100}%",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        )
      ],
    );

    final topRow = Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        commission,
        daysLeft,
      ],
    );

    final todaysIntakeField = Expanded(
      child: Padding(
        padding: EdgeInsets.only(right: 8.0),
        child: TextField(
          key: _intakeFieldKey,
          controller: _intakeController,
          focusNode: _intakeFocus,
          style: Theme.of(context).textTheme.bodyText1,
          decoration: InputDecoration(
            labelStyle: Theme.of(context).textTheme.bodyText1,
            errorText: _showIntakeValidationError ? Translations.of(context).validationMessage : null,
            labelText: Translations.of(context).todaysIntake,
            border: const OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          onChanged: updateTodaysIntake,
        ),
      ),
    );

    final monthsIntake = Column(
      children: [
        Text(Translations.of(context).monthsIntake),
        Text(
          "${context.watch<SalaryProvider>().monthsIntake.toKroner()}",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );

    final currentIntakeRow = Row(
      children: [
        todaysIntakeField,
        IconButton(
          icon: Icon(
            Icons.arrow_forward,
            color: Colors.teal[400],
          ),
          onPressed: () => context.read<SalaryProvider>().addTodaysIntakeToMonth(),
        ),
        monthsIntake,
        IconButton(
          icon: Icon(
            Icons.clear,
            color: Colors.red,
          ),
          onPressed: () => context.read<SalaryProvider>().clearMonthlyIntake(),
        ),
      ],
    );

    String _pickGoalLabel() {
      if (_goalSelection == GoalSelection.GROSS) {
        return Translations.of(context).goalGross;
      } else if (_goalSelection == GoalSelection.NET) {
        return Translations.of(context).goalNet;
      } else {
        return Translations.of(context).goalSalary;
      }
    }

    Widget goalRadio(String title, GoalSelection goalType) {
      return Expanded(
        flex: 1,
        child: Row(
          children: [
            Radio<GoalSelection>(
              value: goalType,
              groupValue: _goalSelection,
              onChanged: (GoalSelection value) {
                setState(() {
                  _goalSelection = value;
                  if (value == GoalSelection.GROSS)
                    _goalController.text = "${context.watch<SalaryProvider>().goalGross}";
                  else if (value == GoalSelection.NET)
                    _goalController.text = "${context.watch<SalaryProvider>().goalNet}";
                  else
                    _goalController.text = "${context.watch<SalaryProvider>().goalSalary}";
                });
              },
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyText1,
            ),
          ],
        ),
      );
    }

    final goal = Column(children: [
      Row(
        children: [
          goalRadio(Translations.of(context).gross, GoalSelection.GROSS),
          goalRadio(Translations.of(context).net, GoalSelection.NET),
          goalRadio(Translations.of(context).salary, GoalSelection.SALARY),
        ],
      ),
      TextField(
        key: _goalFieldKey,
        controller: _goalController,
        focusNode: _goalFocus,
        style: Theme.of(context).textTheme.bodyText1,
        decoration: InputDecoration(
          labelStyle: Theme.of(context).textTheme.bodyText1,
          errorText: _showGoalValidationError ? Translations.of(context).validationMessage : null,
          labelText: _pickGoalLabel(),
          border: const OutlineInputBorder(),
        ),
        keyboardType: TextInputType.number,
        onChanged: context.watch<SalaryProvider>().updateGoal(_goalSelection),
      ),
    ]);

    final goalInfo = Padding(
      padding: EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Column(
            children: [
              Text(Translations.of(context).goalGrossResult),
              Text(
                "${context.watch<SalaryProvider>().goalGross.toKroner()}",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Column(
            children: [
              Text(Translations.of(context).goalNetResult),
              Text(
                "${context.watch<SalaryProvider>().goalNet.toKroner()}",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Column(
            children: [
              Text(Translations.of(context).goalSalaryResult),
              Text(
                "${context.watch<SalaryProvider>().goalSalary.toKroner()}",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );

    final currentSalary = Padding(
      padding: EdgeInsets.only(top: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(Translations.of(context).salaryWithCurrentIntake),
          Text(
            salaryWithCurrentIntake().toKroner(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.teal[300],
            ),
          ),
        ],
      ),
    );

    final importantNumbers = Padding(
      padding: EdgeInsets.only(top: 32.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                flex: 1,
                child: Text(
                  Translations.of(context).intakeNeededToReachGoal,
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(Translations.of(context).intakeNeededPerDay, textAlign: TextAlign.center),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                flex: 1,
                child: Text(
                  remainingIntake().toKroner(),
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal[300], fontSize: 30.0),
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  amountNeededPerDay().toKroner(),
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal[300], fontSize: 30.0),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    return new Scaffold(
      appBar: AppBar(
        title: Text(Translations.of(context).appName),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              topRow,
              currentIntakeRow,
              goal,
              goalInfo,
              currentSalary,
              importantNumbers,
            ],
          ),
        ),
      ),
    );
  }
}
