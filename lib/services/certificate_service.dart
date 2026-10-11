import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class CertificateService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ==================== GENERATE CERTIFICATE PDF ====================
  Future<Uint8List> generateCertificate({
    required String studentName,
    required String studentId,
    required String eventTitle,
    required String eventDate,
    required String organizerName,
    required String certificateType,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        build: (pw.Context context) {
          return pw.Container(
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.blue800, width: 8),
            ),
            padding: const pw.EdgeInsets.all(20),
            child: pw.Container(
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.orange, width: 2),
              ),
              padding: const pw.EdgeInsets.all(30),
              child: pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Text(
                    'CAMPUSCONNECT',
                    style: pw.TextStyle(
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.blue800,
                      letterSpacing: 4,
                    ),
                  ),
                  pw.SizedBox(height: 5),
                  pw.Text(
                    'Riphah International University',
                    style: pw.TextStyle(
                      fontSize: 14,
                      color: PdfColors.grey700,
                    ),
                  ),
                  pw.SizedBox(height: 20),
                  pw.Container(width: 200, height: 3, color: PdfColors.orange),
                  pw.SizedBox(height: 25),
                  pw.Text(
                    'CERTIFICATE',
                    style: pw.TextStyle(
                      fontSize: 48,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.blue900,
                      letterSpacing: 6,
                    ),
                  ),
                  pw.Text(
                    'OF $certificateType',
                    style: pw.TextStyle(
                      fontSize: 18,
                      color: PdfColors.orange,
                      letterSpacing: 4,
                    ),
                  ),
                  pw.SizedBox(height: 30),
                  pw.Text(
                    'This is to certify that',
                    style: pw.TextStyle(
                      fontSize: 16,
                      color: PdfColors.grey700,
                      fontStyle: pw.FontStyle.italic,
                    ),
                  ),
                  pw.SizedBox(height: 10),
                  pw.Text(
                    studentName.toUpperCase(),
                    style: pw.TextStyle(
                      fontSize: 32,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.blue800,
                    ),
                  ),
                  pw.SizedBox(height: 5),
                  pw.Text(
                    'Student ID: $studentId',
                    style: pw.TextStyle(
                      fontSize: 12,
                      color: PdfColors.grey600,
                    ),
                  ),
                  pw.SizedBox(height: 20),
                  pw.Text(
                    'has successfully participated in',
                    style: pw.TextStyle(
                      fontSize: 14,
                      color: PdfColors.grey700,
                    ),
                  ),
                  pw.SizedBox(height: 10),
                  pw.Text(
                    eventTitle,
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(
                      fontSize: 22,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.blue900,
                    ),
                  ),
                  pw.SizedBox(height: 10),
                  pw.Text(
                    'held on $eventDate',
                    style: pw.TextStyle(
                      fontSize: 14,
                      color: PdfColors.grey700,
                    ),
                  ),
                  pw.SizedBox(height: 40),
                  // FIXED: pw.MainAxisAlignment.spaceAround (lowercase)
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                    children: [
                      pw.Column(
                        children: [
                          pw.Container(
                            width: 150,
                            height: 1,
                            color: PdfColors.grey500,
                          ),
                          pw.SizedBox(height: 5),
                          pw.Text(
                            organizerName,
                            style: pw.TextStyle(
                              fontSize: 12,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.Text(
                            'Organizer',
                            style: pw.TextStyle(
                              fontSize: 10,
                              color: PdfColors.grey600,
                            ),
                          ),
                        ],
                      ),
                      pw.Column(
                        children: [
                          pw.Container(
                            width: 150,
                            height: 1,
                            color: PdfColors.grey500,
                          ),
                          pw.SizedBox(height: 5),
                          pw.Text(
                            'University Administration',
                            style: pw.TextStyle(
                              fontSize: 12,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.Text(
                            'Authorized Signatory',
                            style: pw.TextStyle(
                              fontSize: 10,
                              color: PdfColors.grey600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 20),
                  pw.Text(
                    'Certificate ID: ${DateTime.now().millisecondsSinceEpoch}',
                    style: pw.TextStyle(
                      fontSize: 8,
                      color: PdfColors.grey500,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );

    return pdf.save();
  }

  // ==================== PRINT / SHARE CERTIFICATE ====================
  Future<void> printCertificate({
    required String studentName,
    required String studentId,
    required String eventTitle,
    required String eventDate,
    required String organizerName,
    required String certificateType,
  }) async {
    final pdfBytes = await generateCertificate(
      studentName: studentName,
      studentId: studentId,
      eventTitle: eventTitle,
      eventDate: eventDate,
      organizerName: organizerName,
      certificateType: certificateType,
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes,
      name: 'Certificate_$eventTitle',
    );
  }

  // ==================== SHARE CERTIFICATE ====================
  Future<void> shareCertificate({
    required String studentName,
    required String studentId,
    required String eventTitle,
    required String eventDate,
    required String organizerName,
    required String certificateType,
  }) async {
    final pdfBytes = await generateCertificate(
      studentName: studentName,
      studentId: studentId,
      eventTitle: eventTitle,
      eventDate: eventDate,
      organizerName: organizerName,
      certificateType: certificateType,
    );

    await Printing.sharePdf(
      bytes: pdfBytes,
      filename: 'Certificate_${eventTitle.replaceAll(' ', '_')}.pdf',
    );
  }

  // ==================== GET STUDENT CERTIFICATES ====================
  Future<List<Map<String, dynamic>>> getStudentCertificates(
      String userId) async {
    try {
      final snapshot = await _firestore
          .collection('certificates')
          .where('userId', isEqualTo: userId)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      // FIXED: debugPrint instead of print
      debugPrint('Error getting certificates: $e');
      return [];
    }
  }
}