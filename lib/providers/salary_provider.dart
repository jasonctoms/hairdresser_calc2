import 'package:flutter/material.dart';
import 'package:hairdresser_calc2/widgets/salary_page.dart';
import 'package:hive/hive.dart';

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

  double get commissionValue => _commissionValue;

  int get todaysIntake => _todaysIntake;

  int get monthsIntake => _monthsIntake;

  int get daysLeft => _daysLeft;

  int get goalGross => _goalGross;

  int get goalNet => _goalNet;

  int get goalSalary => _goalSalary;

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
}
