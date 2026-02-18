import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/scan_record.dart';
import '../services/database_helper.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late Future<List<ScanRecord>> _future;

  @override
  void initState() {
    super.initState();
    _future = DatabaseHelper.instance.getAllScans();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan History')),
      body: FutureBuilder<List<ScanRecord>>(
        future: _future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final scans = snapshot.data!;
          if (scans.isEmpty) {
            return const Center(child: Text('No scans yet.'));
          }

          return ListView.builder(
            itemCount: scans.length,
            itemBuilder: (_, i) {
              final s = scans[i];
              return ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.file(File(s.imagePath), width: 52, height: 52, fit: BoxFit.cover),
                ),
                title: Text('${s.foodName} - ${s.freshnessStatus}'),
                subtitle: Text(
                  '${(s.confidence * 100).toStringAsFixed(1)}% • ${DateFormat.yMMMd().add_jm().format(s.dateTime)}',
                ),
              );
            },
          );
        },
      ),
    );
  }
}
