import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController =
      TextEditingController();

  final TextEditingController _passwordController =
      TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    print('Username: ${_usernameController.text}');
    print('Password: ${_passwordController.text}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 203, 111, 184),

      appBar: AppBar(
        title: const Text(
          "Login",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 203, 111, 184),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,

          children: [
            const Text(
              "WELCOME TO LOGIN SCREEN",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 40),

            TextField(
              controller: _usernameController,
              keyboardType: TextInputType.text,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white,
              ),

              decoration: const InputDecoration(
                labelText: "Enter your username",
                labelStyle: TextStyle(color: Colors.black),
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: _passwordController,
              obscureText: true,
              keyboardType: TextInputType.visiblePassword,

              style: const TextStyle(
                fontSize: 18,
                color: Colors.white,
              ),

              decoration: const InputDecoration(
                labelText: "Enter your password",
                labelStyle: TextStyle(color: Colors.black),
              ),
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: _login,

              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor:
                    const Color.fromARGB(255, 87, 16, 100),
              ),

              child: const Text(
                "Sign In",
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}