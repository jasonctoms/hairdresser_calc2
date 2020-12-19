import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/translations.dart';
import 'package:hairdresser_calc2/extensions/int_extensions.dart';
import 'package:hairdresser_calc2/providers/salary_provider.dart';
import 'package:hairdresser_calc2/widgets/app_bar_menu.dart';
import 'package:hairdresser_calc2/widgets/goal_widget.dart';
import 'package:hairdresser_calc2/widgets/incdec_widget.dart';
import 'package:hairdresser_calc2/widgets/intake_edit_dialog.dart';
import 'package:hairdresser_calc2/widgets/intake_widget.dart';
import 'package:provider/provider.dart';

class SalaryPage extends StatefulWidget {
  SalaryPage({Key key}) : super(key: key);

  @override
  _SalaryPageState createState() => _SalaryPageState();
}

class _SalaryPageState extends State<SalaryPage> {
  @override
  Widget build(BuildContext context) {
    bool _fixedSalary = context.watch<SalaryProvider>().fixedSalary;

    final monthlyClients = IncDecWidget(
      titleOnTop: true,
      title: Translations.of(context).clients,
      value: context.watch<SalaryProvider>().monthlyClients,
      incrementFunction: () => context.read<SalaryProvider>().addClient(),
      decrementFunction: () => context.read<SalaryProvider>().subtractClient(),
    );

    final daysLeft = IncDecWidget(
      titleOnTop: true,
      title: Translations.of(context).daysLeft,
      value: context.watch<SalaryProvider>().daysLeft,
      incrementFunction: () => context.read<SalaryProvider>().addDay(),
      decrementFunction: () => context.read<SalaryProvider>().subtractDay(),
    );

    final topRow = Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        monthlyClients,
        daysLeft,
      ],
    );

    final currentSalary = Padding(
      padding: EdgeInsets.only(top: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(Translations.of(context).salaryWithCurrentIntake),
          Text(
            context.watch<SalaryProvider>().salaryWithCurrentIntake.toKroner(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.teal[300],
            ),
          ),
        ],
      ),
    );

    final treatmentsPerClient = Padding(
      padding: EdgeInsets.only(top: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(Translations.of(context).treatmentsPerClient),
          Text(
            context.watch<SalaryProvider>().treatmentValuePerClient.toKroner(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.teal[300],
            ),
          ),
        ],
      ),
    );

    final importantNumbers = Padding(
      padding: EdgeInsets.only(top: 16.0),
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
                  context.watch<SalaryProvider>().remainingIntake.toKroner(),
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.teal[300], fontSize: 30.0),
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  context.watch<SalaryProvider>().amountNeededPerDay.toKroner(),
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

    final treatments = IntakeWidget(
      onUpdate: (text) => context.read<SalaryProvider>().updateDailyTreatments(text),
      onStore: () => context.read<SalaryProvider>().addDailyTreatmentsToMonth(),
      onEdit: () {
        showDialog<String>(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return IntakeEditDialog(
                initialIntake: context.watch<SalaryProvider>().monthlyTreatments,
                dialogTitle: Translations.of(context).currentMonthlyTreatments,
                textFieldTitle: Translations.of(context).updatedMonthlyTreatments,
                onSave: (updatedValue) =>
                    context.read<SalaryProvider>().updateMonthlyTreatments(updatedValue),
              );
            });
      },
      monthlyValue: context.watch<SalaryProvider>().monthlyTreatments.toKroner(),
      validationError: context.watch<SalaryProvider>().dailyTreatmentsValidationError,
      initialValue: context.watch<SalaryProvider>().dailyTreatments,
      todayLabel: Translations.of(context).dailyTreatments,
      monthlyLabel: Translations.of(context).monthlyTreatments,
    );

    final sales = IntakeWidget(
      onUpdate: (text) => context.read<SalaryProvider>().updateDailySales(text),
      onStore: () => context.read<SalaryProvider>().addDailySalesToMonth(),
      onEdit: () {
        showDialog<String>(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return IntakeEditDialog(
                initialIntake: context.watch<SalaryProvider>().monthlySales,
                dialogTitle: Translations.of(context).currentMonthlySales,
                textFieldTitle: Translations.of(context).updatedMonthlySales,
                onSave: (updatedValue) =>
                    context.read<SalaryProvider>().updateMonthlySales(updatedValue),
              );
            });
      },
      monthlyValue: context.watch<SalaryProvider>().monthlySales.toKroner(),
      validationError: context.watch<SalaryProvider>().dailySalesValidationError,
      initialValue: context.watch<SalaryProvider>().dailySales,
      todayLabel: Translations.of(context).dailySales,
      monthlyLabel: Translations.of(context).monthlySales,
    );

    return new Scaffold(
      appBar: AppBar(
        title: Text(Translations.of(context).appName),
        actions: [
          AppBarMenu(),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              topRow,
              GoalWidget(),
              Padding(padding: EdgeInsets.only(bottom: 8)),
              treatments,
              if (_fixedSalary) sales,
              if (!_fixedSalary) currentSalary,
              treatmentsPerClient,
              importantNumbers,
            ],
          ),
        ),
      ),
    );
  }
}
