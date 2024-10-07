import 'package:flutter/material.dart';
import 'package:projek_uts_mobile_progamming/screens/main_screen.dart';
import 'package:projek_uts_mobile_progamming/screens/register_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginScreen extends StatefulWidget {
  // ignore: use_super_parameters
  const LoginScreen({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

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
          // ignore: use_build_context_synchronously
          Navigator.pop(context); // Tutup dialog CircularProgressIndicator
          // ignore: use_build_context_synchronously
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => MainScreen(
                userData: userData.data(), // Kirim data pengguna ke MainScreen
              ),
            ),
          );
        } else {
          // ignore: use_build_context_synchronously
          Navigator.pop(context);
          displayMessage("User data not found!");
        }
      }
    } on FirebaseAuthException catch (e) {
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
      displayMessage(e.message ?? "An error occurred.");
    }
  }

  // Fungsi untuk menampilkan pesan error
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
      body: Column(
        children: [
          const Expanded(
              child: Center(
                  child: Text(
            'English',
            style: TextStyle(color: Colors.white),
          ))),
          const Expanded(
              flex: 2,
              child: Center(
                  child: Text(
                '',
                style: TextStyle(color: Colors.white),
              ))),
          Expanded(
              flex: 4,
              child: Column(
                children: [
                  SizedBox(
                      height: 60,
                      width: 180,
                      child: const Image(
                        image: AssetImage('assets/images/img1.png'),
                      )),
                  const SizedBox(
                    height: 15,
                  ),
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(11)),
                      fillColor: Colors.grey.shade700,
                      prefixIconColor: Colors.grey.shade700,
                      filled: true,
                      constraints:
                          const BoxConstraints.tightFor(width: 327, height: 50),
                      hintStyle: const TextStyle(
                          color: Color.fromARGB(255, 255, 255, 255)),
                      hintText: 'Phone number, email or username',
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  TextField(
                    controller: passwordController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(11)),
                      fillColor: Colors.grey.shade700,
                      prefixIconColor: Colors.white,
                      filled: true,
                      constraints:
                          const BoxConstraints.tightFor(width: 327, height: 50),
                      hintStyle: const TextStyle(color: Colors.white),
                      hintText: 'Password',
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
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
                      )),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Forgot your login details? ",
                        style: TextStyle(color: Colors.white),
                      ),
                      Text(
                        "Get help logging in.",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ],
                  )
                ],
              )),
          const Expanded(
              flex: 2,
              child: Center(
                  child: Text(
                '',
                style: TextStyle(color: Colors.white),
              ))),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Don't have an account? ",
                  style: TextStyle(color: Colors.white),
                ),
                InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const RegisterScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    " Sign up",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
