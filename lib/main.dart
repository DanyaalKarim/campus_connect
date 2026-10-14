import 'services/notification_service.dart';
import 'providers/announcement_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';    // ✅ YE IMPORT ADD KARO
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/event_provider.dart';
import 'theme/app_theme.dart';
import 'screens/splash/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ✅ FIRESTORE OFFLINE PERSISTENCE — YE 4 LINES ADD KARO
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  // Initialize notifications
  await NotificationService().initialize();

  runApp(const CampusConnectApp());
}

class AppScrollBehavior extends MaterialScrollBehavior {
  const AppScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
    PointerDeviceKind.stylus,
    PointerDeviceKind.invertedStylus,
  };
}

class CampusConnectApp extends StatelessWidget {
  const CampusConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => EventProvider()),
        ChangeNotifierProvider(create: (_) => AnnouncementProvider()),
      ],
      child: MaterialApp(
        title: 'CampusConnect',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        scrollBehavior: const AppScrollBehavior(),
        home: const SplashScreen(),
        routes: {
          '/login': (context) => const SplashScreen(),
        },
      ),
    );
  }
}