import 'package:flutter/material.dart';
import '../../services/shared_prefs_service.dart';

class FamilyMember {
  final String id;
  String name;
  int age;
  String relationship;
  List<String> medications;
  List<String> chronicDiseases;
  List<String> allergies;
  String notes;
  DateTime lastUpdated;

  FamilyMember({
    required this.id,
    required this.name,
    required this.age,
    required this.relationship,
    this.medications = const [],
    this.chronicDiseases = const [],
    this.allergies = const [],
    this.notes = '',
    DateTime? lastUpdated,
  }) : lastUpdated = lastUpdated ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'relationship': relationship,
      'medications': medications,
      'chronicDiseases': chronicDiseases,
      'allergies': allergies,
      'notes': notes,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory FamilyMember.fromMap(Map<String, dynamic> map) {
    return FamilyMember(
      id: map['id'],
      name: map['name'],
      age: map['age'],
      relationship: map['relationship'],
      medications: List<String>.from(map['medications']),
      chronicDiseases: List<String>.from(map['chronicDiseases']),
      allergies: List<String>.from(map['allergies']),
      notes: map['notes'],
      lastUpdated: DateTime.parse(map['lastUpdated']),
    );
  }
}

class FamilyProvider extends ChangeNotifier {
  List<FamilyMember> _familyMembers = [];
  final SharedPrefsService _prefsService = SharedPrefsService();
  
  // قوائم الأمراض والحساسيات الشائعة
  List<String> commonDiseases = [
    'ضغط الدم',
    'السكري',
    'الربو',
    'أمراض القلب',
    'أمراض الكلى',
    'أمراض الكبد',
    'الغدة الدرقية',
    'الروماتيزم',
    'الصرع',
    'السرطان',
    'الزهايمر',
    'باركنسون',
    'هشاشة العظام',
    'النقرس',
    'الكوليسترول',
    'النقرس',
  ];

  List<String> commonAllergies = [
    'البنسلين',
    'الأسبرين',
    'المسكنات',
    'المضادات الحيوية',
    'اللبن',
    'البيض',
    'المكسرات',
    'الأسماك',
    'الغبار',
    'حبوب اللقاح',
    'الحيوانات الأليفة',
    'العفن',
    'اللاتكس',
    'النيكل',
    'الصويا',
    'القمح',
  ];

  FamilyProvider() {
    _loadFamilyMembers();
  }

  Future<void> _loadFamilyMembers() async {
    _familyMembers = await _prefsService.loadFamilyMembers();
    if (_familyMembers.isEmpty) {
      // بيانات افتراضية
      _familyMembers = [
        FamilyMember(
          id: '1',
          name: 'أحمد',
          age: 35,
          relationship: 'الأب',
          medications: ['أدول', 'بانادول'],
          chronicDiseases: ['ضغط الدم'],
          allergies: ['الأسبرين'],
          notes: 'يأخذ دواء الضغط يومياً',
        ),
        FamilyMember(
          id: '2',
          name: 'سارة',
          age: 8,
          relationship: 'الابنة',
          medications: ['فيفادول', 'بروسبان'],
          chronicDiseases: [],
          allergies: ['البنسلين'],
          notes: 'حساسية من البنسلين',
        ),
      ];
      await _saveFamilyMembers();
    }
    notifyListeners();
  }

  Future<void> _saveFamilyMembers() async {
    await _prefsService.saveFamilyMembers(_familyMembers);
  }

  List<FamilyMember> get familyMembers => _familyMembers;

  Future<void> addMember(FamilyMember member) async {
    _familyMembers.add(member);
    await _saveFamilyMembers();
    notifyListeners();
  }

  Future<void> updateMember(String id, FamilyMember updatedMember) async {
    final index = _familyMembers.indexWhere((member) => member.id == id);
    if (index != -1) {
      _familyMembers[index] = updatedMember;
      await _saveFamilyMembers();
      notifyListeners();
    }
  }

  Future<void> removeMember(String id) async {
    _familyMembers.removeWhere((member) => member.id == id);
    await _saveFamilyMembers();
    notifyListeners();
  }

  List<FamilyMember> getMembersByRelationship(String relationship) {
    return _familyMembers.where((member) => member.relationship == relationship).toList();
  }

  Future<void> addMedication(String memberId, String medication) async {
    final member = _familyMembers.firstWhere((m) => m.id == memberId);
    if (!member.medications.contains(medication)) {
      member.medications.add(medication);
      member.lastUpdated = DateTime.now();
      await _saveFamilyMembers();
      notifyListeners();
    }
  }

  Future<void> removeMedication(String memberId, String medication) async {
    final member = _familyMembers.firstWhere((m) => m.id == memberId);
    member.medications.remove(medication);
    member.lastUpdated = DateTime.now();
    await _saveFamilyMembers();
    notifyListeners();
  }

  Future<void> addAllergy(String memberId, String allergy) async {
    final member = _familyMembers.firstWhere((m) => m.id == memberId);
    if (!member.allergies.contains(allergy)) {
      member.allergies.add(allergy);
      member.lastUpdated = DateTime.now();
      await _saveFamilyMembers();
      notifyListeners();
    }
  }

  Future<void> removeAllergy(String memberId, String allergy) async {
    final member = _familyMembers.firstWhere((m) => m.id == memberId);
    member.allergies.remove(allergy);
    member.lastUpdated = DateTime.now();
    await _saveFamilyMembers();
    notifyListeners();
  }

  Future<void> addChronicDisease(String memberId, String disease) async {
    final member = _familyMembers.firstWhere((m) => m.id == memberId);
    if (!member.chronicDiseases.contains(disease)) {
      member.chronicDiseases.add(disease);
      member.lastUpdated = DateTime.now();
      await _saveFamilyMembers();
      notifyListeners();
    }
  }

  Future<void> removeChronicDisease(String memberId, String disease) async {
    final member = _familyMembers.firstWhere((m) => m.id == memberId);
    member.chronicDiseases.remove(disease);
    member.lastUpdated = DateTime.now();
    await _saveFamilyMembers();
    notifyListeners();
  }
}