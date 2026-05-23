import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'firebase_options.dart';
const bgColor = Color(0xFF0D1117);
const accent = Color(0xFF00E5FF);
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await Hive.initFlutter();
  await Hive.openBox('logs');
  await Hive.openBox('settings');
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: bgColor,
        colorScheme: const ColorScheme.dark(primary: accent),
        appBarTheme: const AppBarTheme(
          backgroundColor: bgColor, foregroundColor: accent,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true, fillColor: const Color(0xFF161B22),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),),
        elevatedButtonTheme: ElevatedButtonThemeData(style: ElevatedButton.styleFrom(
            backgroundColor: accent,foregroundColor: Colors.black, ), ), ),
      home: const Root(),);}}
class Root extends StatelessWidget {
  const Root({super.key});
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasData) {
          return const HomePage();
        } else {
          return const AuthPage();
        }},); }}
class AuthPage extends StatefulWidget {
  const AuthPage({super.key});
  @override
  State<AuthPage> createState() => _AuthPageState();
  }
class _AuthPageState extends State<AuthPage> {
  final emailCtrl = TextEditingController(); final passCtrl = TextEditingController();
  bool login = true;
  Future<void> submit() async {
    try {
      if (login) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailCtrl.text.trim(), password: passCtrl.text.trim(),
        );
      } else {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailCtrl.text.trim(), password: passCtrl.text.trim(),
        ); }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      } }}
  @override
  void dispose() {
    emailCtrl.dispose(); passCtrl.dispose(); super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(login ? "LOGIN" : "REGISTER")),
      body: Padding( padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField( controller: emailCtrl, decoration: const InputDecoration(labelText: "Email"), ),
            const SizedBox(height: 12),
            TextField( controller: passCtrl,  decoration: const InputDecoration(labelText: "Password"), obscureText: true, ),
            const SizedBox(height: 20),
            ElevatedButton( onPressed: submit, child: Text(login ? "LOGIN" : "REGISTER"), ),
            TextButton( onPressed: () => setState(() => login = !login),
              child: Text(login ? "Create account" : "Already have an account?", style: const TextStyle(color: accent),
              ), ),],),),);}}

/* -------------------- HOME PAGE -------------------- */

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final noteCtrl = TextEditingController();

  @override
  void dispose() {
    noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loggedIn = FirebaseAuth.instance.currentUser != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text("CYBER LOG"),
        actions: [
          IconButton(
            icon: Icon(loggedIn ? Icons.logout : Icons.login),
            onPressed: () {
              if (loggedIn) {
                FirebaseAuth.instance.signOut();
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AuthPage()),
                );
              }
            },
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: noteCtrl,
                    decoration: const InputDecoration(hintText: "Enter log..."),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add, color: accent),
                  onPressed: () async {
                    if (noteCtrl.text.isNotEmpty) {
                      await LocalSync.saveLog(noteCtrl.text);
                      noteCtrl.clear();
                    }
                  },
                )
              ],
            ),
          ),
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: Hive.box('logs').listenable(),
              builder: (context, Box box, _) {
                if (box.isEmpty) {
                  return const Center(
                    child: Text("No logs yet", style: TextStyle(color: Colors.grey)),
                  );
                }

                final logs = box.values.toList().reversed.toList();

                return ListView.builder(
                  itemCount: logs.length,
                  itemBuilder: (context, index) {
                    final log = logs[index];
                    final logText =
                        (log is Map && log['text'] != null) ? log['text'].toString() : '';

                    return ListTile(
                      tileColor: const Color(0xFF161B22),
                      title: Text(
                        logText,
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
class LocalSync {
  static final _logBox = Hive.box('logs');
  static final _settingsBox = Hive.box('settings');
  static final _firestore = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;
  static Future<bool> _online() async {
    final r = await Connectivity().checkConnectivity();
    return r != ConnectivityResult.none;
  }
  static Future<void> saveLog(String text) async {
    final log = {
      'text': text,
      'time': DateTime.now().toIso8601String(),
    };
    _logBox.add(log);
    if (_auth.currentUser != null && await _online()) {
      try {
        await _firestore
            .collection('users')
            .doc(_auth.currentUser!.uid)
            .collection('logs')
            .add(log);
      } catch (e) {
        debugPrint('Firestore sync failed: $e');
      }} }
  static Future<void> saveSetting(String key, dynamic value) async {
    _settingsBox.put(key, value);

    if (_auth.currentUser != null && await _online()) {
      try {
        await _firestore
            .collection('users')
            .doc(_auth.currentUser!.uid)
            .collection('settings')
            .doc(key)
            .set({'value': value});
      } catch (e) {
        debugPrint('Firestore settings sync failed: $e');
      }}}}
