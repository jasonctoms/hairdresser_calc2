import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/translations.dart';
import 'package:hairdresser_calc/providers/salary_provider.dart';
import 'package:hairdresser_calc/widgets/commission_dialog.dart';
import 'package:provider/provider.dart';

enum OptionsMenuSelection { COMMISSION, RESET }

class AppBarMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<OptionsMenuSelection>(
      onSelected: (value) => handleClick(context, value),
      itemBuilder: (BuildContext context) {
        return {OptionsMenuSelection.COMMISSION, OptionsMenuSelection.RESET}
            .map((OptionsMenuSelection choice) {
          return PopupMenuItem<OptionsMenuSelection>(
            value: choice,
            child: Text(getMenuItemTitle(context, choice)),
          );
        }).toList();
      },
    );
  }

  String getMenuItemTitle(BuildContext context, OptionsMenuSelection value) {
    switch (value) {
      case OptionsMenuSelection.COMMISSION:
        var commission = Translations.of(context).commission;
        commission += context.read<SalaryProvider>().fixedSalary
            ? Translations.of(context).notApplicable
            : "${context.read<SalaryProvider>().commissionValue * 100}%";
        return commission;
      case OptionsMenuSelection.RESET:
        return Translations.of(context).reset;
      default:
        throw Exception("Menu selection not handled.");
    }
  }

  handleClick(BuildContext context, OptionsMenuSelection value) {
    switch (value) {
      case OptionsMenuSelection.COMMISSION:
        showDialog<String>(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return CommissionDialog();
            });
        break;
      case OptionsMenuSelection.RESET:
        context.read<SalaryProvider>().resetMonth();
        break;
    }
  }
}
