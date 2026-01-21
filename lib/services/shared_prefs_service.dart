import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../../domain/entities/smart_reminder.dart';
import '../../domain/entities/drug_type.dart';  // أضف هذا الاستيراد
import '../../core/providers/family_provider.dart';

class SharedPrefsService {
  static final SharedPrefsService _instance = SharedPrefsService._internal();
  factory SharedPrefsService() => _instance;
  SharedPrefsService._internal();

  // حفظ التذكيرات
  Future<void> saveReminders(List<SmartReminder> reminders) async {
    final prefs = await SharedPreferences.getInstance();
    final remindersJson = reminders.map((r) => jsonEncode({
      'id': r.id,
      'drugName': r.drugName,
      'type': r.type.toString(),
      'dosage': r.dosage,
      'timesPerDay': r.timesPerDay.map((t) => '${t.hour}:${t.minute}').toList(),
      'durationDays': r.durationDays,
      'startDate': r.startDate.toIso8601String(),
      'isActive': r.isActive,
      'dosesTaken': r.dosesTaken,
    })).toList();
    
    await prefs.setStringList('reminders', remindersJson);
  }

  // تحميل التذكيرات
  Future<List<SmartReminder>> loadReminders() async {
    final prefs = await SharedPreferences.getInstance();
    final remindersJson = prefs.getStringList('reminders') ?? [];
    
    return remindersJson.map((json) {
      final map = jsonDecode(json);
      return SmartReminder(
        id: map['id'],
        drugName: map['drugName'],
        type: DrugType.values.firstWhere((e) => e.toString() == map['type'], orElse: () => DrugType.tablet),
        dosage: map['dosage'],
        timesPerDay: (map['timesPerDay'] as List<dynamic>).map((t) {
          final parts = (t as String).split(':');
          return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
        }).toList(),
        durationDays: map['durationDays'],
        startDate: DateTime.parse(map['startDate']),
        isActive: map['isActive'],
        dosesTaken: map['dosesTaken'],
      );
    }).toList();
  }

  // حفظ بيانات العائلة
  Future<void> saveFamilyMembers(List<FamilyMember> members) async {
    final prefs = await SharedPreferences.getInstance();
    final membersJson = members.map((m) => jsonEncode(m.toMap())).toList();
    await prefs.setStringList('familyMembers', membersJson);
  }

  // تحميل بيانات العائلة
  Future<List<FamilyMember>> loadFamilyMembers() async {
    final prefs = await SharedPreferences.getInstance();
    final membersJson = prefs.getStringList('familyMembers') ?? [];
    
    return membersJson.map((json) {
      return FamilyMember.fromMap(jsonDecode(json));
    }).toList();
  }

  // حفظ آخر تحديث
  Future<void> saveLastUpdate() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lastUpdate', DateTime.now().toIso8601String());
  }

  // تحميل آخر تحديث
  Future<DateTime?> loadLastUpdate() async {
    final prefs = await SharedPreferences.getInstance();
    final lastUpdate = prefs.getString('lastUpdate');
    return lastUpdate != null ? DateTime.parse(lastUpdate) : null;
  }
}