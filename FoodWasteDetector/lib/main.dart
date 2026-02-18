import 'package:flutter/material.dart';

import 'screens/analytics_screen.dart';
import 'screens/history_screen.dart';
import 'screens/home_screen.dart';
import 'screens/scan_screen.dart';
import 'screens/waste_tips_screen.dart';
import 'services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.initialize();
  runApp(const FoodWasteDetectorApp());
}

class FoodWasteDetectorApp extends StatelessWidget {
  const FoodWasteDetectorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Food Waste Detector',
      theme: ThemeData.dark(useMaterial3: true).copyWith(
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF7CFC00),
          secondary: Color(0xFF00E5FF),
          surface: Color(0xFF121212),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (_) => const HomeScreen(),
        '/scan': (_) => const ScanScreen(),
        '/history': (_) => const HistoryScreen(),
        '/analytics': (_) => const AnalyticsScreen(),
        '/tips': (_) => const WasteTipsScreen(),
      },
    );
  }
}
