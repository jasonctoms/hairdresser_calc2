import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/translations.dart';
import 'package:hairdresser_calc2/providers/salary_provider.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Translations.of(context).appName),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have pushed the button this many times:',
            ),
          ],
        ),
      ),
    );
  }
}
