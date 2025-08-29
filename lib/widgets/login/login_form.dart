import 'package:app/widgets/common/throbber.dart';
import 'package:flutter/material.dart';
import 'package:app/screen/main_page.dart';
import 'package:app/user/user_session.dart';
import 'package:app/services/auth_service.dart';
import 'package:app/screen/signup/signup.dart';
import 'package:app/widgets/login/login_header.dart';
import 'package:app/widgets/login/login_form.dart';
import 'package:app/widgets/login/register_redirect.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  bool passwordVisible = false;
  bool _isLoading = false;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final userId = await AuthService().signin(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      context: context,
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (userId != null) {
      UserSession().userId = userId;
      await UserSession().saveUserId();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MyHomePage()),
      );
    } else {
      showDialog(
        context: context,
        builder: (_) => const AlertDialog(
          title: Text('Login Failed'),
          content: Text('Incorrect email or password.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5)),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _emailController,
              validator: (value) => value!.isEmpty ? 'Please enter your email' : null,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email),
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _passwordController,
              obscureText: !passwordVisible,
              validator: (value) => value!.isEmpty ? 'Please enter your password' : null,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(
                    passwordVisible ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey,
                  ),
                  onPressed: () => setState(() => passwordVisible = !passwordVisible),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const Throbber()
                : ElevatedButton(
                    onPressed: () => _handleLogin(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightGreen,
                      foregroundColor: Colors.black,
                      minimumSize: const Size(120, 50),
                      textStyle: const TextStyle(fontSize: 20),
                    ),
                    child: const Text('Login'),
                  ),
            const SizedBox(height: 20),
            const RegisterRedirect(),
          ],
        ),
      ),
    );
  }
}
