import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/translations.dart';
import 'package:hairdresser_calc2/extensions/int_extensions.dart';
import 'package:hairdresser_calc2/providers/salary_provider.dart';
import 'package:hairdresser_calc2/widgets/commission_dialog.dart';
import 'package:hairdresser_calc2/widgets/goal_widget.dart';
import 'package:hairdresser_calc2/widgets/incdec_widget.dart';
import 'package:hairdresser_calc2/widgets/intake_widget.dart';
import 'package:provider/provider.dart';

class SalaryPage extends StatefulWidget {
  SalaryPage({Key key}) : super(key: key);

  @override
  _SalaryPageState createState() => _SalaryPageState();
}

class _SalaryPageState extends State<SalaryPage> {
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

    final commission = Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Text(Translations.of(context).commission),
        TextButton(
          onPressed: () {
            showDialog<String>(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) {
                  return CommissionDialog(
                      commission: "${context.watch<SalaryProvider>().commissionValue * 100}%");
                });
          },
          child: Text(
            "${context.watch<SalaryProvider>().commissionValue * 100}%",
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: Theme.of(context).textTheme.headline6.fontSize),
          ),
        ),
      ],
    );

    final topRow = Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        commission,
        daysLeft,
      ],
    );

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
                child:
                    Text(Translations.of(context).intakeNeededPerDay, textAlign: TextAlign.center),
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
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.teal[300], fontSize: 30.0),
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  amountNeededPerDay().toKroner(),
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.teal[300], fontSize: 30.0),
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
              Padding(padding: EdgeInsets.only(bottom: 8)),
              IntakeWidget(
                onUpdate: (text) => context.read<SalaryProvider>().updateTodaysIntake(text),
                onStore: () => context.read<SalaryProvider>().addTodaysIntakeToMonth(),
                onClear: () => context.read<SalaryProvider>().clearMonthlyIntake(),
                onEdit: () => {},
                monthlyValue: context.watch<SalaryProvider>().monthsIntake.toKroner(),
                validationError: context.watch<SalaryProvider>().todaysIntakeValidationError,
                initialValue: context.watch<SalaryProvider>().todaysIntake,
                todayLabel: Translations.of(context).todaysIntake,
                monthlyLabel: Translations.of(context).monthsIntake,
              ),
              GoalWidget(),
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
