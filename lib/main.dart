
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:vaccination/firebase_options.dart';
import 'package:vaccination/pages/home_page.dart';
import 'package:vaccination/pages/onboarding_page.dart';
import 'package:vaccination/services/storage_service.dart';
import 'package:vaccination/pages/my_appointments_page.dart';
import 'package:vaccination/components/bottom_nav_bar.dart';

import 'components/bottom_nav_bar.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FlutterLocalNotificationsPlugin().initialize(
    const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'), // your app icon
    ),
  );
  runApp(ChangeNotifierProvider(
    create:(context)=>StorageService(),
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      initialRoute: '/',
      routes: {
        '/home': (context) => const BottomNavBar(), // Your home page
        '/myAppointments': (context) => MyAppointments(), // Your My Appointments page
      },
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),

      home: const OnboardingPage(), // Use BottomNavBar as the home widget
    );
  }
}

