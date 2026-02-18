import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/scan_record.dart';

class FirestoreService {
  FirestoreService._();
  static final FirestoreService instance = FirestoreService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveScan(ScanRecord record) async {
    await _firestore.collection('food_scans').add({
      'foodName': record.foodName,
      'status': record.freshnessStatus,
      'confidence': record.confidence,
      'time': record.dateTime.toIso8601String(),
      'imageUrl': record.imagePath,
    });
  }
}
