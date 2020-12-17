import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/translations.dart';
import 'package:hairdresser_calc2/extensions/int_extensions.dart';
import 'package:hairdresser_calc2/providers/salary_provider.dart';
import 'package:provider/provider.dart';

enum GoalSelection { GROSS, NET, SALARY }

class GoalWidget extends StatefulWidget {
  GoalWidget({Key key}) : super(key: key);

  @override
  _GoalWidgetState createState() => _GoalWidgetState();
}

class _GoalWidgetState extends State<GoalWidget> {
  final _goalFieldKey = GlobalKey(debugLabel: 'goal');
  final _goalController = TextEditingController();
  final _goalFocus = FocusNode();
  GoalSelection _goalSelection = GoalSelection.GROSS;

  @override
  void dispose() {
    _goalFocus.dispose();
    _goalController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _goalController.text = context.read<SalaryProvider>().goalGross.toString();
    _goalFocus.addListener(onGoalFocusChange);
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
                    _goalController.text = "${context.read<SalaryProvider>().goalGross}";
                  else if (value == GoalSelection.NET)
                    _goalController.text = "${context.read<SalaryProvider>().goalNet}";
                  else
                    _goalController.text = "${context.read<SalaryProvider>().goalSalary}";
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

    return Column(children: [
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
          errorText: context.watch<SalaryProvider>().goalValidationError
              ? Translations.of(context).validationMessage
              : null,
          labelText: _pickGoalLabel(),
          border: const OutlineInputBorder(),
        ),
        keyboardType: TextInputType.number,
        onChanged: (text) {
          context.read<SalaryProvider>().updateGoal(_goalSelection, text);
        },
      ),
      goalInfo,
    ]);
  }
}
