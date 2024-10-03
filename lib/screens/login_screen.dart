import 'package:flutter/material.dart';
import 'package:projek_uts_mobile_progamming/screens/main_screen.dart';
import 'package:projek_uts_mobile_progamming/screens/register_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _isPasswordVisible =
      false; // Tambahkan variabel untuk kontrol visibilitas password

  // Fungsi untuk login pengguna
  void login() async {
    showDialog(
      context: context,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      // Autentikasi dengan Firebase menggunakan email dan password
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      // Jika login berhasil, ambil data pengguna dari Firestore
      if (userCredential.user != null) {
        User? user = userCredential.user;

        // Ambil data pengguna dari Firestore berdasarkan email
        DocumentSnapshot userData = await FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid) // Menggunakan UID dari user yang login
            .get();

        // Setelah data didapatkan, arahkan ke MainScreen
        if (userData.exists) {
          Navigator.pop(context); // Tutup dialog CircularProgressIndicator
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => MainScreen(
                userData: userData.data(), // Kirim data pengguna ke MainScreen
              ),
            ),
          );
        } else {
          Navigator.pop(context);
          displayMessage("User data not found!");
        }
      }
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      displayMessage(e.message ?? "An error occurred.");
    }
  }

  // Fungsi untuk menampilkan pesan error
  void displayMessage(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        backgroundColor: Colors.black,
        title: Text(
          message ==
                  "The supplied auth credential is incorrect, malformed or has expired."
              ? "Email atau kata sandi anda masukkan salah,silahkan coba lagi."
              : message,
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(
              'OK',
              style: TextStyle(color: Colors.blue),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        // Tambahkan Center untuk memastikan elemen-elemen berada di tengah
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                  height: 100), // Beri jarak vertikal yang lebih besar
              Container(
                height: 100, // Perbesar tinggi gambar
                width: 200, // Perbesar lebar gambar
                child: const Image(
                  image: AssetImage('assets/images/img1.png'),
                ),
              ),
              const SizedBox(height: 30),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(11)),
                  fillColor: Colors.grey.shade700,
                  filled: true,
                  constraints:
                      const BoxConstraints.tightFor(width: 327, height: 50),
                  hintStyle: const TextStyle(
                      color:
                          Colors.grey), // Ubah warna hint text menjadi abu-abu
                  hintText: 'Email',
                ),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: passwordController,
                obscureText:
                    !_isPasswordVisible, // Mengatur visibilitas password
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(11)),
                  fillColor: Colors.grey.shade700,
                  filled: true,
                  constraints:
                      const BoxConstraints.tightFor(width: 327, height: 50),
                  hintStyle: const TextStyle(
                      color:
                          Colors.grey), // Ubah warna hint text menjadi abu-abu
                  hintText: 'Kata sandi',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                ),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 15),
              InkWell(
                onTap: login, // Panggil fungsi login
                child: Container(
                  width: 330,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Center(
                    child: Text(
                      'Login',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20), // Jarak vertikal lagi
              InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const RegisterScreen(),
                    ),
                  );
                },
                child: Container(
                  width: 330,
                  height: 40,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blue),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Center(
                    child: Text(
                      'Buat akun baru',
                      style: TextStyle(
                          color: Colors.blue, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 50), // Akhir jarak vertikal
            ],
          ),
        ),
      ),
    );
  }
}
