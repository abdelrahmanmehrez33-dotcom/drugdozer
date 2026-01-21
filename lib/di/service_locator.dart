import 'package:get_it/get_it.dart';
import 'package:drugdozer/domain/repositories/drug_repository.dart';
import 'package:drugdozer/data/repositories/drug_repository_impl.dart';
import 'package:drugdozer/services/notification_service.dart';
import 'package:drugdozer/services/shared_prefs_service.dart';
import 'package:drugdozer/services/pdf_export_service.dart';
import 'package:drugdozer/data/datasources/local_reminders.dart';

final GetIt getIt = GetIt.instance;

void setupServiceLocator() {
  getIt.registerLazySingleton<DrugRepository>(
    () => DrugRepositoryImpl(),
  );
  
  getIt.registerLazySingleton<NotificationService>(
    () => NotificationService(),
  );
  
  getIt.registerLazySingleton<SharedPrefsService>(
    () => SharedPrefsService(),
  );
  
  getIt.registerLazySingleton<PdfExportService>(
    () => PdfExportService(),
  );
  
  getIt.registerLazySingleton<ReminderService>(
    () => ReminderService(),
  );
}