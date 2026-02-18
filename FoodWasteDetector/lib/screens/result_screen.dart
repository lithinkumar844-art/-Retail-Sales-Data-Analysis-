import 'dart:io';

import 'package:flutter/material.dart';

import '../services/tflite_service.dart';

class ResultScreen extends StatelessWidget {
  final File image;
  final InferenceResult result;

  const ResultScreen({super.key, required this.image, required this.result});

  @override
  Widget build(BuildContext context) {
    final confidencePct = (result.confidence * 100).toStringAsFixed(1);

    return Scaffold(
      appBar: AppBar(title: const Text('Prediction Result')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(image, height: 240, fit: BoxFit.cover),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Food: ${result.foodName}', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text('Status: ${result.freshnessStatus}'),
                    const SizedBox(height: 8),
                    Text('Confidence: $confidencePct%'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                title: const Text('Recommendation'),
                subtitle: Text(result.recommendation),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
