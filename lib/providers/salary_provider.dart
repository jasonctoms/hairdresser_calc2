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

  double _commissionValue;
  bool _fixedSalary;
  int _dailyTreatments;
  int _monthlyTreatments;
  int _dailySales;
  int _monthlySales;
  int _daysLeft;
  int _monthlyClients;
  int _goalGross;
  int _goalNet;
  int _goalSalary;

  bool _goalValidationError = false;
  bool _dailyTreatmentsValidationError = false;
  bool _dailySalesValidationError = false;

  double get commissionValue => _commissionValue;

  bool get fixedSalary => _fixedSalary;

  int get dailyTreatments => _dailyTreatments;

  int get monthlyTreatments => _monthlyTreatments;

  int get dailySales => _dailySales;

  int get monthlySales => _monthlySales;

  int get daysLeft => _daysLeft;

  int get monthlyClients => _monthlyClients;

  int get goalGross => _goalGross;

  int get goalNet => _goalNet;

  int get goalSalary => _goalSalary;

  bool get goalValidationError => _goalValidationError;

  bool get dailyTreatmentsValidationError => _dailyTreatmentsValidationError;

  bool get dailySalesValidationError => _dailySalesValidationError;

  SalaryProvider() {
    _box = Hive.box(salaryBox);

    // initialize values
    _commissionValue = _box.get(commissionKey, defaultValue: 0.4);
    _fixedSalary = _box.get(fixedSalaryKey, defaultValue: false);
    _dailyTreatments = _box.get(dailyTreatmentsKey, defaultValue: 0);
    _monthlyTreatments = _box.get(monthlyTreatmentsKey, defaultValue: 0);
    _dailySales = _box.get(dailySalesKey, defaultValue: 0);
    _monthlySales = _box.get(monthlySalesKey, defaultValue: 0);
    _daysLeft = _box.get(daysLeftKey, defaultValue: 20);
    _monthlyClients = _box.get(monthlyClientsKey, defaultValue: 0);
    _goalGross = _box.get(goalGrossKey, defaultValue: 125000);
    _goalNet = _box.get(goalNetKey, defaultValue: 100000);
    _goalSalary = _box.get(goalSalaryKey, defaultValue: 40000);
  }

  resetMonth() {
    _monthlyTreatments = 0;
    _monthlySales = 0;
    _daysLeft = 20;
    _monthlyClients = 0;
    _box.put(monthlyTreatmentsKey, _monthlyTreatments);
    _box.put(monthlySalesKey, _monthlySales);
    _box.put(daysLeftKey, _daysLeft);
    _box.put(monthlyClientsKey, _monthlyClients);
    notifyListeners();
  }

  setCommission(double newCommission) {
    if (newCommission == null) {
      _fixedSalary = true;
    } else {
      _fixedSalary = false;
      _commissionValue = newCommission;
      _box.put(commissionKey, _commissionValue);
    }
    _box.put(fixedSalaryKey, _fixedSalary);
    notifyListeners();
  }

  addDay() {
    if (daysLeft == 31) {
      _daysLeft = 1;
    } else {
      _daysLeft += 1;
    }
    _box.put(daysLeftKey, _daysLeft);
    notifyListeners();
  }

  subtractDay() {
    if (daysLeft == 1) {
      _daysLeft = 31;
    } else {
      _daysLeft -= 1;
    }
    _box.put(daysLeftKey, _daysLeft);
    notifyListeners();
  }

  addClient() {
    _monthlyClients += 1;
    _box.put(monthlyClientsKey, _monthlyClients);
    notifyListeners();
  }

  subtractClient() {
    if (_monthlyClients >= 0) {
      _monthlyClients -= 1;
    } else {
      _monthlyClients = 0;
    }
    _box.put(monthlyClientsKey, _monthlyClients);
    notifyListeners();
  }

  updateDailyTreatments(String dailyTreatments) {
    try {
      if (dailyTreatments == null || dailyTreatments.isEmpty) {
        _dailyTreatments = 0;
      } else {
        final inputInt = int.parse(dailyTreatments);
        _dailyTreatments = inputInt;
      }
      _dailyTreatmentsValidationError = false;
      _box.put(dailyTreatmentsKey, _dailyTreatments);
    } on Exception catch (e) {
      print('Error: $e');
      _dailyTreatmentsValidationError = true;
    }
    notifyListeners();
  }

  addDailyTreatmentsToMonth() {
    _monthlyTreatments += _dailyTreatments;
    _box.put(monthlyTreatmentsKey, _monthlyTreatments);
    notifyListeners();
  }

  updateMonthlyTreatments(int updatedTreatments) {
    _monthlyTreatments = updatedTreatments;
    _box.put(monthlyTreatmentsKey, _monthlyTreatments);
    notifyListeners();
  }

  updateDailySales(String dailySales) {
    try {
      if (dailySales == null || dailySales.isEmpty) {
        _dailySales = 0;
      } else {
        final inputInt = int.parse(dailySales);
        _dailySales = inputInt;
      }
      _dailySalesValidationError = false;
      _box.put(dailySalesKey, _dailySales);
    } on Exception catch (e) {
      print('Error: $e');
      _dailySalesValidationError = true;
    }
    notifyListeners();
  }

  addDailySalesToMonth() {
    _monthlySales += _dailySales;
    _box.put(monthlySalesKey, _monthlySales);
    notifyListeners();
  }

  updateMonthlySales(int updatedSales) {
    _monthlySales = updatedSales;
    _box.put(monthlySalesKey, _monthlySales);
    notifyListeners();
  }

  updateGoal(GoalSelection goalSelection, String input) {
    try {
      if (input == null || input.isEmpty) {
        _goalGross = 0;
        _goalNet = 0;
        _goalSalary = 0;
      } else {
        final inputInt = int.parse(input);
        if (goalSelection == GoalSelection.GROSS) {
          _goalGross = inputInt;
          var net = inputInt * 0.8;
          _goalNet = net.round();
          var salary = net * _commissionValue;
          _goalSalary = salary.round();
        } else if (goalSelection == GoalSelection.NET) {
          _goalNet = inputInt;
          var gross = inputInt / 0.8;
          _goalGross = gross.round();
          var salary = inputInt * _commissionValue;
          _goalSalary = salary.round();
        } else {
          _goalSalary = inputInt;
          var net = inputInt / _commissionValue;
          _goalNet = net.round();
          var gross = net / 0.8;
          _goalGross = gross.round();
        }
      }
      _goalValidationError = false;
      _box.put(goalGrossKey, _goalGross);
      _box.put(goalNetKey, _goalNet);
      _box.put(goalSalaryKey, _goalSalary);
    } on Exception catch (e) {
      print('Error: $e');
      _goalValidationError = true;
    }
    notifyListeners();
  }
}
