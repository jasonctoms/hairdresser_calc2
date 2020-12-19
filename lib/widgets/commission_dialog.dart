import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/translations.dart';
import 'package:hairdresser_calc/providers/salary_provider.dart';
import 'package:provider/provider.dart';

class CommissionDialog extends StatefulWidget {
  @override
  _CommissionDialogState createState() => _CommissionDialogState();
}

class _CommissionDialogState extends State<CommissionDialog> {
  double _commissionValue;
  String _commissionText;
  bool _showValidationError = false;
  bool _fixedSalary;
  final _inputKey = GlobalKey(debugLabel: 'commissionText');
  final _inputController = TextEditingController();

  void updateCommission(String input) {
    setState(() {
      try {
        final inputDouble = (double.parse(input)) / 100.0;
        if (inputDouble > 1.0 || inputDouble < 0) {
          _showValidationError = true;
        } else {
          _showValidationError = false;
          _commissionValue = inputDouble;
          _commissionText = input;
        }
      } on Exception catch (e) {
        print('Error: $e');
        _showValidationError = true;
      }
    });
  }

  saveCommission(BuildContext context) {
    Navigator.pop(context, _commissionText);
    double updatedValue = _fixedSalary ? null : _commissionValue;
    context.read<SalaryProvider>().setCommission(updatedValue);
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (_fixedSalary == null) {
      _fixedSalary = context.read<SalaryProvider>().fixedSalary;
      if (!_fixedSalary) {
        useStoredCommission(context);
      }
    }
  }

  useStoredCommission(BuildContext context) {
    var storedCommission = context.read<SalaryProvider>().commissionValue;
    var storedCommissionString = (storedCommission * 100).round().toString();
    _commissionValue = storedCommission;
    _inputController.text = storedCommissionString;
    _commissionText = storedCommissionString;
  }

  @override
  Widget build(BuildContext context) {
    if (_fixedSalary) {
      _inputController.text = Translations.of(context).notApplicable;
    }

    final currentCommission = Padding(
      padding: EdgeInsets.only(bottom: 16.0, top: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(Translations.of(context).currentCommission),
          Padding(padding: EdgeInsets.symmetric(horizontal: 2.0)),
          Text(
            _fixedSalary
                ? Translations.of(context).notApplicable
                : "${context.watch<SalaryProvider>().commissionValue * 100}%",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );

    final fixedSalarySwitch = Padding(
      padding: EdgeInsets.only(bottom: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(Translations.of(context).fixedSalary),
          Switch(
            activeColor: Theme.of(context).accentColor,
            value: _fixedSalary,
            onChanged: (bool newValue) {
              setState(() {
                if (!newValue) {
                  useStoredCommission(context);
                }
                _fixedSalary = newValue;
              });
            },
          )
        ],
      ),
    );

    final commissionInput = TextField(
      key: _inputKey,
      enabled: !_fixedSalary,
      controller: _inputController,
      style: Theme.of(context).textTheme.bodyText1,
      decoration: InputDecoration(
        labelStyle: Theme.of(context).textTheme.bodyText1,
        errorText: _showValidationError ? Translations.of(context).validationMessage : null,
        labelText: Translations.of(context).commissionPercent,
        border: const OutlineInputBorder(),
      ),
      keyboardType: TextInputType.number,
      onChanged: updateCommission,
    );

    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          currentCommission,
          fixedSalarySwitch,
          commissionInput,
        ],
      ),
      actions: [
        TextButton(
          child: Text(Translations.of(context).cancel),
          onPressed: () => Navigator.pop(context),
        ),
        TextButton(
          child: Text(Translations.of(context).done),
          onPressed: (_showValidationError || (_commissionText == null && !_fixedSalary))
              ? null
              : () => saveCommission(context),
        ),
      ],
    );
  }
}
