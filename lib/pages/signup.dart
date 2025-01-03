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

  // Name validation: Only letters and spaces, no special characters
  String? _validateName(String value) {
    if (value.isEmpty) {
      return 'Please enter your name';
    } else if (!RegExp(r"^[a-zA-Z\s]+$").hasMatch(value)) {
      return 'Name can only contain letters and spaces';
    }
    return null;
  }

  // Email validation: Must be from specific domains
  String? _validateEmail(String value) {
    if (value.isEmpty) {
      return 'Please enter your email';
    } else if (!RegExp(r"^[a-zA-Z0-9._%+-]+@(gmail\.com|yahoo\.com|mail\.com)$")
        .hasMatch(value)) {
      return 'Email must be from @gmail.com, @yahoo.com, or @mail.com';
    }
    return null;
  }

  // NIC validation: 12 characters, letters, and numbers
  String? _validateNIC(String value) {
    if (value.isEmpty) {
      return 'Please enter your NIC';
    } else if (value.length != 12) {
      return 'NIC must be exactly 12 characters';
    } else if (!RegExp(r"^[a-zA-Z0-9]+$").hasMatch(value)) {
      return 'NIC must contain only letters and numbers';
    }
    return null;
  }

  // Password validation: At least one special character
  String? _validatePassword(String value) {
    if (value.isEmpty) {
      return 'Please enter your password';
    } else if (!RegExp(r'^(?=.*?[#?!@$%^&*-]).{6,}$').hasMatch(value)) {
      return 'Password must contain at least one special character';
    }
    return null;
  }

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
                "images/20944881.jpg",
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 10.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildTextField(
                      controller: _nameController,
                      hintText: 'Name',
                      validator: _validateName,
                    ),
                    const SizedBox(height: 10.0),
                    _buildTextField(
                      controller: _emailController,
                      hintText: 'Email',
                      validator: _validateEmail,
                    ),
                    const SizedBox(height: 10.0),
                    _buildTextField(
                      controller: _nicController,
                      hintText: 'NIC',
                      validator: _validateNIC,
                    ),
                    const SizedBox(height: 10.0),
                    _buildTextField(
                      controller: _passwordController,
                      hintText: 'Password',
                      validator: _validatePassword,
                      obscureText: true,
                    ),
                    const SizedBox(height: 10.0),
                    GestureDetector(
                      onTap: _register,
                      child: _buildButton(context, "Sign Up"),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10.0),
            const Text(
              "or LogIn with",
              style: TextStyle(
                  color: Color(0xFF273671),
                  fontSize: 18.0,
                  fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 10.0),
            _buildSocialIcons(),
            const SizedBox(height: 20.0),
            _buildLoginRow(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required String? Function(String) validator,
    bool obscureText = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 0.5, horizontal: 30.0),
      decoration: BoxDecoration(
          color: const Color(0xFFedf0f8),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFA2CFFE), width: 2)), // Add border here
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        validator: (value) => validator(value ?? ''),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hintText,
          hintStyle: const TextStyle(color: Color(0xFFb2b7bf), fontSize: 14.0),
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context, String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
      decoration: BoxDecoration(
        color: const Color(0xFF17C2EC),
        borderRadius: BorderRadius.circular(20),
      ), // Add border here
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
              color: Colors.white, fontSize: 20.0, fontWeight: FontWeight.w500),
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
          height: 30,
          width: 30,
          fit: BoxFit.cover,
        ),
        const SizedBox(width: 30.0),
        Image.asset(
          "images/apple1.png",
          height: 30,
          width: 30,
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
                fontSize: 15.0,
                fontWeight: FontWeight.w500)),
        const SizedBox(width: 5.0),
        GestureDetector(
          onTap: () {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => LogIn()));
          },
          child: const Text(
            "Log In",
            style: TextStyle(
                color: Color(0xFF273671),
                fontSize: 18.0,
                fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}
