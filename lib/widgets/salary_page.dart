import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/translations.dart';
import 'package:hairdresser_calc2/extensions/int_extensions.dart';
import 'package:hairdresser_calc2/providers/salary_provider.dart';
import 'package:hairdresser_calc2/widgets/app_bar_menu.dart';
import 'package:hairdresser_calc2/widgets/commission_dialog.dart';
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
  int remainingIntake() {
    var goalGross = context.watch<SalaryProvider>().goalGross;
    var monthlyTreatments = context.watch<SalaryProvider>().monthlyTreatments;
    var monthlySales = context.watch<SalaryProvider>().monthlySales;
    return goalGross - (monthlyTreatments + monthlySales);
  }

  int amountNeededPerDay() {
    var daysLeft = context.watch<SalaryProvider>().daysLeft;
    return (remainingIntake() / daysLeft).round();
  }

  int salaryWithCurrentIntake() {
    var commissionValue = context.watch<SalaryProvider>().commissionValue;
    var monthlyTreatments = context.watch<SalaryProvider>().monthlyTreatments;
    var monthlySales = context.watch<SalaryProvider>().monthlySales;
    return ((monthlyTreatments * 0.8 * commissionValue) + (monthlySales * 0.8)).round();
  }

  @override
  Widget build(BuildContext context) {
    bool _fixedSalary = context.watch<SalaryProvider>().fixedSalary;

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
                  return CommissionDialog();
                });
          },
          child: Text(
            _fixedSalary
                ? Translations.of(context).notApplicable
                : "${context.watch<SalaryProvider>().commissionValue * 100}%",
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
              IntakeWidget(
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
              ),
              IntakeWidget(
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
              ),
              currentSalary,
              importantNumbers,
            ],
          ),
        ),
      ),
    );
  }
}
