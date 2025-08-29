import 'package:app/widgets/common/throbber.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:app/screen/base_page.dart';
import 'package:app/screen/login/login.dart';
import 'package:app/user/user_session.dart';
import 'package:app/services/auth_service.dart';


class SettingsPage extends BasePage {
  SettingsPage({super.key})
      : super(
    title: 'Settings',
    backgroundColor: Colors.white,
    buildChild: (context) => SettingsPageState().buildSettingsContent(context),
  );
}

class SettingsPageState {
  void _ActionConfirmation(BuildContext context, String title, String message, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            child: const Text("Confirm"),
          ),
        ],
      ),
    );
  }

  Widget buildSettingsContent(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: const Color(0xFFF8F8E7),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 140),
        child: SizedBox(
          height: MediaQuery.of(context).size.height - 250,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(Icons.person_2_rounded, size: 200, color: Colors.green[900]),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: IconButton(
                        icon: Icon(Icons.edit, size: 40, color: Colors.green[900]),
                        tooltip: 'Edit Profile',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const EditProfilePage()),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 0),
              FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('user')
                    .doc(FirebaseAuth.instance.currentUser?.uid)
                    .get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: Throbber());
                  }
                  if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
                    return const Center(
                      child: Text(
                        "My Profile",
                        style: TextStyle(fontSize: 24, color: Colors.black),
                      ),
                    );
                  }
                  final data = snapshot.data!.data() as Map<String, dynamic>;
                  final name = data['name'] ?? 'My Profile';
                  return Center(
                    child: Text(
                      name,
                      style: const TextStyle(fontSize: 27, color: Colors.black, fontWeight: FontWeight.w600 ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 100),
              IntrinsicHeight(
                child: Column(
                  children: [
                    Expanded(
                      child: SizedBox(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            _ActionConfirmation(
                              context,
                              "Logout",
                              "Are you sure you want to logout?",
                                  () {
                                UserSession().clear();
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                                      (route) => false,
                                );
                              },
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 60),
                            textStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                            elevation: 8
                          ),
                          icon: const Icon(Icons.logout, size: 26),
                          label: const Text('Logout'),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    SizedBox (
                        child: ElevatedButton.icon(
                          onPressed: () {
                            _ActionConfirmation(
                              context,
                              "Delete Account",
                              "Are you sure you want to delete your account? This action is irreversible.",
                                  () async {
                                final user = FirebaseAuth.instance.currentUser;
                                if (user == null) return;
                                try {
                                  await FirebaseFirestore.instance.collection('users').doc(user.uid).delete();
                                  await user.delete();
                                  UserSession().clear();
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                                        (route) => false,
                                  );
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error deleting your account: $e')));
                                }
                              },
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 45),
                            textStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                            elevation: 8
                          ),
                          icon: const Icon(Icons.delete_forever, size: 26),
                          label: const Text('Delete Account'),
                        ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class EditProfilePage extends StatelessWidget {
  const EditProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8E7),
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Edit Profile',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
        ),
        backgroundColor: Colors.green,
      ),
      body: Center(
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 24),
            children: [
              ListTile(
                leading: const Icon(Icons.person, size: 30),
                title: const Text('Change Name',
                    style: TextStyle(fontSize: 20)),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const ChangeNamePage())).then((value) {
                    if (value == true) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => SettingsPage()),
                      );
                    }
                  });
                },
              ),
              ListTile(
                leading: const Icon(Icons.email, size: 30),
                title: const Text('Change Email',
                    style: TextStyle(fontSize: 20)),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const ChangeEmailPage()));
                },
              ),
              ListTile(
                leading: const Icon(Icons.lock, size: 30),
                title: const Text('Change Password',
                    style: TextStyle(fontSize: 20)),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const ChangePasswordPage()));
                },
              ),
            ],
          ),
        ),
    );
  }
}

class ChangeNamePage extends StatelessWidget {
  const ChangeNamePage({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController nameController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          title: const Text('Change Name',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
          ), backgroundColor: Colors.green),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'New Name'),
            ),
            const SizedBox(height: 50),
            ElevatedButton(
              onPressed: () async {
                final user = FirebaseAuth.instance.currentUser;
                if (user != null && nameController.text.isNotEmpty) {
                  try {
                    await FirebaseFirestore.instance
                        .collection('user')
                        .doc(user.uid)
                        .update({'name': nameController.text});
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Name updated successfully')));
                    Navigator.pop(context, true);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromRGBO(61, 131, 73, 1.0),
                padding: EdgeInsets.all(20),
                elevation: 5
              ),
                child: const Text('Update Name',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20
                  )
                ),
            )
          ],
        ),
      ),
    );
  }
}





