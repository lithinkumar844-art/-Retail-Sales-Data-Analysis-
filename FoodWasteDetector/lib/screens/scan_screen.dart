import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/scan_record.dart';
import '../services/database_helper.dart';
import '../services/firestore_service.dart';
import '../services/notification_service.dart';
import '../services/tflite_service.dart';
import 'result_screen.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _image;
  bool _busy = false;

  Future<void> _captureAndPredict() async {
    final file = await _picker.pickImage(source: ImageSource.camera);
    if (file == null) return;

    setState(() {
      _busy = true;
      _image = File(file.path);
    });

    try {
      final result = await TfliteService.instance.predict(_image!);
      final record = ScanRecord(
        foodName: result.foodName,
        freshnessStatus: result.freshnessStatus,
        confidence: result.confidence,
        imagePath: _image!.path,
        dateTime: DateTime.now(),
      );

      await DatabaseHelper.instance.insertScan(record);

      // Optional Firestore save (works when Firebase is configured)
      try {
        await FirestoreService.instance.saveScan(record);
      } catch (_) {}

      if (result.freshnessStatus == 'Rotten') {
        await NotificationService.showSpoilageAlert(result.foodName);
      } else {
        await NotificationService.scheduleExpiryReminder(result.foodName);
      }

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(image: _image!, result: result),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Food')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white10,
                ),
                child: _image == null
                    ? const Center(child: Text('No image captured yet.'))
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(_image!, fit: BoxFit.cover),
                      ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _busy ? null : _captureAndPredict,
              icon: const Icon(Icons.camera_alt),
              label: Text(_busy ? 'Processing...' : 'Capture & Predict'),
            ),
          ],
        ),
      ),
    );
  }
}
