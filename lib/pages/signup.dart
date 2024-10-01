import 'package:vaccination/components/bottom_nav_bar.dart';

import 'home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'login.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nicController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _register() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
            email: _emailController.text, password: _passwordController.text);

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user?.uid)
            .set({
          'name': _nameController.text,
          'email': _emailController.text,
          'nic': _nicController.text,
        });

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
              "Registered Successfully",
              style: TextStyle(fontSize: 20.0),
            )));

        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => BottomNavBar()));
      } on FirebaseAuthException catch (e) {
        String message;
        if (e.code == 'weak-password') {
          message = "Password provided is too weak.";
        } else if (e.code == 'email-already-in-use') {
          message = "An account already exists for that email.";
        } else {
          message = "An error occurred: ${e.message}";
        }
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Colors.orangeAccent,
            content: Text(
              message,
              style: TextStyle(fontSize: 18.0),
            )));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Colors.redAccent,
            content: Text(
              "Unexpected error: ${e.toString()}",
              style: TextStyle(fontSize: 18.0),
            )));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              child: Image.asset(
                "images/car.PNG",
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 30.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildTextField(
                      controller: _nameController,
                      hintText: 'Name',
                      validatorText: 'Please enter your name',
                    ),
                    const SizedBox(height: 30.0),
                    _buildTextField(
                      controller: _emailController,
                      hintText: 'Email',
                      validatorText: 'Please enter your email',
                    ),
                    const SizedBox(height: 30.0),
                    _buildTextField(
                      controller: _nicController,
                      hintText: 'NIC',
                      validatorText: 'Please enter your NIC',
                    ),
                    const SizedBox(height: 30.0),
                    _buildTextField(
                      controller: _passwordController,
                      hintText: 'Password',
                      validatorText: 'Please enter your password',
                      obscureText: true,
                    ),
                    const SizedBox(height: 30.0),
                    GestureDetector(
                      onTap: _register,
                      child: _buildButton(context, "Sign Up"),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40.0),
            const Text(
              "or LogIn with",
              style: TextStyle(
                  color: Color(0xFF273671),
                  fontSize: 22.0,
                  fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 30.0),
            _buildSocialIcons(),
            const SizedBox(height: 40.0),
            _buildLoginRow(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required String validatorText,
    bool obscureText = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 30.0),
      decoration: BoxDecoration(
          color: const Color(0xFFedf0f8),
          borderRadius: BorderRadius.circular(30)),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return validatorText;
          }
          return null;
        },
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hintText,
          hintStyle: const TextStyle(color: Color(0xFFb2b7bf), fontSize: 18.0),
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context, String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 13.0, horizontal: 30.0),
      decoration: BoxDecoration(
          color: const Color(0xFF273671), borderRadius: BorderRadius.circular(30)),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
              color: Colors.white, fontSize: 22.0, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  Widget _buildSocialIcons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          "images/google.png",
          height: 45,
          width: 45,
          fit: BoxFit.cover,
        ),
        const SizedBox(width: 30.0),
        Image.asset(
          "images/apple1.png",
          height: 50,
          width: 50,
          fit: BoxFit.cover,
        ),
      ],
    );
  }

  Widget _buildLoginRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Already have an account?",
            style: TextStyle(
                color: Color(0xFF8c8e98),
                fontSize: 18.0,
                fontWeight: FontWeight.w500)),
        const SizedBox(width: 5.0),
        GestureDetector(
          onTap: () {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => LogIn()));
          },
          child: const Text(
            "LogIn",
            style: TextStyle(
                color: Color(0xFF273671),
                fontSize: 20.0,
                fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}
