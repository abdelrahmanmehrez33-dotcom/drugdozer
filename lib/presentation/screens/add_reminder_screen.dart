import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../di/service_locator.dart';
import '../../domain/entities/drug.dart';
import '../../domain/entities/drug_type.dart';
import '../../domain/entities/smart_reminder.dart';
import '../../domain/repositories/drug_repository.dart';
import '../../data/datasources/local_reminders.dart';
import '../../services/notification_service.dart';

class AddReminderScreen extends StatefulWidget {
  final String? initialDrugName;
  final String? initialDrugType;
  
  const AddReminderScreen({
    super.key,
    this.initialDrugName,
    this.initialDrugType,
  });

  @override
  State<AddReminderScreen> createState() => _AddReminderScreenState();
}

class _AddReminderScreenState extends State<AddReminderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _drugNameController = TextEditingController();
  final _dosageController = TextEditingController();
  
  DrugType _selectedType = DrugType.tablet;
  int _durationDays = 7;
  int _timesPerDay = 1;
  
  List<TimeOfDay> _selectedTimes = [TimeOfDay.now()];
  final NotificationService _notificationService = getIt<NotificationService>();
  final ReminderService _reminderService = getIt<ReminderService>();

  @override
  void initState() {
    super.initState();
    
    if (widget.initialDrugName != null) {
      _drugNameController.text = widget.initialDrugName!;
    }
    
    if (widget.initialDrugType != null) {
      _selectedType = _convertStringToDrugType(widget.initialDrugType!);
    }
    
    _dosageController.text = _getDefaultDosage(_selectedType);
  }

  DrugType _convertStringToDrugType(String drugType) {
    switch (drugType) {
      case 'syrup': return DrugType.syrup;
      case 'tablet': return DrugType.tablet;
      case 'cream': return DrugType.cream;
      case 'spray': return DrugType.spray;
      case 'drops': return DrugType.drops;
      case 'injection': return DrugType.injection;
      default: return DrugType.tablet;
    }
  }

  void _addTime() {
    setState(() {
      final lastTime = _selectedTimes.last;
      final newHour = (lastTime.hour + 2) % 24;
      _selectedTimes.add(TimeOfDay(hour: newHour, minute: lastTime.minute));
    });
  }

  void _removeTime(int index) {
    if (_selectedTimes.length > 1) {
      setState(() {
        _selectedTimes.removeAt(index);
      });
    }
  }

  Future<void> _selectTime(int index) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTimes[index],
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(primary: Colors.teal),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        _selectedTimes[index] = picked;
      });
    }
  }

  Future<void> _scheduleAllNotifications(SmartReminder reminder) async {
    await _notificationService.init();
    
    final now = DateTime.now();
    
    for (int day = 0; day < reminder.durationDays; day++) {
      final currentDate = DateTime(now.year, now.month, now.day + day);
      
      for (int timeIndex = 0; timeIndex < reminder.timesPerDay.length; timeIndex++) {
        final time = reminder.timesPerDay[timeIndex];
        final notificationTime = DateTime(
          currentDate.year,
          currentDate.month,
          currentDate.day,
          time.hour,
          time.minute,
        );
        
        final notificationId = int.parse('${reminder.id.hashCode}${day}${timeIndex}');
        
        await _notificationService.scheduleNotification(
          id: notificationId,
          title: '⏰ تذكير بجرعة ${reminder.drugName}',
          body: 'الجرعة: ${reminder.dosage}',
          scheduledTime: notificationTime,
        );
      }
    }
  }

  void _submitReminder() async {
    if (_formKey.currentState!.validate()) {
      final newReminder = SmartReminder(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        drugName: _drugNameController.text,
        type: _selectedType,
        dosage: _dosageController.text,
        timesPerDay: List.from(_selectedTimes),
        durationDays: _durationDays,
        startDate: DateTime.now(),
      );

      // إضافة للمنبهات الذكية وحفظ تلقائي
      await _reminderService.addReminder(newReminder);

      // جدولة التنبيهات
      await _scheduleAllNotifications(newReminder);

      // إظهار رسالة نجاح
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم إضافة منبه ${newReminder.drugName} بنجاح! ⏰'),
          backgroundColor: Colors.green,
        ),
      );

      // العودة للشاشة السابقة
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إضافة منبه جديد'),
        backgroundColor: const Color(0xFF00695C),
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // اسم الدواء
              TextFormField(
                controller: _drugNameController,
                decoration: InputDecoration(
                  labelText: 'اسم الدواء *',
                  hintText: 'أدخل اسم الدواء',
                  prefixIcon: const Icon(Icons.medication),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال اسم الدواء';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 20),
              
              // نوع الدواء
              DropdownButtonFormField<DrugType>(
                value: _selectedType,
                decoration: InputDecoration(
                  labelText: 'نوع الدواء *',
                  prefixIcon: const Icon(Icons.category),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                items: DrugType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type.arabicName),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedType = value;
                      _dosageController.text = _getDefaultDosage(value);
                    });
                  }
                },
              ),
              
              const SizedBox(height: 20),
              
              // الجرعة
              TextFormField(
                controller: _dosageController,
                decoration: InputDecoration(
                  labelText: 'الجرعة *',
                  hintText: 'مثال: قرص واحد، 5 مل، كبسولة',
                  prefixIcon: const Icon(Icons.science),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال الجرعة';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 20),
              
              // عدد المرات في اليوم
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'عدد المرات في اليوم',
                            style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove),
                                onPressed: () {
                                  if (_timesPerDay > 1) {
                                    setState(() {
                                      _timesPerDay--;
                                      if (_selectedTimes.length > _timesPerDay) {
                                        _selectedTimes.removeLast();
                                      }
                                    });
                                  }
                                },
                              ),
                              Text(
                                '$_timesPerDay',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: () {
                                  if (_timesPerDay < 6) {
                                    setState(() {
                                      _timesPerDay++;
                                      if (_selectedTimes.length < _timesPerDay) {
                                        _addTime();
                                      }
                                    });
                                  }
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // مواعيد الجرعات
                      Text(
                        'مواعيد الجرعات:',
                        style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      
                      Wrap(
                        spacing: 8,
                        children: List.generate(_timesPerDay, (index) {
                          return InputChip(
                            label: Text(
                              _selectedTimes[index].format(context),
                              style: GoogleFonts.cairo(),
                            ),
                            onPressed: () => _selectTime(index),
                            deleteIcon: _timesPerDay > 1 ? const Icon(Icons.close, size: 16) : null,
                            onDeleted: _timesPerDay > 1 ? () => _removeTime(index) : null,
                            backgroundColor: Colors.blue[50],
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // مدة العلاج بالأيام
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'مدة العلاج بالأيام',
                            style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove),
                                onPressed: () {
                                  if (_durationDays > 1) {
                                    setState(() {
                                      _durationDays--;
                                    });
                                  }
                                },
                              ),
                              Text(
                                '$_durationDays يوم',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: () {
                                  if (_durationDays < 30) {
                                    setState(() {
                                      _durationDays++;
                                    });
                                  }
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 8),
                      
                      LinearProgressIndicator(
                        value: _durationDays / 30,
                        backgroundColor: Colors.grey[200],
                        color: const Color(0xFF00695C),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'إجمالي الجرعات: ${_timesPerDay * _durationDays} جرعة',
                        style: GoogleFonts.cairo(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 30),
              
              // زر الإضافة
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitReminder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00695C),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.alarm_add),
                      const SizedBox(width: 10),
                      Text(
                        'إضافة المنبه',
                        style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getDefaultDosage(DrugType type) {
    switch (type) {
      case DrugType.syrup: return "5 مل";
      case DrugType.tablet: return "قرص واحد";
      case DrugType.cream: return "طبقة رقيقة";
      case DrugType.spray: return "بخة واحدة";
      case DrugType.drops: return "3 نقط";
      case DrugType.injection: return "حقنة واحدة";
    }
  }
}