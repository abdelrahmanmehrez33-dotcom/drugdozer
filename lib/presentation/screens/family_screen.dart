import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/providers/family_provider.dart';
import '../../services/pdf_export_service.dart';
import 'family_member_details_screen.dart';

class FamilyScreen extends StatelessWidget {
  final FamilyProvider familyProvider;
  
  const FamilyScreen({super.key, required this.familyProvider});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ملف العائلة'),
        backgroundColor: const Color(0xFF00695C),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () async {
              if (familyProvider.familyMembers.isNotEmpty) {
                await PdfExportService.exportFamilyToPdf(
                  familyProvider.familyMembers,
                  'ملف_العائلة_الطبي',
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('لا يوجد أفراد لعرضهم في ملف PDF'),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            },
            tooltip: 'تصدير إلى PDF',
          ),
        ],
      ),
      body: familyProvider.familyMembers.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.group, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 20),
                  const Text(
                    'لا يوجد أفراد في العائلة',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'أضف أفراد عائلتك لإدارة ملفاتهم الطبية',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => _showAddFamilyMemberDialog(context, familyProvider),
                    child: const Text('إضافة فرد جديد'),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: familyProvider.familyMembers.length,
              itemBuilder: (context, index) {
                final member = familyProvider.familyMembers[index];
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 15),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFF00695C),
                      child: Text(
                        member.name.substring(0, 1),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(
                      member.name,
                      style: GoogleFonts.cairo(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${member.relationship} - ${member.age} سنة'),
                        if (member.chronicDiseases.isNotEmpty)
                          Text(
                            'أمراض مزمنة: ${member.chronicDiseases.join(', ')}',
                            style: const TextStyle(color: Colors.red, fontSize: 12),
                          ),
                        if (member.allergies.isNotEmpty)
                          Text(
                            'حساسيات: ${member.allergies.join(', ')}',
                            style: const TextStyle(color: Colors.orange, fontSize: 12),
                          ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.more_vert),
                      onPressed: () => _showMemberOptions(context, member, familyProvider),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FamilyMemberDetailsScreen(member: member),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddFamilyMemberDialog(context, familyProvider),
        backgroundColor: const Color(0xFF00695C),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddFamilyMemberDialog(BuildContext context, FamilyProvider familyProvider) {
    final nameController = TextEditingController();
    final ageController = TextEditingController();
    final notesController = TextEditingController();
    String relationship = 'الأب';
    final List<String> relationships = ['الأب', 'الأم', 'الابن', 'الابنة', 'الجد', 'الجدة', 'آخر'];
    final List<String> selectedMedications = [];
    Set<String> selectedAllergies = {};
    Set<String> selectedDiseases = {};

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return SingleChildScrollView(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'إضافة فرد جديد للعائلة',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'الاسم الكامل',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 15),
                    
                    TextField(
                      controller: ageController,
                      decoration: const InputDecoration(
                        labelText: 'العمر',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 15),
                    
                    DropdownButtonFormField<String>(
                      value: relationship,
                      decoration: const InputDecoration(
                        labelText: 'صلة القرابة',
                        border: OutlineInputBorder(),
                      ),
                      items: relationships.map((rel) {
                        return DropdownMenuItem(
                          value: rel,
                          child: Text(rel),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          relationship = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    
                    const Text(
                      'الأمراض المزمنة (اختياري)',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    Wrap(
                      spacing: 8,
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
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            decoration: const InputDecoration(
                              hintText: 'أدخل مرض آخر',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            ),
                            onSubmitted: (value) {
                              if (value.isNotEmpty) {
                                setState(() {
                                  selectedDiseases.add(value.trim());
                                });
                              }
                            },
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () {
                            final controller = TextEditingController();
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('إضافة مرض جديد'),
                                content: TextField(
                                  controller: controller,
                                  decoration: const InputDecoration(hintText: 'اسم المرض'),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('إلغاء'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      if (controller.text.isNotEmpty) {
                                        setState(() {
                                          selectedDiseases.add(controller.text.trim());
                                        });
                                        Navigator.pop(context);
                                      }
                                    },
                                    child: const Text('إضافة'),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    
                    const Text(
                      'الحساسيات (اختياري)',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    Wrap(
                      spacing: 8,
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
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            decoration: const InputDecoration(
                              hintText: 'أدخل حساسية أخرى',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            ),
                            onSubmitted: (value) {
                              if (value.isNotEmpty) {
                                setState(() {
                                  selectedAllergies.add(value.trim());
                                });
                              }
                            },
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () {
                            final controller = TextEditingController();
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('إضافة حساسية جديدة'),
                                content: TextField(
                                  controller: controller,
                                  decoration: const InputDecoration(hintText: 'نوع الحساسية'),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('إلغاء'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      if (controller.text.isNotEmpty) {
                                        setState(() {
                                          selectedAllergies.add(controller.text.trim());
                                        });
                                        Navigator.pop(context);
                                      }
                                    },
                                    child: const Text('إضافة'),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    
                    TextField(
                      controller: notesController,
                      decoration: const InputDecoration(
                        labelText: 'ملاحظات إضافية',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 20),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('إلغاء'),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () {
                            final newMember = FamilyMember(
                              id: DateTime.now().millisecondsSinceEpoch.toString(),
                              name: nameController.text,
                              age: int.tryParse(ageController.text) ?? 0,
                              relationship: relationship,
                              chronicDiseases: selectedDiseases.toList(),
                              allergies: selectedAllergies.toList(),
                              notes: notesController.text,
                            );
                            familyProvider.addMember(newMember);
                            Navigator.pop(context);
                          },
                          child: const Text('إضافة'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showMemberOptions(BuildContext context, FamilyMember member, FamilyProvider familyProvider) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('تعديل المعلومات'),
              onTap: () {
                Navigator.pop(context);
                _showEditMemberDialog(context, member, familyProvider);
              },
            ),
            ListTile(
              leading: const Icon(Icons.medical_services),
              title: const Text('إضافة دواء'),
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
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('حذف', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _showDeleteDialog(context, member, familyProvider);
              },
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

  void _showDeleteDialog(BuildContext context, FamilyMember member, FamilyProvider familyProvider) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('تأكيد الحذف'),
          content: Text('هل أنت متأكد من حذف ${member.name}؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                familyProvider.removeMember(member.id);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('حذف'),
            ),
          ],
        );
      },
    );
  }
}