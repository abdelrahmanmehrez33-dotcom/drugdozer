import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../di/service_locator.dart';
import '../../domain/entities/drug.dart';
import '../../domain/entities/drug_type.dart';
import '../../domain/repositories/drug_repository.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/providers/language_provider.dart';
import '../../core/providers/family_provider.dart';
import 'details_screen.dart';
import 'reminders_screen.dart';
import 'settings_screen.dart';
import 'family_screen.dart';
import 'search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DrugRepository _drugRepository = getIt<DrugRepository>();
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final familyProvider = Provider.of<FamilyProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    bool isEnglish = languageProvider.isEnglish;

    // تعريف عناوين الصفحات حسب اللغة
    List<String> pageTitles = [
      isEnglish ? 'Home' : 'الرئيسية',
      isEnglish ? 'Medications' : 'الأدوية',
      isEnglish ? 'Reminders' : 'التذكيرات',
      isEnglish ? 'Family File' : 'ملف العائلة',
    ];

    // تعريف الأيقونات
    List<IconData> pageIcons = [
      Icons.home,
      Icons.medication,
      Icons.notifications,
      Icons.family_restroom,
    ];

    // تعريف صفحات المحتوى
    final List<Widget> _pages = [
      // الصفحة الرئيسية مع البطاقات
      _buildHomePage(context, languageProvider, familyProvider),
      
      // صفحة الأدوية
      _buildMedicationsPage(context),
      
      // صفحة التذكيرات
      const RemindersScreen(),
      
      // صفحة ملف العائلة
      FamilyScreen(familyProvider: familyProvider),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          pageTitles[_selectedIndex],
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(isEnglish ? Icons.language : Icons.translate),
            onPressed: () {
              languageProvider.toggleLanguage();
            },
            tooltip: isEnglish ? 'Switch Language' : 'تبديل اللغة',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
            tooltip: isEnglish ? 'Settings' : 'الإعدادات',
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Theme.of(context).primaryColor,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white.withOpacity(0.7),
        items: [
          BottomNavigationBarItem(
            icon: Icon(pageIcons[0]),
            label: pageTitles[0],
          ),
          BottomNavigationBarItem(
            icon: Icon(pageIcons[1]),
            label: pageTitles[1],
          ),
          BottomNavigationBarItem(
            icon: Icon(pageIcons[2]),
            label: pageTitles[2],
          ),
          BottomNavigationBarItem(
            icon: Icon(pageIcons[3]),
            label: pageTitles[3],
          ),
        ],
      ),
      floatingActionButton: _selectedIndex == 1 || _selectedIndex == 3
          ? FloatingActionButton(
              onPressed: () {
                if (_selectedIndex == 1) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SearchScreen()),
                  );
                } else if (_selectedIndex == 3) {
                  _showAddFamilyMemberDialog(context, familyProvider);
                }
              },
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              child: const Icon(Icons.add),
              tooltip: isEnglish ? 'Add New' : 'إضافة جديد',
            )
          : null,
    );
  }

  Widget _buildHomePage(BuildContext context, LanguageProvider languageProvider, FamilyProvider familyProvider) {
    bool isEnglish = languageProvider.isEnglish;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // بطاقة الترحيب
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).primaryColor.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Text(
                  isEnglish ? 'Welcome to' : 'مرحباً بك في',
                  style: GoogleFonts.cairo(
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'DrugDoZer',
                  style: GoogleFonts.cairo(
                    fontSize: 28,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
  'نص بالعربية',
  style: GoogleFonts.cairo(
    fontSize: 14,
    color: Colors.grey[600],
  ),
  textAlign: TextAlign.center, // هنا خارج style
),

              ],
            ),
          ),
          
          const SizedBox(height: 30),
          
          // بطاقات الخيارات الرئيسية
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            children: [
              // بطاقة البحث عن دواء
              _buildHomeCard(
                context: context,
                icon: Icons.search,
                title: isEnglish ? 'Search Medicine' : 'بحث عن دواء',
                subtitle: isEnglish 
                    ? 'Search for any medicine and record its doses'
                    : 'ابحث عن أي دواء وسجل جرعاته',
                color: Colors.blue,
                onTap: () {
                  setState(() {
                    _selectedIndex = 1;
                  });
                },
              ),
              
              // بطاقة التذكيرات
              _buildHomeCard(
                context: context,
                icon: Icons.notifications_active,
                title: isEnglish ? 'Dose Reminders' : 'تذكير بالجرعات',
                subtitle: isEnglish 
                    ? "Don't forget your dose times"
                    : 'لا تنسى مواعيد جرعاتك',
                color: Colors.orange,
                onTap: () {
                  setState(() {
                    _selectedIndex = 2;
                  });
                },
              ),
              
              // بطاقة ملف العائلة
              _buildHomeCard(
                context: context,
                icon: Icons.family_restroom,
                title: isEnglish ? 'Family File' : 'ملف العائلة',
                subtitle: isEnglish 
                    ? 'Manage family medical records'
                    : 'إدارة الملف الطبي للعائلة',
                color: Colors.green,
                onTap: () {
                  setState(() {
                    _selectedIndex = 3;
                  });
                },
              ),
              
              // بطاقة الإعدادات
              _buildHomeCard(
                context: context,
                icon: Icons.settings,
                title: isEnglish ? 'Settings' : 'الإعدادات',
                subtitle: isEnglish 
                    ? 'Customize the app according to your needs'
                    : 'تخصيص التطبيق حسب احتياجاتك',
                color: Colors.purple,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SettingsScreen()),
                  );
                },
              ),
            ],
          ),
          
          const SizedBox(height: 30),
          
          // قسم ملف العائلة السريع
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isEnglish ? 'Quick Family File' : 'ملف العائلة السريع',
                      style: GoogleFonts.cairo(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _selectedIndex = 3;
                        });
                      },
                      child: Text(isEnglish ? 'View All' : 'عرض الكل'),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                
                if (familyProvider.familyMembers.isEmpty)
                  Center(
                    child: Column(
                      children: [
                        Icon(Icons.group, size: 50, color: Colors.grey[300]),
                        const SizedBox(height: 10),
                        Text(
                          isEnglish 
                              ? 'No family members added'
                              : 'لا يوجد أفراد في العائلة',
                          style: GoogleFonts.cairo(color: Colors.grey),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () => _showAddFamilyMemberDialog(context, familyProvider),
                          child: Text(isEnglish ? 'Add New' : 'إضافة جديد'),
                        ),
                      ],
                    ),
                  )
                else
                  Column(
                    children: familyProvider.familyMembers.take(2).map((member) {
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(context).primaryColor,
                          child: Text(
                            member.name.substring(0, 1),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(member.name),
                        subtitle: Text('${member.relationship} - ${member.age} ${isEnglish ? 'years' : 'سنة'}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.arrow_forward_ios, size: 16),
                          onPressed: () {
                            // ستحتاج إلى إنشاء FamilyMemberDetailsScreen
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //     builder: (context) => FamilyMemberDetailsScreen(member: member),
                            //   ),
                            // );
                          },
                        ),
                      );
                    }).toList(),
                  ),
              ],
            ),
          ),
          
          const SizedBox(height: 30),
          
          // قسم الأدوية السريع
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isEnglish ? 'Quick Search' : 'بحث سريع',
                      style: GoogleFonts.cairo(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _selectedIndex = 1;
                        });
                      },
                      child: Text(isEnglish ? 'Search' : 'بحث'),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                
                FutureBuilder<List<Drug>>(
                  future: _drugRepository.getAllDrugs(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    
                    if (snapshot.hasError || snapshot.data == null) {
                      return Center(
                        child: Text(
                          isEnglish ? 'Error loading medications' : 'خطأ في تحميل الأدوية',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      );
                    }
                    
                    final drugs = snapshot.data!.take(3).toList();
                    
                    return Column(
                      children: drugs.map((drug) {
                        return ListTile(
                          leading: Icon(_getDrugIcon(drug.type)),
                          title: Text(isEnglish ? drug.englishName : drug.arabicName),
                          subtitle: Text(drug.category),
                          trailing: const Icon(Icons.chevron_left, size: 16),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DetailsScreen(drug: drug),
                              ),
                            );
                          },
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHomeCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 30),
              ),
              const SizedBox(height: 15),
              Text(
                title,
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 5),
              Text(
                subtitle,
                style: GoogleFonts.cairo(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMedicationsPage(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    bool isEnglish = languageProvider.isEnglish;
    
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SearchScreen()),
                    );
                  },
                  icon: const Icon(Icons.search),
                  label: Text(isEnglish ? 'Search Medicine' : 'بحث عن دواء'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ),
            ],
          ),
        ),
        
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            isEnglish ? 'Recent Medications' : 'الأدوية الأخيرة',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        
        Expanded(
          child: FutureBuilder<List<Drug>>(
            future: _drugRepository.getAllDrugs(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    isEnglish ? 'Error: ${snapshot.error}' : 'خطأ: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              }
              
              final drugs = snapshot.data ?? [];
              final recentDrugs = drugs.take(10).toList();
              
              if (recentDrugs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.medication, size: 80, color: Colors.grey[300]),
                      const SizedBox(height: 20),
                      Text(
                        isEnglish ? 'No medications found' : 'لم يتم العثور على أدوية',
                        style: const TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }
              
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: recentDrugs.length,
                itemBuilder: (context, index) {
                  final drug = recentDrugs[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      leading: Icon(_getDrugIcon(drug.type)),
                      title: Text(isEnglish ? drug.englishName : drug.arabicName),
                      subtitle: Text(drug.category),
                      trailing: const Icon(Icons.chevron_left),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailsScreen(drug: drug),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _showAddFamilyMemberDialog(BuildContext context, FamilyProvider familyProvider) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    bool isEnglish = languageProvider.isEnglish;
    
    final nameController = TextEditingController();
    final ageController = TextEditingController();
    String relationship = isEnglish ? 'Father' : 'الأب';
    final List<String> relationships = isEnglish
        ? ['Father', 'Mother', 'Son', 'Daughter', 'Grandfather', 'Grandmother', 'Other']
        : ['الأب', 'الأم', 'الابن', 'الابنة', 'الجد', 'الجدة', 'آخر'];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEnglish ? 'Add New Family Member' : 'إضافة فرد جديد'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: isEnglish ? 'Full Name' : 'الاسم الكامل',
                  ),
                ),
                TextField(
                  controller: ageController,
                  decoration: InputDecoration(
                    labelText: isEnglish ? 'Age' : 'العمر',
                  ),
                  keyboardType: TextInputType.number,
                ),
                DropdownButtonFormField<String>(
                  value: relationship,
                  items: relationships.map((rel) {
                    return DropdownMenuItem(
                      value: rel,
                      child: Text(rel),
                    );
                  }).toList(),
                  onChanged: (value) {
                    relationship = value!;
                  },
                  decoration: InputDecoration(
                    labelText: isEnglish ? 'Relationship' : 'القرابة',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(isEnglish ? 'Cancel' : 'إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(isEnglish ? 'Please enter a name' : 'يرجى إدخال الاسم'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                
                final newMember = FamilyMember(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: nameController.text,
                  age: int.tryParse(ageController.text) ?? 0,
                  relationship: relationship,
                );
                familyProvider.addMember(newMember);
                Navigator.pop(context);
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isEnglish 
                          ? '${nameController.text} added successfully'
                          : 'تمت إضافة ${nameController.text} بنجاح',
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: Text(isEnglish ? 'Add' : 'إضافة'),
            ),
          ],
        );
      },
    );
  }

  IconData _getDrugIcon(DrugType type) {
    switch (type) {
      case DrugType.syrup: return Icons.water_drop;
      case DrugType.tablet: return Icons.medication;
      case DrugType.cream: return Icons.healing;
      case DrugType.spray: return Icons.air;
      case DrugType.drops: return Icons.water_drop_outlined;
      case DrugType.injection: return Icons.medication_liquid;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}