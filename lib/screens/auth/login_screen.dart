import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:medical_care/screens/auth/signup_screen.dart';
import 'package:medical_care/screens/home_screen.dart';
import 'package:medical_care/utils/colors.dart';
import 'package:medical_care/widgets/button_widget.dart';
import 'package:medical_care/widgets/text_widget.dart';
import 'package:medical_care/widgets/textfield_widget.dart';
import 'package:medical_care/widgets/toast_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
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
                label: 'Email',
                controller: email,
              ),
              TextFieldWidget(
                label: 'Password',
                controller: password,
                showEye: true,
                isObscure: true,
              ),
              Padding(
                padding: const EdgeInsets.only(right: 25),
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: GestureDetector(
                    onTap: () {
                      forgotPassword();
                    },
                    child: TextWidget(
                      text: 'Forgot Password?',
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              ButtonWidget(
                label: 'Login',
                onPressed: () {
                  login(context);
                },
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextWidget(
                    color: Colors.white,
                    text: "Doesn't have an account?",
                    fontSize: 12,
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const SignupScreen()));
                    },
                    child: TextWidget(
                      color: Colors.white,
                      fontFamily: 'Bold',
                      text: "Signup",
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

  forgotPassword() {
    showDialog(
      context: context,
      builder: ((context) {
        final formKey = GlobalKey<FormState>();
        final TextEditingController emailController = TextEditingController();

        return AlertDialog(
          backgroundColor: Colors.grey[300],
          title: TextWidget(
            text: 'Forgot Password',
            fontSize: 18,
            color: Colors.black,
            fontFamily: 'Bold',
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFieldWidget(
                  width: 300,
                  hint: 'Email',
                  textCapitalization: TextCapitalization.none,
                  inputType: TextInputType.emailAddress,
                  label: 'Email',
                  borderColor: secondary,
                  controller: emailController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an email address';
                    }
                    final emailRegex =
                        RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                    if (!emailRegex.hasMatch(value)) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: (() {
                Navigator.pop(context);
              }),
              child: TextWidget(
                text: 'Cancel',
                fontSize: 12,
                color: Colors.black,
                fontFamily: 'Bold',
              ),
            ),
            TextButton(
              onPressed: (() async {
                if (formKey.currentState!.validate()) {
                  try {
                    Navigator.pop(context);
                    await FirebaseAuth.instance
                        .sendPasswordResetEmail(email: emailController.text);
                    showToast(
                        'Password reset link sent to ${emailController.text}');
                  } catch (e) {
                    String errorMessage = '';

                    if (e is FirebaseException) {
                      switch (e.code) {
                        case 'invalid-email':
                          errorMessage = 'The email address is invalid.';
                          break;
                        case 'user-not-found':
                          errorMessage =
                              'The user associated with the email address is not found.';
                          break;
                        default:
                          errorMessage =
                              'An error occurred while resetting the password.';
                      }
                    } else {
                      errorMessage =
                          'An error occurred while resetting the password.';
                    }

                    showToast(errorMessage);
                    Navigator.pop(context);
                  }
                }
              }),
              child: TextWidget(
                text: 'Continue',
                fontSize: 14,
                color: Colors.black,
                fontFamily: 'Bold',
              ),
            ),
          ],
        );
      }),
    );
  }

  login(context) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email.text, password: password.text);

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        showToast("No user found with that email.");
      } else if (e.code == 'wrong-password') {
        showToast("Wrong password provided for that user.");
      } else if (e.code == 'invalid-email') {
        showToast("Invalid email provided.");
      } else if (e.code == 'user-disabled') {
        showToast("User account has been disabled.");
      } else {
        showToast("An error occurred: ${e.message}");
      }
    } on Exception catch (e) {
      showToast("An error occurred: $e");
    }
  }
}
