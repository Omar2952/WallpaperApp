import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wallpaperapp/Views/home_page.dart';
import 'package:wallpaperapp/Views/login_page.dart';

import 'Utils/app_colors.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Wallpapers',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        scaffoldBackgroundColor: bgColor,
        appBarTheme: const AppBarTheme(backgroundColor: bgColor, centerTitle: true),
        useMaterial3: true,
      ),
      home: FirebaseAuth.instance.currentUser?.email != null ? const HomePage() : LoginPage(),
    );
  }
}

