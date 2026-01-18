import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

class ForensicService {
  
  /// Computes SHA-256 hash of a file
  Future<String> computeFileHash(File file) async {
    if (!await file.exists()) return "File Not Found";
    final bytes = await file.readAsBytes();
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Generates a "Section 65B Certificate" PDF
  Future<String> generateEvidenceReport({
    required File audioFile,
    required String hash,
    required String location,
  }) async {
    final pdf = pw.Document();
    
    // 1. Get Device Info
    final deviceInfo = DeviceInfoPlugin();
    String deviceModel = "Unknown";
    String androidId = "Unknown";
    try {
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        deviceModel = "${androidInfo.brand} ${androidInfo.model}";
        androidId = androidInfo.id;
      }
    } catch (e) {
      deviceModel = "Error: $e";
    }

    // 2. Timestamp
    final now = DateTime.now().toUtc();
    final String timestamp = "${DateFormat('yyyy-MM-dd HH:mm:ss').format(now)} UTC";

    // 3. Build PDF Content
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(
                level: 0,
                child: pw.Text("ELECTRONIC EVIDENCE CERTIFICATE", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 18)),
              ),
              pw.SizedBox(height: 10),
              pw.Text("Under Section 65B of The Bharatiya Sakshya Adhiniyam / Evidence Act", style: const pw.TextStyle(fontSize: 10)),
              pw.Divider(),
              pw.SizedBox(height: 20),
              
              _buildInfoRow("Date & Time (UTC)", timestamp),
              _buildInfoRow("Device Model", deviceModel),
              _buildInfoRow("Device ID (Unique)", androidId),
              _buildInfoRow("GPS Coordinates", location),
              
              pw.SizedBox(height: 20),
              pw.Text("Evidence Details:", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Container(
                decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.black)),
                padding: const pw.EdgeInsets.all(10),
                margin: const pw.EdgeInsets.only(top: 5),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text("File Name: panic_audio.m4a"),
                    pw.Text("File Size: ${audioFile.lengthSync()} bytes"),
                    pw.SizedBox(height: 5),
                    pw.Text("SHA-256 HASH (Integrity Check):", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.Text(hash, style: pw.TextStyle(font: pw.Font.courier(), fontSize: 9)),
                  ],
                ),
              ),

              pw.SizedBox(height: 40),
              pw.Text("Declaration:", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Paragraph(text: "I hereby certify that the computer output (audio recording) containing the information was produced by the computer/device during the period over which the computer was used regularly to store or process information for the purposes of any activities regularly carried on over that period by the person having lawful control over the use of the computer."),
              pw.Paragraph(text: "The information contained in the electronic record reproduces or is derived from such information fed into the computer in the ordinary course of the said activities."),
              pw.Paragraph(text: "Throughout the material part of the said period, the computer was operating properly."),
              
              pw.SizedBox(height: 30),
              pw.Text("Generated Automatically by Safehouse Calculator Vault"),
            ],
          );
        },
      ),
    );

    // 4. Save PDF
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/evidence_report.pdf');
    await file.writeAsBytes(await pdf.save());
    return file.path;
  }

  pw.Widget _buildInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(width: 120, child: pw.Text("$label:", style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
          pw.Expanded(child: pw.Text(value)),
        ],
      ),
    );
  }
}
