import 'package:flutter/material.dart';
import 'package:app/screen/login/login.dart';
import 'package:app/services/auth_service.dart';
import 'package:app/screen/main_page.dart';
import 'package:app/user/user_session.dart';
import 'package:app/widgets/login/login_header.dart';
import 'package:app/widgets/signup/register_form.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();

  bool nameError = false;
  bool emailError = false;
  bool passwordError = false;
  bool passwordConfirmError = false;

  bool passwordVisible = false;
  bool passwordConfirmVisible = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    super.dispose();
  }

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
        padding: const EdgeInsets.all(32.0),
         child: const Center(
          child: Padding(
            padding: EdgeInsets.all(32.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  LoginHeader(),
                  SizedBox(height: 40),
                  RegisterForm(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
