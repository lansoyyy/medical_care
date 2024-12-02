import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:medical_care/screens/auth/login_screen.dart';
import 'package:medical_care/screens/auth/signup_screen.dart';
import 'package:medical_care/screens/home_screen.dart';
import 'package:medical_care/services/add_user.dart';
import 'package:medical_care/utils/colors.dart';
import 'package:medical_care/widgets/button_widget.dart';
import 'package:medical_care/widgets/text_widget.dart';
import 'package:medical_care/widgets/textfield_widget.dart';
import 'package:medical_care/widgets/toast_widget.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final name = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primary,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/logo.png',
                height: 300,
              ),
              TextFieldWidget(
                label: 'Full Name',
                controller: name,
              ),
              TextFieldWidget(
                label: 'Email',
                controller: email,
              ),
              TextFieldWidget(
                label: 'Password',
                controller: password,
                showEye: true,
                isObscure: true,
              ),
              const SizedBox(height: 30),
              ButtonWidget(
                label: 'Signup',
                onPressed: () {
                  register(context);
                },
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextWidget(
                    color: Colors.white,
                    text: "Already have an account?",
                    fontSize: 12,
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const LoginScreen()));
                    },
                    child: TextWidget(
                      color: Colors.white,
                      fontFamily: 'Bold',
                      text: "Login",
                      fontSize: 12,
                    ),
                  )
                ],
              ),
              const SizedBox(height: 25),
            ],
          ),
        ),
      ),
    );
  }

  register(context) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email.text, password: password.text);

      addUser(name.text, email.text);

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
      showToast("Registered Successfully!");

      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        showToast('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        showToast('The account already exists for that email.');
      } else if (e.code == 'invalid-email') {
        showToast('The email address is not valid.');
      } else {
        showToast(e.toString());
      }
    } on Exception catch (e) {
      showToast("An error occurred: $e");
    }
  }
}
