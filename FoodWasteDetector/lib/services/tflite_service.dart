import 'dart:io';

import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class InferenceResult {
  final String rawClass;
  final String foodName;
  final String freshnessStatus;
  final double confidence;
  final String recommendation;

  InferenceResult({
    required this.rawClass,
    required this.foodName,
    required this.freshnessStatus,
    required this.confidence,
    required this.recommendation,
  });
}

class TfliteService {
  TfliteService._();
  static final TfliteService instance = TfliteService._();

  Interpreter? _interpreter;
  List<String> _labels = [];

  Future<void> loadModel() async {
    _interpreter ??= await Interpreter.fromAsset('assets/food_freshness_model.tflite');
    _labels = const [
      'FreshApple',
      'FreshBanana',
      'FreshOrange',
      'RottenApple',
      'RottenBanana',
      'RottenOrange',
    ];
  }

  Future<InferenceResult> predict(File imageFile) async {
    await loadModel();

    final image = img.decodeImage(await imageFile.readAsBytes());
    if (image == null) {
      throw Exception('Unable to decode selected image.');
    }

    final resized = img.copyResize(image, width: 224, height: 224);
    final input = List.generate(
      1,
      (_) => List.generate(
        224,
        (y) => List.generate(
          224,
          (x) {
            final pixel = resized.getPixel(x, y);
            return [pixel.r / 255.0, pixel.g / 255.0, pixel.b / 255.0];
          },
        ),
      ),
    );

    final output = List.generate(1, (_) => List.filled(_labels.length, 0.0));
    _interpreter!.run(input, output);

    final scores = output.first;
    int bestIndex = 0;
    double bestScore = scores.first;
    for (int i = 1; i < scores.length; i++) {
      if (scores[i] > bestScore) {
        bestScore = scores[i];
        bestIndex = i;
      }
    }

    final predicted = _labels[bestIndex];
    final foodName = predicted.replaceAll('Fresh', '').replaceAll('Rotten', '');
    final freshness = predicted.startsWith('Fresh') ? 'Fresh' : 'Rotten';

    return InferenceResult(
      rawClass: predicted,
      foodName: foodName,
      freshnessStatus: freshness,
      confidence: bestScore,
      recommendation: _recommendation(foodName, freshness),
    );
  }

  String _recommendation(String foodName, String freshness) {
    if (freshness == 'Fresh') {
      switch (foodName.toLowerCase()) {
        case 'banana':
          return 'Keep bananas at room temperature and consume within ~2 days.';
        case 'apple':
          return 'Store apples in the fridge crisper to keep them fresh for ~5 days.';
        case 'orange':
          return 'Store oranges in a cool dry place or fridge; best within ~6 days.';
        default:
          return 'Store in a cool place and monitor daily.';
      }
    }

    return 'This item appears spoiled. Discard safely or compost if suitable.';
  }
}
