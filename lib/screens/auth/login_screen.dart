import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool isSignUpMode = false;

  // Error messages for fields
  String _emailError = '';
  String _passwordError = '';
  String _nameError = '';

  void toggleAuthMode() {
    setState(() {
      isSignUpMode = !isSignUpMode;
    });
  }

  void handleAuthAction() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String name = _nameController.text.trim();

    // Reset error messages
    setState(() {
      _emailError = '';
      _passwordError = '';
      _nameError = '';
    });

    // Validation for missing fields
    String message = '';
    if (email.isEmpty || password.isEmpty || (isSignUpMode && name.isEmpty)) {
      message = 'All fields are required.';
    } else if (isSignUpMode && password.length < 6) {
      message = 'Password must be at least 6 characters.';
    }

    // Set error messages for respective fields
    if (email.isEmpty) {
      _emailError = 'Email is required.';
    }
    if (password.isEmpty) {
      _passwordError = 'Password is required.';
    }
    if (isSignUpMode && name.isEmpty) {
      _nameError = 'Name is required.';
    }

    if (message.isNotEmpty) {
      // Show Snackbar for validation errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
      return; // Don't proceed if validation fails
    }

    try {
      if (isSignUpMode) {
        // Sign Up logic
        UserCredential userCredential =
            await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
          'name': name,
          'email': email,
          'usertype': 'client', // Default usertype
        });

        Navigator.pushReplacementNamed(context, '/client_homepage');
      } else {
        // Login logic
        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Check if the user is an admin or client
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .get();

        String usertype = userDoc.get('usertype') ?? 'client';

        if (usertype == 'admin') {
          Navigator.pushReplacementNamed(context, '/admin_homepage');
        } else {
          Navigator.pushReplacementNamed(context, '/client_homepage');
        }
      }
    } on FirebaseAuthException catch (error) {
      String errorMessage;

      switch (error.code) {
        case 'email-already-in-use':
          errorMessage = 'This email is already taken.';
          break;
        case 'invalid-credential':
          errorMessage = 'Invalid email or password. Please try again.';
          break;
        case 'invalid-email':
          errorMessage =
              'Incorrect email format. Use format like example@domain.com';
          setState(() {
            _emailError += "Invalid Email Format";
          });
          break;
        case 'weak-password':
          errorMessage = 'Password must be at least 6 characters.';
          break;
        default:
          errorMessage = 'An error occurred. Please try again.';
      }

      // Show Snackbar for Firebase errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    } catch (error) {
      // General error
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An unexpected error occurred.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 15, top: 70),
              child: Image.asset(
                "lib/assets/login_logo.png",
                width: 413,
                height: 350,
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Text(
                  //   isSignUpMode ? 'Sign Up' : 'Log In',
                  //   style: const TextStyle(
                  //     color: Color(0xFF000000),
                  //     fontSize: 27,
                  //     fontFamily: 'Poppins',
                  //     fontWeight: FontWeight.w500,
                  //   ),
                  // ),
                  // const SizedBox(height: 50),
                  if (isSignUpMode)
                    TextField(
                      controller: _nameController,
                      textAlign: TextAlign.left,
                      style: const TextStyle(
                        color: Color(0xFF393939),
                        fontSize: 13,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w400,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        labelStyle: TextStyle(
                          color: Color(0xFF808080),
                          fontSize: 15,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          borderSide: BorderSide(
                            width: 1,
                            color: Color(0xFF837E93),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          borderSide: BorderSide(
                            width: 1,
                            color: Color(0xFFFF6F00),
                          ),
                        ),
                      ),
                    ),
                  if (isSignUpMode && _nameError.isNotEmpty)
                    Text(
                      _nameError,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  if (isSignUpMode) const SizedBox(height: 30),
                  TextField(
                    controller: _emailController,
                    textAlign: TextAlign.left,
                    style: const TextStyle(
                      color: Color(0xFF393939),
                      fontSize: 13,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w400,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      labelStyle: TextStyle(
                        color: Color(0xFF808080),
                        fontSize: 15,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        borderSide: BorderSide(
                          width: 1,
                          color: Color(0xFF837E93),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        borderSide: BorderSide(
                          width: 1,
                          color: Color(0xFFFF6F00),
                        ),
                      ),
                    ),
                  ),
                  if (_emailError.isNotEmpty)
                    Text(
                      _emailError,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  const SizedBox(height: 30),
                  TextField(
                    controller: _passwordController,
                    textAlign: TextAlign.left,
                    obscureText: true,
                    style: const TextStyle(
                      color: Color(0xFF393939),
                      fontSize: 13,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w400,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      labelStyle: TextStyle(
                        color: Color(0xFF808080),
                        fontSize: 15,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        borderSide: BorderSide(
                          width: 1,
                          color: Color(0xFF837E93),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        borderSide: BorderSide(
                          width: 1,
                          color: Color(0xFFFF6F00),
                        ),
                      ),
                    ),
                  ),
                  if (_passwordError.isNotEmpty)
                    Text(
                      _passwordError,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  const SizedBox(height: 25),
                  ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    child: SizedBox(
                      width: 329,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: handleAuthAction,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF6F00),
                        ),
                        child: Text(
                          isSignUpMode ? 'Sign Up' : 'Sign In',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Text(
                        isSignUpMode
                            ? 'Already have an account?'
                            : 'Don’t have an account?',
                        style: const TextStyle(
                          color: Color(0xFF837E93),
                          fontSize: 13,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 5),
                      InkWell(
                        onTap: toggleAuthMode,
                        child: Text(
                          isSignUpMode ? 'Log In' : 'Sign Up',
                          style: const TextStyle(
                            color: Color(0xFFFF6F00),
                            fontSize: 13,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 50,
                      )
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
