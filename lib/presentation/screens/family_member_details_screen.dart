import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/providers/family_provider.dart';

class FamilyMemberDetailsScreen extends StatelessWidget {
  final FamilyMember member;
  
  const FamilyMemberDetailsScreen({super.key, required this.member});

  @override
  Widget build(BuildContext context) {
    final familyProvider = Provider.of<FamilyProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(member.name),
        backgroundColor: const Color(0xFF00695C),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              _showEditMemberDialog(context, member, familyProvider);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // معلومات أساسية
            Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: const Color(0xFF00695C),
                          child: Text(
                            member.name.substring(0, 1),
                            style: const TextStyle(
                              fontSize: 24,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                member.name,
                                style: GoogleFonts.cairo(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                '${member.relationship} - ${member.age} سنة',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (member.notes.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'ملاحظات:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            member.notes,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // الأمراض المزمنة
            _buildInfoCard(
              title: 'الأمراض المزمنة',
              items: member.chronicDiseases,
              icon: Icons.sick,
              color: Colors.red,
              onAdd: () {
                _showAddDiseaseDialog(context, member, familyProvider);
              },
              onDelete: (item) {
                familyProvider.removeChronicDisease(member.id, item);
              },
            ),
            
            const SizedBox(height: 20),
            
            // الحساسيات
            _buildInfoCard(
              title: 'الحساسيات',
              items: member.allergies,
              icon: Icons.warning,
              color: Colors.orange,
              onAdd: () {
                _showAddAllergyDialog(context, member, familyProvider);
              },
              onDelete: (item) {
                familyProvider.removeAllergy(member.id, item);
              },
            ),
            
            const SizedBox(height: 20),
            
            // الأدوية
            _buildInfoCard(
              title: 'الأدوية المستخدمة',
              items: member.medications,
              icon: Icons.medication,
              color: Colors.blue,
              onAdd: () {
                _showAddMedicationDialog(context, member, familyProvider);
              },
              onDelete: (item) {
                familyProvider.removeMedication(member.id, item);
              },
            ),
            
            const SizedBox(height: 20),
            
            // المعلومات الطبية الإضافية
            Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'معلومات طبية إضافية',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ListTile(
                      leading: const Icon(Icons.calendar_today),
                      title: const Text('آخر تحديث'),
                      subtitle: Text(
                        '${member.lastUpdated.day}/${member.lastUpdated.month}/${member.lastUpdated.year}',
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.history),
                      title: const Text('عدد الأدوية'),
                      subtitle: Text('${member.medications.length} دواء'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.medical_information),
                      title: const Text('الحالة الصحية'),
                      subtitle: Text(
                        member.chronicDiseases.isEmpty
                            ? 'جيدة'
                            : 'تتطلب متابعة',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (context) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.medication),
                    title: const Text('إضافة دواء جديد'),
                    onTap: () {
                      Navigator.pop(context);
                      _showAddMedicationDialog(context, member, familyProvider);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.warning),
                    title: const Text('إضافة حساسية'),
                    onTap: () {
                      Navigator.pop(context);
                      _showAddAllergyDialog(context, member, familyProvider);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.sick),
                    title: const Text('إضافة مرض مزمن'),
                    onTap: () {
                      Navigator.pop(context);
                      _showAddDiseaseDialog(context, member, familyProvider);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.edit_note),
                    title: const Text('تعديل الملاحظات'),
                    onTap: () {
                      Navigator.pop(context);
                      _showEditNotesDialog(context, member, familyProvider);
                    },
                  ),
                ],
              );
            },
          );
        },
        backgroundColor: const Color(0xFF00695C),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required List<String> items,
    required IconData icon,
    required Color color,
    required VoidCallback onAdd,
    required Function(String) onDelete,
  }) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(icon, color: color),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: onAdd,
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (items.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Text(
                    'لا توجد معلومات',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: items.map((item) {
                  return Chip(
                    label: Text(item),
                    backgroundColor: color.withOpacity(0.1),
                    labelStyle: TextStyle(color: color),
                    deleteIcon: const Icon(Icons.close, size: 16),
                    onDeleted: () {
                      onDelete(item);
                    },
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  void _showAddMedicationDialog(BuildContext context, FamilyMember member, FamilyProvider familyProvider) {
    final medicationController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('إضافة دواء جديد'),
          content: TextField(
            controller: medicationController,
            decoration: const InputDecoration(
              hintText: 'أدخل اسم الدواء',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                if (medicationController.text.isNotEmpty) {
                  familyProvider.addMedication(member.id, medicationController.text);
                  Navigator.pop(context);
                }
              },
              child: const Text('إضافة'),
            ),
          ],
        );
      },
    );
  }

  void _showAddAllergyDialog(BuildContext context, FamilyMember member, FamilyProvider familyProvider) {
    final allergyController = TextEditingController();
    Set<String> selectedAllergies = Set.from(member.allergies);
    
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('إضافة حساسيات'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // الحساسيات الشائعة
                    Text('الحساسيات الشائعة:', 
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: familyProvider.commonAllergies.map((allergy) {
                        return FilterChip(
                          label: Text(allergy),
                          selected: selectedAllergies.contains(allergy),
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                selectedAllergies.add(allergy);
                              } else {
                                selectedAllergies.remove(allergy);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                    
                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 10),
                    
                    // إضافة حساسية جديدة يدويًا
                    TextField(
                      controller: allergyController,
                      decoration: const InputDecoration(
                        labelText: 'إضافة حساسية جديدة',
                        hintText: 'أدخل نوع الحساسية',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        if (allergyController.text.isNotEmpty) {
                          setState(() {
                            selectedAllergies.add(allergyController.text.trim());
                            allergyController.clear();
                          });
                        }
                      },
                      child: const Text('إضافة حساسية جديدة'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('إلغاء'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    // إضافة الحساسيات المختارة
                    for (String allergy in selectedAllergies) {
                      if (!member.allergies.contains(allergy)) {
                        await familyProvider.addAllergy(member.id, allergy);
                      }
                    }
                    
                    // إزالة الحساسيات غير المختارة
                    for (String existingAllergy in member.allergies) {
                      if (!selectedAllergies.contains(existingAllergy)) {
                        await familyProvider.removeAllergy(member.id, existingAllergy);
                      }
                    }
                    
                    Navigator.pop(context);
                  },
                  child: const Text('حفظ'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAddDiseaseDialog(BuildContext context, FamilyMember member, FamilyProvider familyProvider) {
    final diseaseController = TextEditingController();
    Set<String> selectedDiseases = Set.from(member.chronicDiseases);
    
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('إضافة أمراض مزمنة'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // الأمراض الشائعة
                    Text('الأمراض الشائعة:', 
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: familyProvider.commonDiseases.map((disease) {
                        return FilterChip(
                          label: Text(disease),
                          selected: selectedDiseases.contains(disease),
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                selectedDiseases.add(disease);
                              } else {
                                selectedDiseases.remove(disease);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                    
                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 10),
                    
                    // إضافة مرض جديد يدويًا
                    TextField(
                      controller: diseaseController,
                      decoration: const InputDecoration(
                        labelText: 'إضافة مرض جديد',
                        hintText: 'أدخل اسم المرض',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        if (diseaseController.text.isNotEmpty) {
                          setState(() {
                            selectedDiseases.add(diseaseController.text.trim());
                            diseaseController.clear();
                          });
                        }
                      },
                      child: const Text('إضافة مرض جديد'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('إلغاء'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    // إضافة الأمراض المختارة
                    for (String disease in selectedDiseases) {
                      if (!member.chronicDiseases.contains(disease)) {
                        await familyProvider.addChronicDisease(member.id, disease);
                      }
                    }
                    
                    // إزالة الأمراض غير المختارة
                    for (String existingDisease in member.chronicDiseases) {
                      if (!selectedDiseases.contains(existingDisease)) {
                        await familyProvider.removeChronicDisease(member.id, existingDisease);
                      }
                    }
                    
                    Navigator.pop(context);
                  },
                  child: const Text('حفظ'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditNotesDialog(BuildContext context, FamilyMember member, FamilyProvider familyProvider) {
    final notesController = TextEditingController(text: member.notes);
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('تعديل الملاحظات'),
          content: TextField(
            controller: notesController,
            decoration: const InputDecoration(
              hintText: 'أدخل ملاحظات إضافية',
            ),
            maxLines: 5,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                final updatedMember = FamilyMember(
                  id: member.id,
                  name: member.name,
                  age: member.age,
                  relationship: member.relationship,
                  medications: member.medications,
                  chronicDiseases: member.chronicDiseases,
                  allergies: member.allergies,
                  notes: notesController.text,
                );
                familyProvider.updateMember(member.id, updatedMember);
                Navigator.pop(context);
              },
              child: const Text('حفظ'),
            ),
          ],
        );
      },
    );
  }

  void _showEditMemberDialog(BuildContext context, FamilyMember member, FamilyProvider familyProvider) {
    final nameController = TextEditingController(text: member.name);
    final ageController = TextEditingController(text: member.age.toString());
    final notesController = TextEditingController(text: member.notes);
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('تعديل معلومات العضو'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'الاسم'),
                ),
                TextField(
                  controller: ageController,
                  decoration: const InputDecoration(labelText: 'العمر'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(labelText: 'ملاحظات'),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                final updatedMember = FamilyMember(
                  id: member.id,
                  name: nameController.text,
                  age: int.tryParse(ageController.text) ?? member.age,
                  relationship: member.relationship,
                  medications: member.medications,
                  chronicDiseases: member.chronicDiseases,
                  allergies: member.allergies,
                  notes: notesController.text,
                );
                familyProvider.updateMember(member.id, updatedMember);
                Navigator.pop(context);
              },
              child: const Text('حفظ'),
            ),
          ],
        );
      },
    );
  }
}