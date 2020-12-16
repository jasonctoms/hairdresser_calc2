import 'package:flutter/material.dart';
import 'package:hairdresser_calc2/widgets/goal_widget.dart';
import 'package:hive/hive.dart';

const salaryBox = "salaryBoxKey";
const commissionKey = 'commissionKey';
const todaysIntakeKey = 'todaysIntakeKey';
const monthsIntakeKey = 'monthsIntakeKey';
const daysLeftKey = 'daysLeftKey';
const goalGrossKey = 'goalGrossKey';
const goalNetKey = 'goalNetKey';
const goalSalaryKey = 'goalSalaryKey';

class SalaryProvider with ChangeNotifier {
  Box _box;

  double _commissionValue;
  int _todaysIntake;
  int _monthsIntake;
  int _daysLeft;
  int _goalGross;
  int _goalNet;
  int _goalSalary;

  bool _goalValidationError = false;
  bool _todaysIntakeValidationError = false;

  double get commissionValue => _commissionValue;

  int get todaysIntake => _todaysIntake;

  int get monthsIntake => _monthsIntake;

  int get daysLeft => _daysLeft;

  int get goalGross => _goalGross;

  int get goalNet => _goalNet;

  int get goalSalary => _goalSalary;

  bool get goalValidationError => _goalValidationError;

  bool get todaysIntakeValidationError => _todaysIntakeValidationError;

  SalaryProvider() {
    _box = Hive.box(salaryBox);

    // initialize values
    _commissionValue = _box.get(commissionKey, defaultValue: 0.4);
    _todaysIntake = _box.get(todaysIntakeKey, defaultValue: 0);
    _monthsIntake = _box.get(monthsIntakeKey, defaultValue: 0);
    _daysLeft = _box.get(daysLeftKey, defaultValue: 20);
    _goalGross = _box.get(goalGrossKey, defaultValue: 125000);
    _goalNet = _box.get(goalNetKey, defaultValue: 100000);
    _goalSalary = _box.get(goalSalaryKey, defaultValue: 40000);
  }

  setCommission(double newCommission) {
    _commissionValue = newCommission;
    _box.put(commissionKey, _commissionValue);
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

  updateTodaysIntake(String todaysIntake) {
    try {
      if (todaysIntake == null || todaysIntake.isEmpty) {
        _todaysIntake = 0;
      } else {
        final inputInt = int.parse(todaysIntake);
        _todaysIntake = inputInt;
      }
      _todaysIntakeValidationError = false;
      _box.put(todaysIntakeKey, _todaysIntake);
    } on Exception catch (e) {
      print('Error: $e');
      _todaysIntakeValidationError = true;
    }
    notifyListeners();
  }

  addTodaysIntakeToMonth() {
    _monthsIntake += _todaysIntake;
    _box.put(monthsIntakeKey, _monthsIntake);
    notifyListeners();
  }

  clearMonthlyIntake() {
    _monthsIntake = 0;
    _box.put(monthsIntakeKey, _monthsIntake);
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
