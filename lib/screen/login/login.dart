import 'package:flutter/material.dart';
import 'package:app/widgets/login/login_header.dart';
import 'package:app/widgets/login/login_form.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFA8E6CF), Color(0xFF56AB2F), Color(0xFF004E00)],
          ),
        ),
        child: const Center(
          child: Padding(
            padding: EdgeInsets.all(32.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  LoginHeader(),
                  SizedBox(height: 40),
                  LoginForm(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}