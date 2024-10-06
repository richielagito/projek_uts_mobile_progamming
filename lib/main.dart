import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/login_screen.dart'; // Impor halaman login Anda
import 'screens/profile_screen.dart';
// Impor halaman-halaman lain yang Anda perlukan

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nama Aplikasi Anda',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/login', // Rute awal aplikasi
      routes: {
        '/login': (context) => LoginScreen(), // Definisikan rute login
        '/profile': (context) => ProfileScreen(),
        // Tambahkan rute-rute lain yang Anda perlukan
      },
    );
  }
}
