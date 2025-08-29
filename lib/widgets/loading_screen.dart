import 'package:app/widgets/common/throbber.dart';
import 'package:flutter/material.dart';
import 'package:app/screen/main_page.dart';
import 'package:app/user/user_session.dart';
//import 'package:app/screen/login_page.dart';
import 'package:app/screen/login/login.dart';



class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  LoadingScreenState createState() => LoadingScreenState();
}

class LoadingScreenState extends State<LoadingScreen> {

  @override
  void initState() {
    super.initState();
    _checkUserSession();
  }

  void _checkUserSession() async {
    await UserSession().loadUserId(); 

    if (!mounted) return;
    
    if (UserSession().userId != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MyHomePage()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFA8E6CF), // Verde claro
              Color(0xFF56AB2F), // Verde médio
              Color(0xFF004E00), // Verde escuro
            ],
          ),
        ),
        child: Center(
          child: Throbber(),
        ),
      ),
    );
  }
}

