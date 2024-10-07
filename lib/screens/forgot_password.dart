import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final emailController = TextEditingController();
  final codeController = TextEditingController();
  final newPasswordController = TextEditingController();
  bool isCodeSent = false;
  String verificationCode = '';

  void sendResetCode() async {
    try {
      verificationCode = (Random().nextInt(900000) + 100000).toString();
      await sendEmailWithCode(emailController.text, verificationCode);
      setState(() {
        isCodeSent = true;
      });
      displayMessage("Kode reset telah dikirim ke email Anda.");
    } catch (e) {
      displayMessage("Terjadi kesalahan.");
    }
  }

  Future<void> sendEmailWithCode(String email, String code) async {
    // Implementasikan logika pengiriman email di sini
  }

  void resetPassword() async {
    if (codeController.text == verificationCode) {
      try {
        User? user = FirebaseAuth.instance.currentUser;
        await user?.updatePassword(newPasswordController.text);
        displayMessage("Kata sandi berhasil diatur ulang.");
      } catch (e) {
        displayMessage("Terjadi kesalahan saat mengatur ulang kata sandi.");
      }
    } else {
      displayMessage("Kode verifikasi salah.");
    }
  }

  void displayMessage(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          'Reset Password',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 50),
              Text(
                'Masukkan email yang ingin di reset',
                style: TextStyle(color: Colors.white, fontSize: 18),
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
                  hintStyle: const TextStyle(color: Colors.grey),
                  hintText: 'Email',
                ),
                style: const TextStyle(color: Colors.white),
              ),
              if (isCodeSent) ...[
                const SizedBox(height: 15),
                TextField(
                  controller: codeController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(11)),
                    fillColor: Colors.grey.shade700,
                    filled: true,
                    constraints:
                        const BoxConstraints.tightFor(width: 327, height: 50),
                    hintStyle: const TextStyle(color: Colors.grey),
                    hintText: 'Kode Autentikasi',
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: newPasswordController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(11)),
                    fillColor: Colors.grey.shade700,
                    filled: true,
                    constraints:
                        const BoxConstraints.tightFor(width: 327, height: 50),
                    hintStyle: const TextStyle(color: Colors.grey),
                    hintText: 'Kata Sandi Baru',
                  ),
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),
                ),
              ],
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: isCodeSent ? resetPassword : sendResetCode,
                child: Text(
                  isCodeSent ? 'Reset Password' : 'Kirim Kode',
                  style: TextStyle(color: Colors.white), // Ubah warna teks menjadi putih
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 195, 112, 255),
                  fixedSize: const Size(330, 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}