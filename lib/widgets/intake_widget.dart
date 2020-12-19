import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/translations.dart';

class IntakeWidget extends StatefulWidget {
  final Function(String input) onUpdate;
  final Function() onStore;
  final Function() onEdit;
  final String monthlyValue;
  final bool validationError;
  final int initialValue;
  final String todayLabel;
  final String monthlyLabel;

  IntakeWidget({
    Key key,
    @required this.onUpdate,
    @required this.onStore,
    @required this.onEdit,
    @required this.monthlyValue,
    @required this.validationError,
    @required this.initialValue,
    @required this.todayLabel,
    @required this.monthlyLabel,
  }) : super(key: key);

  @override
  _IntakeWidgetState createState() => _IntakeWidgetState();
}

class _IntakeWidgetState extends State<IntakeWidget> {
  final _intakeFieldKey = GlobalKey(debugLabel: 'intake');
  final _intakeController = TextEditingController();
  final _intakeFocus = FocusNode();

  @override
  void dispose() {
    _intakeFocus.dispose();
    _intakeController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _intakeController.text = widget.initialValue.toString();
    _intakeFocus.addListener(onIntakeFocusChange);
  }

  onIntakeFocusChange() {
    if (_intakeFocus.hasFocus) {
      _intakeController.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _intakeController.text.length,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final intakeField = TextField(
      key: _intakeFieldKey,
      controller: _intakeController,
      focusNode: _intakeFocus,
      style: Theme.of(context).textTheme.bodyText1,
      decoration: InputDecoration(
        labelStyle: Theme.of(context).textTheme.bodyText1,
        errorText: widget.validationError ? Translations.of(context).validationMessage : null,
        labelText: widget.todayLabel,
        border: const OutlineInputBorder(),
      ),
      keyboardType: TextInputType.number,
      onChanged: (text) {
        widget.onUpdate(text);
      },
    );

    final monthsIntake = GestureDetector(
      onTap: () => widget.onEdit(),
      child: Column(
        children: [
          Text(widget.monthlyLabel),
          Text(
            widget.monthlyValue,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            flex: 3,
            child: intakeField,
          ),
          Expanded(
            flex: 1,
            child: IconButton(
              icon: Icon(
                Icons.arrow_forward,
                color: Theme.of(context).accentColor,
              ),
              onPressed: () => widget.onStore(),
            ),
          ),
          Expanded(
            flex: 3,
            child: monthsIntake,
          ),
        ],
      ),
    );
  }
}
