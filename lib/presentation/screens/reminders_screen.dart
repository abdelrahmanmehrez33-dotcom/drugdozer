import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../domain/entities/drug_type.dart';
import '../../domain/entities/smart_reminder.dart';
import '../../data/datasources/local_reminders.dart';
import 'add_reminder_screen.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('جدول جرعاتي ⏰', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF00695C),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddReminderScreen()),
              );
            },
            tooltip: 'إضافة تذكير جديد',
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[50],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  icon: Icons.medication,
                  title: 'إجمالي الجرعات',
                  value: smartReminders.fold(0, (sum, reminder) => sum + reminder.totalDoses).toString(),
                ),
                _buildStatItem(
                  icon: Icons.check_circle,
                  title: 'المأخوذ',
                  value: smartReminders.fold(0, (sum, reminder) => sum + reminder.dosesTaken).toString(),
                ),
                _buildStatItem(
                  icon: Icons.timer,
                  title: 'نشطة',
                  value: smartReminders.where((r) => r.isActive).length.toString(),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: smartReminders.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.alarm_add, size: 80, color: Colors.grey[300]),
                        const SizedBox(height: 20),
                        Text(
                          'لا توجد منبهات بعد',
                          style: GoogleFonts.cairo(fontSize: 18, color: Colors.grey),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'اضف منبهات تذكير لمواعيد أدويتك',
                          style: GoogleFonts.cairo(fontSize: 14, color: Colors.grey[500]),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const AddReminderScreen()),
                            );
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('إضافة أول منبه'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00695C),
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: smartReminders.length,
                    itemBuilder: (context, index) {
                      final reminder = smartReminders[index];
                      return _buildReminderCard(reminder, context);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddReminderScreen()),
          );
        },
        backgroundColor: const Color(0xFF00695C),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildStatItem({required IconData icon, required String title, required String value}) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF00695C), size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        Text(
          title,
          style: GoogleFonts.cairo(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildReminderCard(SmartReminder reminder, BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    reminder.drugName,
                    style: GoogleFonts.cairo(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: reminder.isCompleted ? Colors.grey : Colors.black87,
                    ),
                  ),
                ),
                Row(
                  children: [
                    Icon(
                      _getIcon(reminder.type),
                      color: _getColor(reminder.type),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Switch(
                      value: reminder.isActive,
                      onChanged: (value) {
                        setState(() {
                          reminder.isActive = value;
                        });
                      },
                      activeColor: const Color(0xFF00695C),
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            Row(
              children: [
                Icon(Icons.medication, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  'الجرعة: ${reminder.dosage}',
                  style: GoogleFonts.cairo(fontSize: 14, color: Colors.grey[700]),
                ),
                const Spacer(),
                Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  '${reminder.durationDays} يوم',
                  style: GoogleFonts.cairo(fontSize: 14, color: Colors.grey[700]),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            Text(
              'مواعيد اليوم:',
              style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: reminder.timesPerDay.map((time) {
                return Chip(
                  label: Text(
                    time.format(context),
                    style: GoogleFonts.cairo(fontSize: 12),
                  ),
                  backgroundColor: Colors.blue[50],
                  visualDensity: VisualDensity.compact,
                );
              }).toList(),
            ),
            
            const SizedBox(height: 16),
            
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'تقدم العلاج',
                      style: GoogleFonts.cairo(fontSize: 14, color: Colors.grey[700]),
                    ),
                    Text(
                      '${reminder.dosesTaken}/${reminder.totalDoses} جرعة',
                      style: GoogleFonts.cairo(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF00695C),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: reminder.progress,
                  backgroundColor: Colors.grey[200],
                  color: reminder.isCompleted ? Colors.green : const Color(0xFF00695C),
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (!reminder.isCompleted)
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            reminder.markAsTaken();
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('تم تسجيل جرعة ${reminder.drugName} ✅'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        },
                        icon: const Icon(Icons.check, size: 16),
                        label: const Text('تسجيل جرعة مأخوذة'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                      ),
                    if (reminder.isCompleted)
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green[200]!),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.green[700], size: 16),
                            const SizedBox(width: 4),
                            Text(
                              'تم إنهاء العلاج',
                              style: GoogleFonts.cairo(
                                color: Colors.green[700],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIcon(DrugType type) {
    switch (type) {
      case DrugType.syrup: return Icons.water_drop;
      case DrugType.tablet: return Icons.medication;
      case DrugType.cream: return Icons.healing;
      case DrugType.spray: return Icons.air;
      case DrugType.drops: return Icons.water_drop_outlined;
      case DrugType.injection: return Icons.medication_liquid;
    }
  }

  Color _getColor(DrugType type) {
    switch (type) {
      case DrugType.syrup: return const Color(0xFF2196F3);
      case DrugType.tablet: return const Color(0xFF4CAF50);
      case DrugType.cream: return const Color(0xFFFF9800);
      case DrugType.spray: return const Color(0xFF9C27B0);
      case DrugType.drops: return const Color(0xFF00BCD4);
      case DrugType.injection: return const Color(0xFFF44336);
    }
  }
}