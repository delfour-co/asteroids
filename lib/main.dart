import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app.dart';
import 'splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  // Capture Flutter errors (widget/rendering)
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  // Capture uncaught async Dart errors
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  // Force landscape orientation
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // Hide system UI for fullscreen
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  runApp(const NeonAsteroidsApp());
}

class NeonAsteroidsApp extends StatefulWidget {
  const NeonAsteroidsApp({super.key});

  @override
  State<NeonAsteroidsApp> createState() => _NeonAsteroidsAppState();
}

class _NeonAsteroidsAppState extends State<NeonAsteroidsApp> {
  bool _splashDone = false;

  @override
  Widget build(BuildContext context) {
    if (!_splashDone) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: SplashScreen(
          onComplete: () => setState(() => _splashDone = true),
        ),
      );
    }
    return GameWidget(game: AsteroidsNeonGame());
  }
}
