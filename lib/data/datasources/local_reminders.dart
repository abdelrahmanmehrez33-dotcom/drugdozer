import '../../domain/entities/smart_reminder.dart';
import '../../services/shared_prefs_service.dart';

List<SmartReminder> smartReminders = [];

class ReminderService {
  static final ReminderService _instance = ReminderService._internal();
  factory ReminderService() => _instance;
  ReminderService._internal();

  final SharedPrefsService _prefsService = SharedPrefsService();

  Future<void> loadReminders() async {
    smartReminders = await _prefsService.loadReminders();
  }

  Future<void> saveReminders() async {
    await _prefsService.saveReminders(smartReminders);
  }

  Future<void> addReminder(SmartReminder reminder) async {
    smartReminders.add(reminder);
    await saveReminders();
  }

  Future<void> updateReminder(String id, SmartReminder updatedReminder) async {
    final index = smartReminders.indexWhere((r) => r.id == id);
    if (index != -1) {
      smartReminders[index] = updatedReminder;
      await saveReminders();
    }
  }

  Future<void> deleteReminder(String id) async {
    smartReminders.removeWhere((r) => r.id == id);
    await saveReminders();
  }

  void markAsTaken(String id) {
    final index = smartReminders.indexWhere((r) => r.id == id);
    if (index != -1) {
      smartReminders[index].markAsTaken();
      saveReminders();
    }
  }

  void toggleActive(String id) {
    final index = smartReminders.indexWhere((r) => r.id == id);
    if (index != -1) {
      smartReminders[index].isActive = !smartReminders[index].isActive;
      saveReminders();
    }
  }
}