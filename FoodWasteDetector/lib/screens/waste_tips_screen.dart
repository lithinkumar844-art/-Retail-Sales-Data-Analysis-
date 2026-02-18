import 'package:flutter/material.dart';

class WasteTipsScreen extends StatelessWidget {
  const WasteTipsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tips = [
      'Plan weekly meals and buy only what you need.',
      'Use FIFO: First In, First Out in your fridge.',
      'Freeze ripe fruits before they spoil.',
      'Compost biodegradable food waste when possible.',
      'Track your waste with app history and analytics.',
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Waste Reduction Tips')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: tips.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (_, i) => Card(
          child: ListTile(
            leading: const Icon(Icons.eco_outlined),
            title: Text(tips[i]),
          ),
        ),
      ),
    );
  }
}
