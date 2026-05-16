import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:kids_learning_flutter_app/providers/course_provider.dart';
import 'package:kids_learning_flutter_app/providers/statistics_provider.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'core/notify_data.dart';
import 'providers/session_provider.dart';
import 'providers/audio_provider.dart';
import 'package:flutter_stripe/flutter_stripe.dart';


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  if(!kIsWeb) {
    Stripe.publishableKey = "pk_test_51TCk2f5uapxQa23DhqiKT6ij1zRatKNESeQCjLndVrUAziFRvdDfGTGRZ4o1ECRG6ZxqDNgTfgWKs6YiWGbM5ca100rWB53sYw";
    try {
      await Stripe.instance.applySettings();
    } catch (e) {
      debugPrint('Stripe init failed: $e');
    }
  }
  

  runApp(
    ChangeNotifierProvider(
      create: (context) => NotifyData(),
      child: MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SessionProvider()),
        ChangeNotifierProvider(create: (_) => CourseProvider()),
        ChangeNotifierProvider(create: (_) => AudioProvider()),
        ChangeNotifierProvider(create: (_) => StatisticsProvider()),
      ],
      child: const KidsLearningApp(),
    ),
    ),
  );
}