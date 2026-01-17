import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:calculator_vault/services/forensic_service.dart';

class PanicService {
  final AudioRecorder _audioRecorder = AudioRecorder();
  final ForensicService _forensicService = ForensicService();

  Future<void> triggerPanic({
    required BuildContext context,
    required Function(String) onStatusChange,
    required Function(bool) onRecordingStateChange,
  }) async {
    try {
      onStatusChange("Initializing Panic Mode...");
      onRecordingStateChange(true);

      // 1. Permissions
      Map<Permission, PermissionStatus> statuses = await [
        Permission.location,
        Permission.microphone,
      ].request();

      if (statuses.values.any((status) => status.isDenied)) {
        onStatusChange("Permissions Denied!");
        onRecordingStateChange(false);
        return;
      }

      // 2. Load Contacts
      final prefs = await SharedPreferences.getInstance();
      List<String> contacts = prefs.getStringList('contacts') ?? [];
      
      // 3. Get Location
      onStatusChange("Acquiring GPS Location...");
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      String mapsLink = "https://www.google.com/maps/search/?api=1&query=${position.latitude},${position.longitude}";

      // 4. Start Recording
      onStatusChange("Recording Audio (10s)...");
      final Directory appDir = await getApplicationDocumentsDirectory();
      String audioPath = '${appDir.path}/panic_audio.m4a';
      File audioFile = File(audioPath);
      
      if (await audioFile.exists()) {
        await audioFile.delete();
      }

      if (await _audioRecorder.hasPermission()) {
        await _audioRecorder.start(const RecordConfig(), path: audioPath);
        
        // Wait 10 seconds
        await Future.delayed(const Duration(seconds: 10));
        
        await _audioRecorder.stop();
        onStatusChange("Generating Forensic Evidence...");

        // 5. Forensic Processing (Hash + PDF)
        String fileHash = await _forensicService.computeFileHash(audioFile);
        String pdfPath = await _forensicService.generateEvidenceReport(
          audioFile: audioFile,
          hash: fileHash,
          location: "${position.latitude}, ${position.longitude}",
        );

        onStatusChange("Evidence Secured. Sharing...");

        // 6. Share (Audio + PDF)
        String contactList = contacts.map((c) => c.split(':')[0]).join(', ');
        String message = "SOS! I need help!\nMy Location: $mapsLink\n\nSent to: $contactList\n\nEvidence Attached (Audio + Forensic Report).";
        
        await Share.shareXFiles(
          [XFile(audioPath), XFile(pdfPath)],
          text: message,
        );

        onStatusChange("Alert Sent!");
      }
    } catch (e) {
      onStatusChange("Error: $e");
    } finally {
      onRecordingStateChange(false);
    }
  }
}
