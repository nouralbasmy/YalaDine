import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yala_dine/providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  var confirmPasswordController = TextEditingController();

  var authenticationMode = 0;
  // 0 for login and 1 for signup.

  void toggleAuthMode() {
    setState(() {
      authenticationMode = authenticationMode == 0 ? 1 : 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: 400,
        margin: EdgeInsets.only(top: 100, left: 10, right: 10),
        child: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Center(
                  child: Text(
                    "Yala Dine",
                    style: TextStyle(fontSize: 30),
                  ),
                ),
                TextField(
                  decoration: InputDecoration(labelText: "Email"),
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                ),
                TextField(
                  decoration: InputDecoration(labelText: "Password"),
                  controller: passwordController,
                  obscureText: true,
                ),
                if (authenticationMode == 1)
                  TextField(
                    decoration: InputDecoration(labelText: "Confirm Password"),
                    controller: confirmPasswordController,
                    obscureText: true,
                  ),
                ElevatedButton(
                  onPressed: () {
                    loginORsignup();
                  },
                  child: (authenticationMode == 1)
                      ? Text("Sign up")
                      : Text("Login"),
                ),
                TextButton(
                  onPressed: () {
                    toggleAuthMode();
                  },
                  child: (authenticationMode == 1)
                      ? Text("Login")
                      : Text("Sign up"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void loginORsignup() async {
    var authprov = Provider.of<AuthProvider>(context, listen: false);
    var email = emailController.text.trim();
    var password = passwordController.text.trim();

    if (authenticationMode == 1) {
      var successOrError = await authprov.signup(em: email, pass: password);
      if (successOrError == "success") {
        Navigator.of(context).pop();
        Navigator.of(context).pushNamed('/ClientRouteTest');
      } else if (successOrError.contains("EMAIL_EXISTS")) {
        _showSnackBar('Email already exists');
      }
    } else {
      var successOrError = await authprov.signin(em: email, pass: password);
      if (successOrError == "success") {
        Navigator.of(context).pop();
        Navigator.of(context).pushNamed('/ClientRouteTest');
      } else if (successOrError.contains("INVALID_LOGIN_CREDENTIALS")) {
        _showSnackBar('Invalid email or password. Please try again.');
      }
    }
  }

  void _showSnackBar(String message) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
