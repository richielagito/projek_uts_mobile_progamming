import 'package:flutter/material.dart';
import 'package:projek_uts_mobile_progamming/screens/login_screen.dart';
import 'package:projek_uts_mobile_progamming/screens/main_screen.dart';
import 'package:projek_uts_mobile_progamming/screens/post_thread_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'GedaGedi.',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: PostThreadScreen());
  }
}
