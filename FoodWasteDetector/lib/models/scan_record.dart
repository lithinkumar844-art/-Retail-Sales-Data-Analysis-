class ScanRecord {
  final int? id;
  final String foodName;
  final String freshnessStatus;
  final double confidence;
  final String imagePath;
  final DateTime dateTime;

  ScanRecord({
    this.id,
    required this.foodName,
    required this.freshnessStatus,
    required this.confidence,
    required this.imagePath,
    required this.dateTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'foodName': foodName,
      'freshnessStatus': freshnessStatus,
      'confidence': confidence,
      'imagePath': imagePath,
      'dateTime': dateTime.toIso8601String(),
    };
  }

  factory ScanRecord.fromMap(Map<String, dynamic> map) {
    return ScanRecord(
      id: map['id'] as int?,
      foodName: map['foodName'] as String,
      freshnessStatus: map['freshnessStatus'] as String,
      confidence: (map['confidence'] as num).toDouble(),
      imagePath: map['imagePath'] as String,
      dateTime: DateTime.parse(map['dateTime'] as String),
    );
  }
}
