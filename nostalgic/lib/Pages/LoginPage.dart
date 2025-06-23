import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController usernameController = TextEditingController(); // Changed from emailController
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;

  Future<void> login() async {
    setState(() => isLoading = true);
    try {
      // Convert username to fake email
      String fakeEmail = "${usernameController.text.toLowerCase()}@nos.com";

      // Sign in with Firebase Auth using fake email
      await _auth.signInWithEmailAndPassword(
        email: fakeEmail,
        password: passwordController.text,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Logged In"),
          backgroundColor: Color(0xFF00B7FF), // Electric Blue
        ),
      );

      // Store username (not fake email) in SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('username', usernameController.text); // Changed from 'email'

      Navigator.pushReplacementNamed(context, '/startH');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: const Color(0xFFFF4D4D), // Soft Red for errors
        ),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  InputDecoration _inputDecoration({required String label, required IconData icon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Color(0xFF26A69A)), // Teal
      prefixIcon: Icon(icon, color: const Color(0xFF26A69A)),
      border: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0xFF00B7FF), width: 1), // Electric Blue
        borderRadius: BorderRadius.circular(12),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0xFF00B7FF), width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0xFF00B7FF), width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A), // Charcoal Gray
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Log in Bro 👀',
                  style: GoogleFonts.orbitron(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF00B7FF), // Electric Blue
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Let us know, you are still worthy',
                  style: GoogleFonts.roboto(
                    fontSize: 16,
                    color: const Color(0xFFE0E0E0).withOpacity(0.7), // Off-White
                  ),
                ),
                const SizedBox(height: 40),
                TextField(
                  controller: usernameController, // Changed from emailController
                  style: const TextStyle(color: Color(0xFFE0E0E0)),
                  decoration: _inputDecoration(
                    label: 'Username', // Changed from 'Email'
                    icon: Icons.person, // Changed from Icons.email
                  ),
                  keyboardType: TextInputType.text, // Changed from TextInputType.emailAddress
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  style: const TextStyle(color: Color(0xFFE0E0E0)),
                  decoration: _inputDecoration(
                    label: 'Password',
                    icon: Icons.lock,
                  ),
                ),
                const SizedBox(height: 48),
                Center(
                  child: isLoading
                      ? const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00B7FF)),
                  )
                      : ElevatedButton(
                    onPressed: login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00B7FF), // Electric Blue
                      foregroundColor: const Color(0xFF1A1A1A), // Charcoal Gray
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Login',
                      style: GoogleFonts.orbitron(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      " Want to Join?",
                      style: GoogleFonts.roboto(
                        color: const Color(0xFFE0E0E0).withOpacity(0.7),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pushReplacementNamed(context, '/reg'),
                      child: Text(
                        'Register',
                        style: GoogleFonts.orbitron(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF00B7FF), // Electric Blue
                        ),
                      ),
                    ),
                    Text("\n  😗\n👉 👈\n"),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}