import 'package:flutter/material.dart';
import 'package:medical_care/screens/auth/login_screen.dart';
import 'package:medical_care/utils/colors.dart';
import 'package:medical_care/widgets/button_widget.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo.png',
            ),
            const SizedBox(
              height: 20,
            ),
            ButtonWidget(
              radius: 100,
              label: 'Get Started',
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
