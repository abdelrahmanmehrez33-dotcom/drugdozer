import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'di/service_locator.dart';
import 'core/theme/theme_provider.dart';
import 'core/providers/language_provider.dart';
import 'core/providers/family_provider.dart';
import 'data/datasources/local_reminders.dart';
import 'presentation/screens/welcome_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  setupServiceLocator();
  
  // تحميل التذكيرات المحفوظة
  await ReminderService().loadReminders();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => LanguageProvider()),
        ChangeNotifierProvider(create: (context) => FamilyProvider()),
      ],
      child: const DrugDozerApp(),
    ),
  );
}

class DrugDozerApp extends StatelessWidget {
  const DrugDozerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer3<ThemeProvider, LanguageProvider, FamilyProvider>(
      builder: (context, themeProvider, languageProvider, familyProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'DrugDoZer',
          theme: themeProvider.getLightTheme(),
          darkTheme: themeProvider.getDarkTheme(),
          themeMode: themeProvider.themeMode,
          home: const WelcomeScreen(),
        );
      },
    );
  }
}