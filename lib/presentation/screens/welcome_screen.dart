import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/providers/language_provider.dart';
import 'home_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  String _selectedLanguage = 'العربية';

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    bool isEnglish = languageProvider.isEnglish;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              
              // الشعار
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).primaryColor.withOpacity(0.7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).primaryColor.withOpacity(0.3),
                      blurRadius: 15,
                      spreadRadius: 3,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    Icons.medical_services,
                    size: 70,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // العنوان الرئيسي
              Text(
                'DrugDoZer',
                style: GoogleFonts.cairo(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 8),
              
              // الوصف
              Text(
                isEnglish ? 'Smart Medicine Organizer' : 'دراج دوزر - منظم الدواء الذكي',
                style: GoogleFonts.cairo(
                  fontSize: 18,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 40),
              
              // ميزات التطبيق
              _buildFeatureItem(
                icon: Icons.medication,
                title: isEnglish ? 'Complete Medicine Library' : 'مكتبة أدوية شاملة',
                description: isEnglish ? 'Over 100 medicines with detailed information' : 'أكثر من 100 دواء مع معلومات تفصيلية',
                color: const Color(0xFF2196F3),
                iconColor: Colors.white,
              ),
              
              _buildFeatureItem(
                icon: Icons.calculate,
                title: isEnglish ? 'Smart Dose Calculator' : 'حاسبة جرعات ذكية',
                description: isEnglish ? 'Calculate accurate doses based on child weight' : 'احسب الجرعة المناسبة حسب وزن الطفل بدقة',
                color: const Color(0xFF4CAF50),
                iconColor: Colors.white,
              ),
              
              _buildFeatureItem(
                icon: Icons.notifications_active,
                title: isEnglish ? 'Dose Reminders' : 'منبهات تذكير',
                description: isEnglish ? "Never forget your medicine times" : 'لا تنسى مواعيد جرعاتك',
                color: const Color(0xFFFF9800),
                iconColor: Colors.white,
              ),
              
              _buildFeatureItem(
                icon: Icons.family_restroom,
                title: isEnglish ? 'Family Medical File' : 'ملف العائلة الطبي',
                description: isEnglish ? 'Manage medical records for all family members' : 'إدارة السجلات الطبية لجميع أفراد العائلة',
                color: const Color(0xFF9C27B0),
                iconColor: Colors.white,
              ),
              
              const SizedBox(height: 30),
              
              // اختيار اللغة
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 2,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  children: [
                    Text(
                      isEnglish ? 'Choose Your Language' : 'اختر اللغة المفضلة',
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildLanguageButton(
                          language: 'العربية',
                          isSelected: _selectedLanguage == 'العربية',
                          flag: '🇸🇦',
                          onTap: () {
                            setState(() {
                              _selectedLanguage = 'العربية';
                            });
                            languageProvider.switchToArabic();
                          },
                        ),
                        const SizedBox(width: 10),
                        _buildLanguageButton(
                          language: 'English',
                          isSelected: _selectedLanguage == 'English',
                          flag: '🇺🇸',
                          onTap: () {
                            setState(() {
                              _selectedLanguage = 'English';
                            });
                            languageProvider.switchToEnglish();
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 30),
              
              // زر البداية
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const HomeScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 4,
                    shadowColor: Theme.of(context).primaryColor.withOpacity(0.3),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isEnglish ? 'Get Started' : 'ابدأ الآن',
                        style: GoogleFonts.cairo(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.arrow_forward, size: 24),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // زر تخطي (للمستخدمين المتقدمين)
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                  );
                },
                child: Text(
                  isEnglish ? 'Skip and Continue' : 'تخطي والمتابعة',
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ),
              
              const SizedBox(height: 30),
              
              // تذييل الصفحة
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      '⚠️ ${isEnglish ? 'Important Note' : 'تنبيه مهم'}',
                      style: GoogleFonts.cairo(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange[700],
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isEnglish 
                          ? 'This app is for assistance only and does not replace doctor consultation'
                          : 'هذا التطبيق للمساعدة فقط ولا يغني عن استشارة الطبيب',
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // معلومات حقوق النشر
              Text(
                isEnglish 
                    ? '© 2024 DrugDoZer Team\nVersion 1.0.0'
                    : '© 2024 فريق DrugDoZer\nالإصدار 1.0.0',
                style: GoogleFonts.cairo(
                  fontSize: 11,
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required Color iconColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 6,
                  spreadRadius: 1,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, color: iconColor, size: 26),
          ),
          
          const SizedBox(width: 16),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.cairo(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          
          Icon(
            Icons.check_circle,
            color: color,
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageButton({
    required String language,
    required bool isSelected,
    required String flag,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? Theme.of(context).primaryColor : Colors.grey[300]!,
            width: 2,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: Theme.of(context).primaryColor.withOpacity(0.2),
              blurRadius: 6,
              spreadRadius: 2,
              offset: const Offset(0, 2),
            ),
          ] : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              flag,
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(width: 8),
            Text(
              language,
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Colors.black87,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}