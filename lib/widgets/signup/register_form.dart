import 'package:flutter/material.dart';
import 'package:app/screen/login/login.dart';
import 'package:app/widgets/signup/login_redirect.dart';
import 'package:app/services/auth_service.dart';
import 'package:app/user/user_session.dart';
import 'package:app/screen/main_page.dart';

class RegisterForm extends StatefulWidget {

  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();

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


  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final userId = await AuthService().signup(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      passwordConfirm: _passwordConfirmController.text.trim(),
    );

    if (userId != null) {
      if (!mounted) return;
      UserSession().userId = userId;
      await UserSession().saveUserId();
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MyHomePage()));
    } else {
      _showErrorDialog();
    }
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Signup Failed'),
        content: const Text('An error occurred. Please try again.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
        ],
      ),
    );
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
            const SizedBox(height: 10),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Name",
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) => value!.isEmpty ? 'Please enter your name' : null,
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: "Email",
                prefixIcon: Icon(Icons.email),
              ),
              validator: (value) => value!.isEmpty ? 'Please enter your email' : null,
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _passwordController,
              obscureText: !passwordVisible,
              decoration: InputDecoration(
                labelText: "Password",
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(
                    passwordVisible ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      passwordVisible = !passwordVisible;
                    });
                  },
                ),
              ),
              validator: (value) => value!.isEmpty ? 'Please enter your password' : null,
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _passwordConfirmController,
              obscureText: !passwordConfirmVisible,
              decoration: InputDecoration(
                labelText: "Confirm Password",
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(
                    passwordConfirmVisible ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      passwordConfirmVisible = !passwordConfirmVisible;
                    });
                  },
                ),
              ),
              validator: (value) {
                if (value!.isEmpty) return 'Please confirm your password';
                if (value != _passwordController.text) return 'Passwords do not match';
                return null;
              },
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _handleSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightGreen,
                foregroundColor: Colors.black,
                minimumSize: const Size(120, 50),
                textStyle: const TextStyle(fontSize: 20),
              ),
              child: const Text("Register"),
            ),
            const SizedBox(height: 20),
            const LoginRedirect(),
          ],
        ),
      ),
    );
  }
}
