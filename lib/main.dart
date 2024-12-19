  import 'package:flutter/material.dart';
  import 'package:firebase_core/firebase_core.dart';
  import 'firebase_options.dart';
  import 'package:flutter_local_notifications/flutter_local_notifications.dart';
  import 'package:firebase_messaging/firebase_messaging.dart';
  import 'package:hedieaty/views/SignInPage.dart';

  // Global FlutterLocalNotificationsPlugin instance
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  Future<void> main() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Initialize Notification Channel
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'gift_channel',
      'Gift Notifications',
      description: 'This channel is used for gift notifications.',
      importance: Importance.max,
      playSound: true,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Request notification permissions
    await FirebaseMessaging.instance.requestPermission();

    // Listen for background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    runApp(const HedieatyApp());
  }

  // Background notification handler
  Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    await Firebase.initializeApp();
  }

  // Define the HedieatyApp class
  class HedieatyApp extends StatelessWidget {
    const HedieatyApp({super.key});

    @override
    Widget build(BuildContext context) {
      return MaterialApp(
        title: 'Hedieaty',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: SignInPage(), // Navigate to the SignInPage
      );
    }
  }
