import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';

import '../../domain/entities/drug.dart';
import '../../domain/entities/drug_type.dart';
import '../../core/utils/dose_calculator.dart';
import 'add_reminder_screen.dart';

class DetailsScreen extends StatefulWidget {
  final Drug drug;
  const DetailsScreen({super.key, required this.drug});

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  final _weightController = TextEditingController();
  final _calculator = DoseCalculator();
  String _resultText = "";
  bool _hasResult = false;

  void _showAddReminderDialog(BuildContext context) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddReminderScreen(
          initialDrugName: widget.drug.name,
          initialDrugType: widget.drug.type.name,
        ),
      ),
    );
  }

  void _calculateDose() {
    final weight = double.tryParse(_weightController.text);
    if (weight == null || weight <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("يرجى إدخال وزن صحيح")),
      );
      return;
    }
    
    // تحقق من أن الدواء من النوع الذي له جرعة محسوبة
    if (widget.drug.concentrationMg == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("هذا الدواء له جرعة ثابتة")),
      );
      return;
    }
    
    final min = _calculator.calculateMinDoseMl(weight, widget.drug);
    final max = _calculator.calculateMaxDoseMl(weight, widget.drug);
    
    setState(() {
      _resultText = "الجرعة: ${min.toStringAsFixed(1)} - ${max.toStringAsFixed(1)} مل";
      _hasResult = true;
    });
    FocusScope.of(context).unfocus(); 
  }

  void _shareDosage() {
    if (!_hasResult || _weightController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("يرجى حساب الجرعة أولاً")),
      );
      return;
    }
    
    final String message = "💊 تطبيق DrugDoZer\n"
        "--------------------------\n"
        "📌 الدواء: ${widget.drug.name}\n"
        "👶 الوزن: ${_weightController.text} كجم\n"
        "✅ $_resultText\n"
        "📝 ${widget.drug.howToUse}\n"
        "⚠️ ${widget.drug.warning}\n"
        "--------------------------\n"
        "تمنياتنا بالشفاء العاجل! ❤️";
    Share.share(message, subject: 'جرعة دواء ${widget.drug.name}');
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.drug.name, style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : const Color(0xFF00695C),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // زر إضافة المنبه
            ElevatedButton.icon(
              onPressed: () => _showAddReminderDialog(context),
              icon: const Icon(Icons.alarm_add, color: Colors.white),
              label: Text("إضافة منبه لهذا الدواء", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 20),

            // بطاقة وصف الدواء
            _buildCard(
              icon: Icons.description,
              title: "وصف الدواء",
              body: widget.drug.description,
            ),
            const SizedBox(height: 20),
            
            // بطاقة طريقة الاستخدام
            _buildCard(
              icon: Icons.medical_services,
              title: "طريقة الاستخدام",
              body: widget.drug.howToUse,
            ),
            const SizedBox(height: 20),
            
            // إظهار حاسبة الجرعة أو معلومات الجرعة الثابتة
            if (widget.drug.type == DrugType.syrup && widget.drug.concentrationMg > 0) 
              _buildSyrupCalculator(isDark) 
            else 
              _buildFixedDoseInfo(),
            
            const SizedBox(height: 20),
            
            // بطاقة التحذيرات
            _buildWarningCard(),
            
            const SizedBox(height: 20),
            
            // معلومات إضافية
            _buildInfoCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({required IconData icon, required String title, required String body}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.teal),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.teal,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              body,
              style: GoogleFonts.cairo(fontSize: 14, height: 1.5),
              textAlign: TextAlign.right,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSyrupCalculator(bool isDark) {
    return Card(
      elevation: 2,
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
                Icon(Icons.calculate, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  "حاسبة الجرعة بالوزن",
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            
            Text(
              "معلومات التركيز:",
              style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(
              "${widget.drug.concentrationMg} مجم في كل ${widget.drug.concentrationMl} مل",
              style: GoogleFonts.cairo(),
            ),
            const SizedBox(height: 10),
            
            Text(
              "نطاق الجرعة:",
              style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(
              "${widget.drug.minDosePerKg} - ${widget.drug.maxDosePerKg} مجم لكل كجم من الوزن",
              style: GoogleFonts.cairo(),
            ),
            const SizedBox(height: 20),
            
            TextField(
              controller: _weightController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "وزن الطفل (كجم)",
                hintText: "أدخل الوزن بالكيلوجرام",
                prefixIcon: const Icon(Icons.scale),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                filled: true,
                fillColor: isDark ? Colors.grey[800] : Colors.grey[50],
              ),
            ),
            const SizedBox(height: 15),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _calculateDose,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  "احسب الجرعة",
                  style: GoogleFonts.cairo(fontSize: 16),
                ),
              ),
            ),
            
            if (_hasResult) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.teal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.teal),
                ),
                child: Column(
                  children: [
                    Text(
                      _resultText,
                      style: GoogleFonts.cairo(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "كل ${widget.drug.howToUse.contains('6') ? '6' : widget.drug.howToUse.contains('8') ? '8' : '12'} ساعات",
                      style: GoogleFonts.cairo(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: _shareDosage,
                icon: const Icon(Icons.share),
                label: Text(
                  "مشاركة النتيجة",
                  style: GoogleFonts.cairo(),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildFixedDoseInfo() {
    return Card(
      elevation: 2,
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
                Icon(Icons.medication, color: Colors.purple),
                const SizedBox(width: 8),
                Text(
                  "معلومات الجرعة",
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.purple,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            if (widget.drug.fixedDose != null && widget.drug.fixedDose!.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "الجرعة المحددة:",
                    style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    widget.drug.fixedDose!,
                    style: GoogleFonts.cairo(fontSize: 14),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            
            Text(
              "نوع الدواء:",
              style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                Icon(_getTypeIcon(widget.drug.type), size: 16, color: Colors.grey[600]),
                const SizedBox(width: 5),
                Text(
                  widget.drug.type.arabicName,
                  style: GoogleFonts.cairo(fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 10),
            
            Text(
              "التصنيف:",
              style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(
              widget.drug.category,
              style: GoogleFonts.cairo(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWarningCard() {
    return Card(
      elevation: 2,
      color: Colors.red.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: Colors.red.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning, color: Colors.red),
                const SizedBox(width: 8),
                Text(
                  "تحذيرات هامة",
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              widget.drug.warning,
              style: GoogleFonts.cairo(
                fontSize: 14,
                color: Colors.red[700],
                height: 1.5,
              ),
              textAlign: TextAlign.right,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      elevation: 2,
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
                Icon(Icons.info_outline, color: Colors.blueGrey),
                const SizedBox(width: 8),
                Text(
                  "معلومات إضافية",
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.blueGrey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "الاسم الإنجليزي:",
                        style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                      Text(
                        widget.drug.englishName,
                        style: GoogleFonts.cairo(fontSize: 14),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "معرف الدواء:",
                        style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                      Text(
                        widget.drug.id,
                        style: GoogleFonts.cairo(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getTypeIcon(DrugType type) {
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
    _weightController.dispose();
    super.dispose();
  }
}