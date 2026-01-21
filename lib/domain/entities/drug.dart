import 'drug_type.dart';

class Drug {
  final String id;
  final String name;
  final String arabicName;
  final String englishName;
  final String category;
  final DrugType type;
  final double concentrationMg;
  final double concentrationMl;
  final double minDosePerKg;
  final double maxDosePerKg;
  final String description;
  final String warning;
  final String howToUse;
  final String? fixedDose;

  const Drug({
    required this.id,
    required this.name,
    required this.arabicName,
    required this.englishName,
    required this.category,
    required this.type,
    this.concentrationMg = 0.0,
    this.concentrationMl = 0.0,
    this.minDosePerKg = 0.0,
    this.maxDosePerKg = 0.0,
    required this.description,
    required this.warning,
    required this.howToUse,
    this.fixedDose,
  });

  String get searchKey {
    return '$arabicName $englishName $category $description $howToUse ${fixedDose ?? ""}';
  }

  factory Drug.fromMap(Map<String, dynamic> map) {
    return Drug(
      id: map['id'] as String,
      name: map['name'] as String,
      arabicName: map['arabicName'] as String,
      englishName: map['englishName'] as String,
      category: map['category'] as String,
      type: DrugType.values.firstWhere(
        (e) => e.toString() == 'DrugType.${map['type']}',
        orElse: () => DrugType.tablet,
      ),
      concentrationMg: (map['concentrationMg'] as num).toDouble(),
      concentrationMl: (map['concentrationMl'] as num).toDouble(),
      minDosePerKg: (map['minDosePerKg'] as num).toDouble(),
      maxDosePerKg: (map['maxDosePerKg'] as num).toDouble(),
      description: map['description'] as String,
      warning: map['warning'] as String,
      howToUse: map['howToUse'] as String,
      fixedDose: map['fixedDose'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'arabicName': arabicName,
      'englishName': englishName,
      'category': category,
      'type': type.toString().split('.').last,
      'concentrationMg': concentrationMg,
      'concentrationMl': concentrationMl,
      'minDosePerKg': minDosePerKg,
      'maxDosePerKg': maxDosePerKg,
      'description': description,
      'warning': warning,
      'howToUse': howToUse,
      'fixedDose': fixedDose,
    };
  }
}