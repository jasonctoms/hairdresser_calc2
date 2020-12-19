import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/translations.dart';
import 'package:hairdresser_calc/extensions/int_extensions.dart';
import 'package:meta/meta.dart';

class IntakeEditDialog extends StatefulWidget {
  final int initialIntake;
  final String dialogTitle;
  final String textFieldTitle;
  final Function(int updatedIntake) onSave;

  const IntakeEditDialog({
    @required this.initialIntake,
    @required this.dialogTitle,
    @required this.textFieldTitle,
    @required this.onSave,
  }) : assert(initialIntake != null);

  @override
  _IntakeEditDialogState createState() => _IntakeEditDialogState();
}

class _IntakeEditDialogState extends State<IntakeEditDialog> {
  int _intakeValue;
  String _intakeText;
  bool _showValidationError = false;
  final _inputKey = GlobalKey(debugLabel: 'commissionText');

  void updateCommission(String input) {
    setState(() {
      try {
        final inputDouble = (int.parse(input));
        _showValidationError = false;
        _intakeValue = inputDouble;
        _intakeText = input;
      } on Exception catch (e) {
        print('Error: $e');
        _showValidationError = true;
      }
    });
  }

  saveIntake(BuildContext context) {
    Navigator.pop(context, _intakeText);
    widget.onSave(_intakeValue);
  }

  @override
  Widget build(BuildContext context) {
    final currentCommission = Padding(
      padding: EdgeInsets.only(bottom: 32.0, top: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(widget.dialogTitle),
          Padding(padding: EdgeInsets.symmetric(horizontal: 2.0)),
          Text(
            widget.initialIntake.toKroner(),
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
        labelText: widget.textFieldTitle,
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
          onPressed:
              (_showValidationError || _intakeText == null) ? null : () => saveIntake(context),
        ),
      ],
    );
  }
}
