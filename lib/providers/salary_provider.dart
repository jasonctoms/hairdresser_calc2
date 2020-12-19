import 'package:flutter/material.dart';
import 'package:hairdresser_calc2/widgets/goal_widget.dart';
import 'package:hive/hive.dart';

const salaryBox = "salaryBoxKey";
const commissionKey = 'commissionKey';
const fixedSalaryKey = 'fixedSalaryKey';
const dailyTreatmentsKey = 'dailyTreatmentsKey';
const monthlyTreatmentsKey = 'monthlyTreatmentsKey';
const dailySalesKey = 'dailySalesKey';
const monthlySalesKey = 'monthlySalesKey';
const daysLeftKey = 'daysLeftKey';
const monthlyClientsKey = 'monthlyClientsKey';
const goalGrossKey = 'goalGrossKey';
const goalNetKey = 'goalNetKey';
const goalSalaryKey = 'goalSalaryKey';

class SalaryProvider with ChangeNotifier {
  Box _box;

  bool _goalValidationError = false;
  bool _dailyTreatmentsValidationError = false;
  bool _dailySalesValidationError = false;

  double get commissionValue => _box.get(commissionKey, defaultValue: 0.4);

  bool get fixedSalary => _box.get(fixedSalaryKey, defaultValue: false);

  int get dailyTreatments => _box.get(dailyTreatmentsKey, defaultValue: 0);

  int get monthlyTreatments => _box.get(monthlyTreatmentsKey, defaultValue: 0);

  int get dailySales => _box.get(dailySalesKey, defaultValue: 0);

  int get monthlySales => _box.get(monthlySalesKey, defaultValue: 0);

  int get daysLeft => _box.get(daysLeftKey, defaultValue: 20);

  int get monthlyClients => _box.get(monthlyClientsKey, defaultValue: 0);

  int get goalGross => _box.get(goalGrossKey, defaultValue: 125000);

  int get goalNet => _box.get(goalNetKey, defaultValue: 100000);

  int get goalSalary => _box.get(goalSalaryKey, defaultValue: 40000);

  bool get goalValidationError => _goalValidationError;

  bool get dailyTreatmentsValidationError => _dailyTreatmentsValidationError;

  bool get dailySalesValidationError => _dailySalesValidationError;

  int get remainingIntake => calculateRemainingIntake();

  int get amountNeededPerDay => calculateAmountNeededPerDay();

  int get salaryWithCurrentIntake => calculateSalaryWithCurrentIntake();

  int get treatmentValuePerClient => calculateTreatmentValuePerClient();

  SalaryProvider() {
    _box = Hive.box(salaryBox);
  }

  resetMonth() {
    _box.put(monthlyTreatmentsKey, 0);
    _box.put(monthlySalesKey, 0);
    _box.put(daysLeftKey, 20);
    _box.put(monthlyClientsKey, 0);
    notifyListeners();
  }

  setCommission(double newCommission) {
    if (newCommission == null) {
      _box.put(fixedSalaryKey, true);
    } else {
      _box.put(fixedSalaryKey, false);
      _box.put(commissionKey, newCommission);
    }
    notifyListeners();
  }

  addDay() {
    if (daysLeft == 31) {
      _box.put(daysLeftKey, 1);
    } else {
      _box.put(daysLeftKey, daysLeft + 1);
    }
    notifyListeners();
  }

  subtractDay() {
    if (daysLeft == 1) {
      _box.put(daysLeftKey, 31);
    } else {
      _box.put(daysLeftKey, daysLeft - 1);
    }
    notifyListeners();
  }

  addClient() {
    _box.put(monthlyClientsKey, monthlyClients + 1);
    notifyListeners();
  }

  subtractClient() {
    if (monthlyClients >= 0) {
      _box.put(monthlyClientsKey, monthlyClients - 1);
    } else {
      _box.put(monthlyClientsKey, 0);
    }
    notifyListeners();
  }

  updateDailyTreatments(String dailyTreatments) {
    try {
      if (dailyTreatments == null || dailyTreatments.isEmpty) {
        _box.put(dailyTreatmentsKey, 0);
      } else {
        final inputInt = int.parse(dailyTreatments);
        _box.put(dailyTreatmentsKey, inputInt);
      }
      _dailyTreatmentsValidationError = false;
    } on Exception catch (e) {
      print('Error: $e');
      _dailyTreatmentsValidationError = true;
    }
    notifyListeners();
  }

  addDailyTreatmentsToMonth() {
    _box.put(monthlyTreatmentsKey, monthlyTreatments + dailyTreatments);
    notifyListeners();
  }

  updateMonthlyTreatments(int updatedTreatments) {
    _box.put(monthlyTreatmentsKey, updatedTreatments);
    notifyListeners();
  }

  updateDailySales(String dailySales) {
    try {
      if (dailySales == null || dailySales.isEmpty) {
        _box.put(dailySalesKey, 0);
      } else {
        final inputInt = int.parse(dailySales);
        _box.put(dailySalesKey, inputInt);
      }
      _dailySalesValidationError = false;
    } on Exception catch (e) {
      print('Error: $e');
      _dailySalesValidationError = true;
    }
    notifyListeners();
  }

  addDailySalesToMonth() {
    _box.put(monthlySalesKey, monthlySales + dailySales);
    notifyListeners();
  }

  updateMonthlySales(int updatedSales) {
    _box.put(monthlySalesKey, updatedSales);
    notifyListeners();
  }

  updateGoal(GoalSelection goalSelection, String input) {
    try {
      if (input == null || input.isEmpty) {
        _box.put(goalGrossKey, 0);
        _box.put(goalNetKey, 0);
        _box.put(goalSalaryKey, 0);
      } else {
        final inputInt = int.parse(input);
        if (goalSelection == GoalSelection.GROSS) {
          _box.put(goalGrossKey, inputInt);
          var net = inputInt * 0.8;
          _box.put(goalNetKey, net.round());
          var salary = net * commissionValue;
          _box.put(goalSalaryKey, salary.round());
        } else if (goalSelection == GoalSelection.NET) {
          _box.put(goalNetKey, inputInt);
          var gross = inputInt / 0.8;
          _box.put(goalGrossKey, gross.round());
          var salary = inputInt * commissionValue;
          _box.put(goalSalaryKey, salary.round());
        } else {
          _box.put(goalSalaryKey, inputInt);
          var net = inputInt / commissionValue;
          _box.put(goalNetKey, net.round());
          var gross = net / 0.8;
          _box.put(goalGrossKey, gross.round());
        }
      }
      _goalValidationError = false;
    } on Exception catch (e) {
      print('Error: $e');
      _goalValidationError = true;
    }
    notifyListeners();
  }

  int calculateRemainingIntake() {
    var calculatedMonthlySales = fixedSalary ? monthlySales : 0;
    return goalGross - (monthlyTreatments + calculatedMonthlySales);
  }

  int calculateAmountNeededPerDay() {
    return (calculateRemainingIntake() / daysLeft).round();
  }

  int calculateSalaryWithCurrentIntake() {
    return (monthlyTreatments * 0.8 * commissionValue).round();
  }

  int calculateTreatmentValuePerClient() {
    return monthlyClients == 0 ? 0 : (monthlyTreatments / monthlyClients).round();
  }
}
