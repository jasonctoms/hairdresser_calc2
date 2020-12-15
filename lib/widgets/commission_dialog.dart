import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/translations.dart';
import 'package:hairdresser_calc2/providers/salary_provider.dart';
import 'package:meta/meta.dart';
import 'package:provider/provider.dart';

class CommissionDialog extends StatefulWidget {
  final String commission;

  const CommissionDialog({
    @required this.commission,
  }) : assert(commission != null);

  @override
  _CommissionDialogState createState() => _CommissionDialogState();
}

class _CommissionDialogState extends State<CommissionDialog> {
  double _commissionValue;
  String _commissionText;
  bool _showValidationError = false;
  final _inputKey = GlobalKey(debugLabel: 'commissionText');

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
    context.read<SalaryProvider>().setCommission(_commissionValue);
  }

  @override
  Widget build(BuildContext context) {
    final currentCommission = Padding(
      padding: EdgeInsets.only(bottom: 32.0, top: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(Translations.of(context).currentCommission),
          Padding(padding: EdgeInsets.symmetric(horizontal: 2.0)),
          Text(
            widget.commission,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );

    final commissionInput = TextField(
      key: _inputKey,
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
        children: [currentCommission, commissionInput],
      ),
      actions: [
        TextButton(
          child: Text(Translations.of(context).cancel),
          onPressed: () => Navigator.pop(context),
        ),
        TextButton(
          child: Text(Translations.of(context).done),
          onPressed: (_showValidationError || _commissionText == null) ? null : () => saveCommission(context),
        ),
      ],
    );
  }
}
