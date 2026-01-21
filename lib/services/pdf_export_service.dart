import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../core/providers/family_provider.dart';

class PdfExportService {
  static Future<void> exportFamilyToPdf(List<FamilyMember> members, String fileName) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            children: [
              pw.Header(
                level: 0,
                child: pw.Text('ملف العائلة الطبي - DrugDoZer',
                    style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              ),
              pw.SizedBox(height: 10),
              pw.Text('تاريخ التصدير: ${DateTime.now().toString().split(' ')[0]}',
                  style: pw.TextStyle(fontSize: 12)),
              pw.SizedBox(height: 20),
              ...members.map((member) => _buildMemberCard(member)).toList(),
            ],
          );
        },
      ),
    );

    await Printing.sharePdf(bytes: await pdf.save(), filename: '$fileName.pdf');
  }

  static pw.Widget _buildMemberCard(FamilyMember member) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 20),
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(10),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            children: [
              pw.Container(
                width: 40,
                height: 40,
                decoration: pw.BoxDecoration(
                  color: PdfColors.blue100,
                  shape: pw.BoxShape.circle,
                ),
                child: pw.Center(
                  child: pw.Text(
                    member.name.substring(0, 1),
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.blue800,
                    ),
                  ),
                ),
              ),
              pw.SizedBox(width: 15),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('الاسم: ${member.name}',
                      style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                  pw.Text('العمر: ${member.age} سنة - صلة القرابة: ${member.relationship}',
                      style: pw.TextStyle(fontSize: 12)),
                ],
              ),
            ],
          ),
          
          pw.SizedBox(height: 15),
          
          if (member.chronicDiseases.isNotEmpty)
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('الأمراض المزمنة:', 
                    style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 5),
                pw.Text(member.chronicDiseases.join('، '),
                    style: pw.TextStyle(fontSize: 12)),
                pw.SizedBox(height: 10),
              ],
            ),
          
          if (member.allergies.isNotEmpty)
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('الحساسيات:', 
                    style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 5),
                pw.Text(member.allergies.join('، '),
                    style: pw.TextStyle(fontSize: 12)),
                pw.SizedBox(height: 10),
              ],
            ),
          
          if (member.medications.isNotEmpty)
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('الأدوية المستخدمة:', 
                    style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 5),
                pw.Text(member.medications.join('، '),
                    style: pw.TextStyle(fontSize: 12)),
                pw.SizedBox(height: 10),
              ],
            ),
          
          if (member.notes.isNotEmpty)
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('ملاحظات:', 
                    style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 5),
                pw.Text(member.notes,
                    style: pw.TextStyle(fontSize: 12)),
              ],
            ),
          
          pw.SizedBox(height: 10),
          pw.Divider(),
          pw.Text('آخر تحديث: ${member.lastUpdated.toString().split(' ')[0]}',
              style: pw.TextStyle(fontSize: 10, color: PdfColors.grey)),
        ],
      ),
    );
  }
}