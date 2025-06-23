import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:note_up/Providers/code_provider.dart';
import 'package:note_up/Providers/notesProvider.dart';
import 'package:note_up/dbs/CodeDbHelper.dart';
import 'package:note_up/dbs/image_db_helper.dart';
import 'package:note_up/dbs/reminder_db_helper.dart';
import 'package:note_up/dbs/todo_db_helper.dart';
import 'package:note_up/dbs/watchlist_db_helper.dart';
import 'package:provider/provider.dart';
import 'package:workmanager/workmanager.dart';
import 'Providers/menuProvider.dart';
import 'Providers/themeProvider.dart';
import 'dbs/database.dart';
import 'screens/HomeScreen.dart';
import 'dbs/note_db_helper.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

Future<void> initializeNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
}

Future<void> requestNotificationPermission() async {
  final bool? androidGranted =
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.requestNotificationsPermission();

  final bool? iosGranted = await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      IOSFlutterLocalNotificationsPlugin>()
      ?.requestPermissions(alert: true, badge: true, sound: true);

  if (androidGranted == true || iosGranted == true) {
    print("Notification permission granted");
  } else {
    print("Notification permission denied");
  }
}

void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    final position = await Geolocator.getCurrentPosition();
    final title = inputData?['title'] ?? 'Location Alert'; // Use custom title or default
    final targetLat = inputData?['targetLat'] ?? 19.0760; // Default from original
    final targetLng = inputData?['targetLng'] ?? 72.8777;

    double distanceInMeters = Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      targetLat,
      targetLng,
    );

    if (distanceInMeters < 200) {
      final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails('location_channel', 'Location Channel',
          importance: Importance.max, priority: Priority.high);
      const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);

      await flutterLocalNotificationsPlugin.show(
        0,
        title, // Use custom title
        'You are near your target!',
        platformChannelSpecifics,
      );
    }

    return Future.value(true);
  });
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Setup timezone
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));

  // Initialize notifications
  await initializeNotifications();
  await requestNotificationPermission();

  // Register all tables
  NoteDbHelper.registerNotesTable();
  TodoDbHelper.registerTodoTable();
  ReminderDbHelper.registerRegisterTable();
  WatchListDbHelper.registerRegisterTable();
  ImageDbHelper.registerImageTable();
  CodeModelHelper.registerCodeTable();

  // Initialize database
  await DatabaseHelper().database;

  await Workmanager().initialize(callbackDispatcher, isInDebugMode: false);

  Workmanager().registerPeriodicTask(
    "locationCheckTask",
    "checkLocation",
    frequency: const Duration(minutes: 15),
    initialDelay: Duration(seconds: 10),
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => MenuProvider()),
        ChangeNotifierProvider(create: (_) => NotesProvider()..loadNotes()),
        ChangeNotifierProvider(create: (_) => CodeProvider()..loadCodes()),

      ],
      child: MaterialApp(
        home: HomeScreen(isDark: false),
        debugShowCheckedModeBanner: false,
      ),
    ),
  );
}