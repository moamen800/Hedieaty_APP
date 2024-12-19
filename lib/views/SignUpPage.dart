import 'package:flutter/material.dart';
import 'package:hedieaty/controllers/auth_controller.dart';
import 'SignInPage.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController preferencesController = TextEditingController();

  final AuthController _authController = AuthController();

  void _signUp() async {
    String username = usernameController.text;
    String email = emailController.text;
    String password = passwordController.text;
    String preferences = preferencesController.text;

    if (username.isNotEmpty && email.isNotEmpty && password.isNotEmpty) {
      try {
        // Call AuthController's signUp method
        final user = await _authController.signUp(
          email,
          password,
          username,
          preferences.isNotEmpty ? preferences : 'No preferences',
        );

        if (user != null) {
          // Sign-Up Successful
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Sign Up Successful!')),
          );

          // Navigate to Sign In page
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => SignInPage()),
          );
        } else {
          // Handle sign-up failure if the user is null
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: Sign Up failed')),
          );
        }
      } catch (e) {
        // Handle any unexpected errors
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } else {
      // Missing fields
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter all fields')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Color(0xffba8fe3),
        iconTheme: IconThemeData(color: Colors.black),
        automaticallyImplyLeading: false,  // This removes the back icon
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Color(0xffba8fe3),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: Colors.black12, blurRadius: 12, offset: Offset(0, 4)),
              ],
            ),
            constraints: BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 20),

                // Username Field
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(color: Colors.black26, blurRadius: 5, offset: Offset(0, 3)),
                    ],
                  ),
                  child: TextField(
                    controller: usernameController,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.person, color: Color(0xffba8fe3)),
                      labelText: 'Username',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(16),
                    ),
                  ),
                ),
                SizedBox(height: 20),

                // Email Field
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(color: Colors.black26, blurRadius: 5, offset: Offset(0, 3)),
                    ],
                  ),
                  child: TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.email, color: Color(0xffba8fe3)),
                      labelText: 'Email Address',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(16),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                ),
                SizedBox(height: 20),

                // Password Field
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(color: Colors.black26, blurRadius: 5, offset: Offset(0, 3)),
                    ],
                  ),
                  child: TextField(
                    controller: passwordController,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.lock, color: Color(0xffba8fe3)),
                      labelText: 'Password',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(16),
                    ),
                    obscureText: true,
                  ),
                ),
                SizedBox(height: 20),

                // Preferences Field
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(color: Colors.black26, blurRadius: 5, offset: Offset(0, 3)),
                    ],
                  ),
                  child: TextField(
                    controller: preferencesController,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.settings, color: Color(0xffba8fe3)),
                      labelText: 'Preferences',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(16),
                    ),
                  ),
                ),
                SizedBox(height: 30),

                // Sign Up Button with sleek design
                ElevatedButton(
                  onPressed: _signUp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xff905cc2),
                    padding: EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 5,
                  ),
                  child: Text('Sign Up', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
                SizedBox(height: 24),

                // Redirect to Sign In Page Text with Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Already have an account?', style: TextStyle(fontSize: 16)),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SignInPage()),
                        );
                      },
                      child: Text('Sign In', style: TextStyle(color: Colors.black, fontSize: 16)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      // Bottom Navigation Bar with the "Please Sign Up to continue" text
      bottomNavigationBar: BottomAppBar(
        color: Color(0xffba8fe3),
        child: Container(
          height: 60,
          alignment: Alignment.center,
          child: Text(
            'Please Sign Up to continue',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