class ChangeEmailPage extends StatefulWidget {
  const ChangeEmailPage({super.key});

  @override
  State<ChangeEmailPage> createState() => _ChangeEmailPageState();
}

class _ChangeEmailPageState extends State<ChangeEmailPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  Future<void> _sendVerificationEmail(String newEmail) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      if (await AuthService().emailAlreadyExists(newEmail)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('This email is already in use by another account.'),
          ),
        );
        return;
      }

      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: passwordController.text.trim(),
      );

      await user.reauthenticateWithCredential(credential);

      await user.verifyBeforeUpdateEmail(newEmail);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Verification email sent to $newEmail. Please check your inbox and verify to complete the change.',
          ),
        ),
      );

      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('This email is already in use by another account.'),
          ),
        );
      } else if (e.code == 'wrong-password') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Incorrect password.'),
          ),
        );
      } else if (e.code == 'user-mismatch') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('The provided credentials do not match the current user.'),
          ),
        );
      } else if (e.code == 'user-not-found') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User not found. Please log in again.'),
          ),
        );
      } else if (e.code == 'invalid-credential') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid credentials.'),
          ),
        );
      } else if (e.code == 'too-many-requests') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Too many attempts. Try again later.'),
          ),
        );
      } else if (e.code == 'requires-recent-login') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please log in again to complete this action.'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unexpected error: ${e.message}'),
          ),
        );
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Change Email',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            )
        ),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'New Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 40),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Current Password'),
              obscureText: true,
            ),
            const SizedBox(height: 50),
            isLoading
                ? const Throbber()
                : ElevatedButton(
              onPressed: () async {
                final newEmail = emailController.text.trim();
                final password = passwordController.text.trim();

                if (newEmail.isEmpty || password.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill in all fields.')),
                  );
                  return;
                }

                setState(() {
                  isLoading = true;
                });

                await _sendVerificationEmail(newEmail);

                setState(() {
                  isLoading = false;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromRGBO(61, 131, 73, 1.0),
                padding: EdgeInsets.all(20),
                elevation: 5
              ),
              child: const Text('Send Verification Email',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20
                  )
              ),
            ),
          ],
        ),
      ),
    );
  }
}







class ChangePasswordPage extends StatelessWidget {
  const ChangePasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController passwordController = TextEditingController();
    final TextEditingController oldPasswordController = TextEditingController();


    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.green,
          title: const Text('Change Password',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              )
          ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: oldPasswordController,
              decoration: const InputDecoration(labelText: 'Old Password'),
              obscureText: true,
            ),

            SizedBox(height:40),

            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'New Password'),
              obscureText: true,
            ),

            const SizedBox(height: 50),

            ElevatedButton(
              onPressed: () async {
                final user = FirebaseAuth.instance.currentUser;

                if (oldPasswordController.text.isEmpty || passwordController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill in all fields.')),
                  );
                  return;
                }


                if (user != null && passwordController.text.isNotEmpty && oldPasswordController.text.isNotEmpty) {
                  try {
                    final cred = EmailAuthProvider.credential(
                        email: user.email!,
                        password: oldPasswordController.text,
                    );

                    await user.reauthenticateWithCredential(cred);
                    await user.updatePassword(passwordController.text);

                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Password updated successfully')),
                    );
                    Navigator.pop(context);
                  } on FirebaseAuthException catch (e) {
                    String message;

                    switch (e.code) {
                      case 'wrong-password':
                        message = 'Your old password is wrong.';
                        break;
                      case 'weak-password':
                        message = 'Your new password is weak.';
                        break;
                      case 'requires-recent-login':
                        message = 'Try to login again, before changing your password';
                        break;
                      default:
                        message = 'Error: ${e.message}';
                    }

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(message)),
                    );
                  }

                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromRGBO(61, 131, 73, 1.0),
                padding: EdgeInsets.all(20),
                elevation: 5
              ),
              child: const Text('Update Password',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20
                  )
              ),
            )
          ],
        ),
      ),
    );
  }
}
