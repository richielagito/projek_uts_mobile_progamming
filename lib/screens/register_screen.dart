import 'package:flutter/material.dart';
import 'package:projek_uts_mobile_progamming/screens/login_screen.dart';
import 'package:projek_uts_mobile_progamming/screens/main_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Controller untuk field input
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();

  // Fungsi untuk mendaftarkan pengguna
  void daftar() async {
    showDialog(
      context: context,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      // Mendaftarkan pengguna dengan email dan password di Firebase
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      // Setelah sukses, simpan data pengguna ke Firestore
      await createUserInFirebase(
        usernameController.text,
        phoneController.text,
        emailController.text,
      );

      if (context.mounted) {
        Navigator.pop(context);
        // Navigasi ke MainScreen setelah pendaftaran sukses
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const LoginScreen(),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      displayMessage(e.code); // Menampilkan pesan error
    }
  }

  // Fungsi untuk menyimpan data pengguna ke Firestore
  Future<void> createUserInFirebase(
      String username, String phone, String email) async {
    await FirebaseFirestore.instance.collection('users').add({
      'username': username,
      'phone': phone,
      'email': email,
    });
  }

  // Fungsi untuk menampilkan pesan
  void displayMessage(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 50),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 60,
                    width: 180,
                    child: const Image(
                      image: AssetImage('assets/images/img1.png'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Tombol login dengan Facebook
              Container(
                width: 327,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.facebook),
                    SizedBox(width: 7),
                    Center(
                      child: Text(
                        'Log in with Facebook',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Garis pemisah OR
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 1,
                    width: 150,
                    color: Colors.grey.shade700,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'OR',
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                  ),
                  Container(
                    height: 1,
                    width: 150,
                    color: Colors.grey.shade700,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Input Username
              TextField(
                controller: usernameController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(11),
                  ),
                  fillColor: Colors.grey.shade700,
                  filled: true,
                  constraints:
                      const BoxConstraints.tightFor(width: 327, height: 50),
                  hintStyle: const TextStyle(color: Colors.grey),
                  hintText: 'Username',
                ),
              ),
              const SizedBox(height: 15),
              // Input Password
              TextField(
                controller: passwordController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(11),
                  ),
                  fillColor: Colors.grey.shade700,
                  filled: true,
                  constraints:
                      const BoxConstraints.tightFor(width: 327, height: 50),
                  hintStyle: const TextStyle(color: Colors.grey),
                  hintText: 'Password',
                ),
              ),
              const SizedBox(height: 15),
              // Input Phone
              TextField(
                controller: phoneController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(11),
                  ),
                  fillColor: Colors.grey.shade700,
                  filled: true,
                  constraints:
                      const BoxConstraints.tightFor(width: 327, height: 50),
                  hintStyle: const TextStyle(color: Colors.grey),
                  hintText: 'Phone',
                ),
              ),
              const SizedBox(height: 15),
              // Input Email
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(11),
                  ),
                  fillColor: Colors.grey.shade700,
                  filled: true,
                  constraints:
                      const BoxConstraints.tightFor(width: 327, height: 50),
                  hintStyle: const TextStyle(color: Colors.grey),
                  hintText: 'Email',
                ),
              ),
              const SizedBox(height: 15),
              // Tombol Daftar
              InkWell(
                onTap: daftar,
                child: Container(
                  width: 327,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Center(
                    child: Text(
                      'Register',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "By signing up, you agree to our Terms and Policy",
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 120),
              // Opsi login
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Have an account ? ",
                    style: TextStyle(color: Colors.white),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      " Log in",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
