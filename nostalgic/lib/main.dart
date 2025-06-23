import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:nostalgic/Connection%20Service/Starter_Home.dart';
import 'package:nostalgic/Pages/LoginPage.dart';
import 'package:nostalgic/Pages/RegisterPage.dart';
import 'Communication/requests.dart';
import 'firebase_options.dart';



void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp(); // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MaterialApp(
    title: 'Bee Hive',
    theme: ThemeData(
      primarySwatch: Colors.grey,
      scaffoldBackgroundColor: const Color(0xFFF7F7F7),
    ),
    // home: MessagingHome(),
    home: LoginPage(),
    debugShowCheckedModeBanner: false,
    routes: {
      '/reg' : (context) => RegisterPage(),
      '/log' : (context) => LoginPage(),
      '/startH' : (context) => StarterHome(),
      '/joinH' : (context) => ConnectionRequestsPage(),


    },
  ));
}