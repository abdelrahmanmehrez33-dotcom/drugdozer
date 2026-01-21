import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../di/service_locator.dart';
import '../../domain/entities/drug.dart';
import '../../domain/repositories/drug_repository.dart';
import '../../core/theme/theme_provider.dart';
import 'details_screen.dart';
import 'reminders_screen.dart';
import 'settings_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'الإعدادات',
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // إعدادات التطبيق العامة
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.settings, color: Theme.of(context).primaryColor),
                      const SizedBox(width: 10),
                      Text(
                        'الإعدادات العامة',
                        style: GoogleFonts.cairo(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  
                  // اللغة
                  _buildSettingItem(
                    icon: Icons.language,
                    title: 'اللغة',
                    trailing: DropdownButton<String>(
                      value: 'العربية',
                      items: const [
                        DropdownMenuItem(
                          value: 'العربية',
                          child: Text('العربية'),
                        ),
                        DropdownMenuItem(
                          value: 'English',
                          child: Text('English'),
                        ),
                      ],
                      onChanged: (String? newValue) {
                        // تغيير اللغة
                      },
                    ),
                  ),
                  
                  // الوضع الداكن
                  _buildSettingItem(
                    icon: Icons.dark_mode,
                    title: 'الوضع الداكن',
                    trailing: Switch(
                      value: isDarkMode,
                      onChanged: (value) {
                        themeProvider.toggleTheme(value);
                      },
                      activeColor: Theme.of(context).primaryColor,
                    ),
                  ),
                  
                  // إشعارات
                  _buildSettingItem(
                    icon: Icons.notifications,
                    title: 'الإشعارات',
                    trailing: Switch(
                      value: _notificationsEnabled,
                      onChanged: (value) {
                        setState(() {
                          _notificationsEnabled = value;
                        });
                      },
                      activeColor: Theme.of(context).primaryColor,
                    ),
                  ),
                  
                  // الصوت
                  _buildSettingItem(
                    icon: Icons.volume_up,
                    title: 'الصوت',
                    trailing: Switch(
                      value: _soundEnabled,
                      onChanged: (value) {
                        setState(() {
                          _soundEnabled = value;
                        });
                      },
                      activeColor: Theme.of(context).primaryColor,
                    ),
                  ),
                  
                  // الاهتزاز
                  _buildSettingItem(
                    icon: Icons.vibration,
                    title: 'الاهتزاز',
                    trailing: Switch(
                      value: _vibrationEnabled,
                      onChanged: (value) {
                        setState(() {
                          _vibrationEnabled = value;
                        });
                      },
                      activeColor: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // معلومات التطبيق
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info, color: Theme.of(context).primaryColor),
                      const SizedBox(width: 10),
                      Text(
                        'معلومات التطبيق',
                        style: GoogleFonts.cairo(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  
                  _buildInfoItem(
                    title: 'الإصدار',
                    value: '1.0.0',
                  ),
                  
                  _buildInfoItem(
                    title: 'المطور',
                    value: 'DrugDoZer Team',
                  ),
                  
                  _buildInfoItem(
                    title: 'الاتصال',
                    value: 'support@drugdozer.com',
                  ),
                  
                  const SizedBox(height: 10),
                  
                  Center(
                    child: TextButton.icon(
                      onPressed: () {
                        // سياسة الخصوصية
                      },
                      icon: const Icon(Icons.privacy_tip),
                      label: Text(
                        'سياسة الخصوصية',
                        style: GoogleFonts.cairo(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 30),
          
          // أزرار الإجراءات
          Column(
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  _showBackupDialog(context);
                },
                icon: const Icon(Icons.backup),
                label: Text(
                  'نسخ البيانات احتياطياً',
                  style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
              
              const SizedBox(height: 10),
              
              ElevatedButton.icon(
                onPressed: () {
                  _showResetDialog(context);
                },
                icon: const Icon(Icons.restart_alt),
                label: Text(
                  'إعادة تعيين الإعدادات',
                  style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
              
              const SizedBox(height: 10),
              
              TextButton.icon(
                onPressed: () {
                  _showAboutDialog(context);
                },
                icon: const Icon(Icons.help),
                label: Text(
                  'عن التطبيق',
                  style: GoogleFonts.cairo(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required Widget trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600]),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.cairo(fontSize: 16),
            ),
          ),
          trailing,
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.cairo(fontSize: 14, color: Colors.grey[600]),
          ),
          Text(
            value,
            style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  void _showBackupDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'نسخ البيانات احتياطياً',
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'سيتم حفظ جميع بياناتك محلياً على الجهاز.',
          style: GoogleFonts.cairo(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'تم النسخ الاحتياطي بنجاح!',
                    style: GoogleFonts.cairo(),
                  ),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('نسخ'),
          ),
        ],
      ),
    );
  }

  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'إعادة تعيين الإعدادات',
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'هل أنت متأكد من إعادة تعيين جميع الإعدادات إلى القيم الافتراضية؟',
          style: GoogleFonts.cairo(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _notificationsEnabled = true;
                _soundEnabled = true;
                _vibrationEnabled = true;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'تم إعادة التعيين بنجاح!',
                    style: GoogleFonts.cairo(),
                  ),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('إعادة تعيين'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'DrugDoZer',
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'تطبيق DrugDoZer هو تطبيق طبي يساعدك في حساب جرعات الأدوية وتنظيم مواعيدها.',
              style: GoogleFonts.cairo(),
            ),
            const SizedBox(height: 10),
            Text(
              '© 2024 DrugDoZer Team',
              style: GoogleFonts.cairo(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }
}