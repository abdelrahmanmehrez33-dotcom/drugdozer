import 'package:flutter/material.dart';
import 'drug_type.dart';

class SmartReminder {
  final String id;
  final String drugName;
  final DrugType type;
  final String dosage;
  final List<TimeOfDay> timesPerDay;
  final int durationDays;
  final DateTime startDate;
  bool isActive;
  int dosesTaken;
  
  SmartReminder({
    required this.id,
    required this.drugName,
    required this.type,
    required this.dosage,
    required this.timesPerDay,
    required this.durationDays,
    required this.startDate,
    this.isActive = true,
    this.dosesTaken = 0,
  });
  
  int get totalDoses => timesPerDay.length * durationDays;
  int get remainingDoses => totalDoses - dosesTaken;
  double get progress => totalDoses > 0 ? dosesTaken / totalDoses : 0;
  bool get isCompleted => dosesTaken >= totalDoses;
  
  void markAsTaken() {
    if (dosesTaken < totalDoses) {
      dosesTaken++;
      if (dosesTaken >= totalDoses) {
        isActive = false;
      }
    }
  }
}