import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:task_flow/featuresscreen/taskrepo/providercontainer.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'firebase_options.dart';
import 'featuresscreen/homescreen/notification/notification.dart';
import 'splash_screen/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// 🔔 Initialize timezone (REQUIRED for scheduled notifications)
  tz.initializeTimeZones();

  /// 🔥 Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  /// 🔔 Initialize notifications
  await NotificationService.init();
await NotificationService.requestPermission();

  runApp(
    /// ✅ IMPORTANT: Use UncontrolledProviderScope
    /// so ProviderContainer can be used for UNDO
    UncontrolledProviderScope(
      container: providerContainer,
      child: const TaskFlowApp(),
    ),
  );
}

class TaskFlowApp extends StatelessWidget {
  const TaskFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Flow',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
        ),
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const SplashScreen(),
    );
  }
}
