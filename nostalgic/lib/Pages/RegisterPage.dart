// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:flutter/services.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
//
// class RegisterPage extends StatefulWidget {
//   const RegisterPage({super.key});
//
//   @override
//   State<RegisterPage> createState() => _RegisterPageState();
// }
//
// class _RegisterPageState extends State<RegisterPage> {
//   final TextEditingController fullnameController = TextEditingController();
//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController phoneController = TextEditingController();
//   final TextEditingController addressController = TextEditingController();
//   final TextEditingController passwordController = TextEditingController();
//   bool isLoading = false;
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//
//   final FocusNode fullnameFocus = FocusNode();
//   final FocusNode emailFocus = FocusNode();
//   final FocusNode phoneFocus = FocusNode();
//   final FocusNode addressFocus = FocusNode();
//   final FocusNode passwordFocus = FocusNode();
//
//   bool isEmailValid = true;
//
//   final RegExp emailRegex =
//   RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");
//
//   @override
//   void initState() {
//     super.initState();
//     emailController.addListener(() {
//       setState(() {
//         isEmailValid = emailController.text.isEmpty ||
//             emailRegex.hasMatch(emailController.text);
//       });
//     });
//   }
//
//   @override
//   void dispose() {
//     fullnameController.dispose();
//     emailController.dispose();
//     phoneController.dispose();
//     addressController.dispose();
//     passwordController.dispose();
//     fullnameFocus.dispose();
//     emailFocus.dispose();
//     phoneFocus.dispose();
//     addressFocus.dispose();
//     passwordFocus.dispose();
//     super.dispose();
//   }
//
//   InputDecoration _inputDecoration(
//       {required String label, required IconData icon, String? errorText}) {
//     return InputDecoration(
//       labelText: label,
//       labelStyle: const TextStyle(color: Color(0xFF26A69A)), // Teal
//       prefixIcon: Icon(icon, color: const Color(0xFF26A69A)),
//       border: OutlineInputBorder(
//         borderSide: const BorderSide(color: Color(0xFF00B7FF), width: 1), // Electric Blue
//         borderRadius: BorderRadius.circular(12),
//       ),
//       enabledBorder: OutlineInputBorder(
//         borderSide: const BorderSide(color: Color(0xFF00B7FF), width: 1),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       focusedBorder: OutlineInputBorder(
//         borderSide: const BorderSide(color: Color(0xFF00B7FF), width: 2),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       errorText: errorText,
//       errorStyle: const TextStyle(color: Color(0xFFFF4D4D)), // Soft Red
//       contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
//     );
//   }
//
//   void register() async {
//     final fullname = fullnameController.text.trim();
//     final email = emailController.text.trim();
//     final phone = phoneController.text.trim();
//     final address = addressController.text.trim();
//     final password = passwordController.text.trim();
//
//     setState(() => isLoading = true);
//
//     try {
//       UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
//           email: email, password: password);
//       String uid = userCredential.user!.uid;
//
//
//       await FirebaseFirestore.instance.collection('joiner connections').doc(uid).set({
//         'sender_ids':[],
//       });
//
//       await FirebaseFirestore.instance.collection('users').doc(uid).set({
//         'fullname': fullname,
//         'email': email,
//         'phone': phone,
//         'address': address,
//         'uid': uid,
//         'createdAt': Timestamp.now(),
//       });
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text("Registered"),
//           backgroundColor: Color(0xFF00B7FF), // Electric Blue
//         ),
//       );
//
//       Navigator.pushReplacementNamed(context, '/log');
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text("Error: $e"),
//           backgroundColor: const Color(0xFFFF4D4D), // Soft Red
//         ),
//       );
//     }
//
//     setState(() => isLoading = false);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () => FocusScope.of(context).unfocus(),
//       child: Scaffold(
//         backgroundColor: const Color(0xFF1A1A1A), // Charcoal Gray
//         appBar: AppBar(
//           leading: IconButton(
//             icon: const Icon(Icons.arrow_back, color: Color(0xFF00B7FF)), // Electric Blue
//             onPressed: () => Navigator.pushReplacementNamed(context, '/log'),
//           ),
//           title: Text(
//             'Register',
//             style: GoogleFonts.orbitron(
//               color: const Color(0xFF00B7FF), // Electric Blue
//               fontWeight: FontWeight.bold,
//               letterSpacing: 1.5,
//             ),
//           ),
//           backgroundColor: const Color(0xFF1A1A1A), // Charcoal Gray
//           elevation: 0,
//         ),
//         body: SafeArea(
//           child: SingleChildScrollView(
//             physics: const BouncingScrollPhysics(),
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 20),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'New Player',
//                     style: GoogleFonts.orbitron(
//                       fontSize: 32,
//                       fontWeight: FontWeight.bold,
//                       color: const Color(0xFF00B7FF), // Electric Blue
//                       letterSpacing: 1.5,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     'Create your account',
//                     style: GoogleFonts.roboto(
//                       fontSize: 16,
//                       color: const Color(0xFFE0E0E0).withOpacity(0.7), // Off-White
//                     ),
//                   ),
//                   const SizedBox(height: 40),
//                   TextField(
//                     focusNode: fullnameFocus,
//                     controller: fullnameController,
//                     style: const TextStyle(color: Color(0xFFE0E0E0)),
//                     decoration: _inputDecoration(
//                       label: 'Name',
//                       icon: Icons.person,
//                     ),
//                     textInputAction: TextInputAction.next,
//                     onSubmitted: (_) =>
//                         FocusScope.of(context).requestFocus(emailFocus),
//                   ),
//                   const SizedBox(height: 20),
//                   TextField(
//                     focusNode: emailFocus,
//                     controller: emailController,
//                     style: const TextStyle(color: Color(0xFFE0E0E0)),
//                     decoration: _inputDecoration(
//                       label: 'Email',
//                       icon: Icons.email,
//                       errorText: isEmailValid ? null : 'Invalid Email',
//                     ),
//                     keyboardType: TextInputType.emailAddress,
//                     textInputAction: TextInputAction.next,
//                     onSubmitted: (_) =>
//                         FocusScope.of(context).requestFocus(phoneFocus),
//                   ),
//                   const SizedBox(height: 20),
//                   TextField(
//                     focusNode: phoneFocus,
//                     controller: phoneController,
//                     style: const TextStyle(color: Color(0xFFE0E0E0)),
//                     decoration: _inputDecoration(
//                       label: 'Phone (opt)',
//                       icon: Icons.phone,
//                     ),
//                     keyboardType: TextInputType.phone,
//                     textInputAction: TextInputAction.next,
//                     inputFormatters: [
//                       FilteringTextInputFormatter.digitsOnly,
//                       LengthLimitingTextInputFormatter(10),
//                     ],
//                     onSubmitted: (_) =>
//                         FocusScope.of(context).requestFocus(addressFocus),
//                   ),
//                   const SizedBox(height: 20),
//                   TextField(
//                     focusNode: addressFocus,
//                     controller: addressController,
//                     style: const TextStyle(color: Color(0xFFE0E0E0)),
//                     decoration: _inputDecoration(
//                       label: 'Address (opt)',
//                       icon: Icons.location_on,
//                     ),
//                     textInputAction: TextInputAction.next,
//                     onSubmitted: (_) =>
//                         FocusScope.of(context).requestFocus(passwordFocus),
//                   ),
//                   const SizedBox(height: 20),
//                   TextField(
//                     focusNode: passwordFocus,
//                     controller: passwordController,
//                     obscureText: true,
//                     style: const TextStyle(color: Color(0xFFE0E0E0)),
//                     decoration: _inputDecoration(
//                       label: 'Password',
//                       icon: Icons.lock,
//                     ),
//                     textInputAction: TextInputAction.done,
//                     onSubmitted: (_) => register(),
//                   ),
//                   const SizedBox(height: 48),
//                   Center(
//                     child: isLoading
//                         ? const CircularProgressIndicator(
//                       valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00B7FF)),
//                     )
//                         : ElevatedButton(
//                       onPressed: register,
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: const Color(0xFF00B7FF), // Electric Blue
//                         foregroundColor: const Color(0xFF1A1A1A), // Charcoal Gray
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 48, vertical: 16),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         elevation: 0,
//                       ),
//                       child: Text(
//                         'Register',
//                         style: GoogleFonts.orbitron(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                           letterSpacing: 1,
//                         ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 24),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Text(
//                         "Already have an account? ",
//                         style: GoogleFonts.roboto(
//                           color: const Color(0xFFE0E0E0).withOpacity(0.7),
//                         ),
//                       ),
//                       TextButton(
//                         onPressed: () => Navigator.pushReplacementNamed(context, '/log'),
//                         child: Text(
//                           'Login',
//                           style: GoogleFonts.orbitron(
//                             fontWeight: FontWeight.bold,
//                             color: const Color(0xFF00B7FF), // Electric Blue
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController fullnameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController(); // Changed from emailController
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final FocusNode fullnameFocus = FocusNode();
  final FocusNode usernameFocus = FocusNode(); // Changed from emailFocus
  final FocusNode phoneFocus = FocusNode();
  final FocusNode addressFocus = FocusNode();
  final FocusNode passwordFocus = FocusNode();

  bool isUsernameValid = true;

  @override
  void initState() {
    super.initState();
    usernameController.addListener(() {
      setState(() {
        isUsernameValid = usernameController.text.isNotEmpty &&
            usernameController.text.length >= 3; // Basic validation (min 3 chars)
      });
    });
  }

  @override
  void dispose() {
    fullnameController.dispose();
    usernameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    passwordController.dispose();
    fullnameFocus.dispose();
    usernameFocus.dispose();
    phoneFocus.dispose();
    addressFocus.dispose();
    passwordFocus.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration(
      {required String label, required IconData icon, String? errorText}) {
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
      errorText: errorText,
      errorStyle: const TextStyle(color: Color(0xFFFF4D4D)), // Soft Red
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
    );
  }

  // Check if username is available
  Future<bool> isUsernameAvailable(String username) async {
    final result = await _firestore
        .collection('usernames')
        .doc(username.toLowerCase())
        .get();
    return !result.exists; // True if username is not taken
  }

  void register() async {
    final fullname = fullnameController.text.trim();
    final username = usernameController.text.trim();
    final phone = phoneController.text.trim();
    final address = addressController.text.trim();
    final password = passwordController.text.trim();

    if (!isUsernameValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Username must be at least 3 characters"),
          backgroundColor: Color(0xFFFF4D4D),
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      // Check if username is available
      bool available = await isUsernameAvailable(username);
      if (!available) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Username is already taken"),
            backgroundColor: Color(0xFFFF4D4D),
          ),
        );
        return;
      }

      // Create fake email
      String fakeEmail = "${username.toLowerCase()}@nos.com";

      // Register with Firebase Auth
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: fakeEmail,
        password: password,
      );
      String uid = userCredential.user!.uid;

      // Store username in Firestore for availability checking
      await FirebaseFirestore.instance.collection('joiner connections').doc(uid).set({
        'sender_ids':[],
      });

      // Store user details in Firestore
      await _firestore.collection('users').doc(uid).set({
        'fullname': fullname,
        'email': username, // Changed from 'email'
        'phone': phone,
        'address': address,
        'uid': uid,
        'createdAt': Timestamp.now(),
      });

      // Store username in SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('username', username); // Changed from 'email'

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Registered"),
          backgroundColor: Color(0xFF00B7FF), // Electric Blue
        ),
      );

      Navigator.pushReplacementNamed(context, '/log');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: const Color(0xFFFF4D4D), // Soft Red
        ),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: const Color(0xFF1A1A1A), // Charcoal Gray
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF00B7FF)), // Electric Blue
            onPressed: () => Navigator.pushReplacementNamed(context, '/log'),
          ),
          title: Text(
            'Register',
            style: GoogleFonts.orbitron(
              color: const Color(0xFF00B7FF), // Electric Blue
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          backgroundColor: const Color(0xFF1A1A1A), // Charcoal Gray
          elevation: 0,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'New Player',
                    style: GoogleFonts.orbitron(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF00B7FF), // Electric Blue
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create your account',
                    style: GoogleFonts.roboto(
                      fontSize: 16,
                      color: const Color(0xFFE0E0E0).withOpacity(0.7), // Off-White
                    ),
                  ),
                  const SizedBox(height: 40),
                  TextField(
                    focusNode: fullnameFocus,
                    controller: fullnameController,
                    style: const TextStyle(color: Color(0xFFE0E0E0)),
                    decoration: _inputDecoration(
                      label: 'Name',
                      icon: Icons.person,
                    ),
                    textInputAction: TextInputAction.next,
                    onSubmitted: (_) =>
                        FocusScope.of(context).requestFocus(usernameFocus),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    focusNode: usernameFocus, // Changed from emailFocus
                    controller: usernameController,
                    style: const TextStyle(color: Color(0xFFE0E0E0)),
                    decoration: _inputDecoration(
                      label: 'Username', // Changed from 'Email'
                      icon: Icons.person_outline, // Changed from Icons.email
                      errorText: isUsernameValid ? null : 'Username must be at least 3 characters',
                    ),
                    keyboardType: TextInputType.text, // Changed from TextInputType.emailAddress
                    textInputAction: TextInputAction.next,
                    onSubmitted: (_) =>
                        FocusScope.of(context).requestFocus(phoneFocus),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    focusNode: phoneFocus,
                    controller: phoneController,
                    style: const TextStyle(color: Color(0xFFE0E0E0)),
                    decoration: _inputDecoration(
                      label: 'Phone (opt)',
                      icon: Icons.phone,
                    ),
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                    onSubmitted: (_) =>
                        FocusScope.of(context).requestFocus(addressFocus),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    focusNode: addressFocus,
                    controller: addressController,
                    style: const TextStyle(color: Color(0xFFE0E0E0)),
                    decoration: _inputDecoration(
                      label: 'Address (opt)',
                      icon: Icons.location_on,
                    ),
                    textInputAction: TextInputAction.next,
                    onSubmitted: (_) =>
                        FocusScope.of(context).requestFocus(passwordFocus),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    focusNode: passwordFocus,
                    controller: passwordController,
                    obscureText: true,
                    style: const TextStyle(color: Color(0xFFE0E0E0)),
                    decoration: _inputDecoration(
                      label: 'Password',
                      icon: Icons.lock,
                    ),
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => register(),
                  ),
                  const SizedBox(height: 48),
                  Center(
                    child: isLoading
                        ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00B7FF)),
                    )
                        : ElevatedButton(
                      onPressed: register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00B7FF), // Electric Blue
                        foregroundColor: const Color(0xFF1A1A1A), // Charcoal Gray
                        padding: const EdgeInsets.symmetric(
                            horizontal: 48, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Register',
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
                        "Already have an account? ",
                        style: GoogleFonts.roboto(
                          color: const Color(0xFFE0E0E0).withOpacity(0.7),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pushReplacementNamed(context, '/log'),
                        child: Text(
                          'Login',
                          style: GoogleFonts.orbitron(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF00B7FF), // Electric Blue
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}