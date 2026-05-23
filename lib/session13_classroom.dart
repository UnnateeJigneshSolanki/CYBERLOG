import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}
const bgColor = Color(0xFF0D1117);  
const accent = Color(0xFF00E5FF);  
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
          filled: true,
          fillColor: const Color(0xFF161B22),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),borderSide: BorderSide.none, ), ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(backgroundColor: accent,foregroundColor: Colors.black,),),),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return const HomePage();
          } return const AuthPage();
        },),);}}
class AuthPage extends StatefulWidget {
  const AuthPage({super.key});
  @override
  State<AuthPage> createState() => _AuthPageState();
}
class _AuthPageState extends State<AuthPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool isLogin = true;
  Future<void> _submit() async {
    try {
      if (isLogin) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      } else {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );}
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }}
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text(isLogin ? "LOGIN" : "REGISTER") ),
      body: Padding(padding: const EdgeInsets.all(16),
        child: Column( children: [
            TextField( controller: _emailController,decoration: const InputDecoration(labelText: "Email"),),
            const SizedBox(height: 12),
            TextField(controller: _passwordController, decoration: const InputDecoration(labelText: "Password"), obscureText: true,),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _submit,child: Text(isLogin ? "LOGIN" : "REGISTER")),
            TextButton(
              onPressed: () => setState(() => isLogin = !isLogin),
              child: Text(isLogin ? "Create account" : "Already have an account?",style: const TextStyle(color: accent),
              ), ),],),),);}}
class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final notesRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('notes');
    final noteController = TextEditingController();
    return Scaffold(
      appBar: AppBar(title: const Text("MY NOTES"),
        actions: [IconButton( icon: const Icon(Icons.logout),
            onPressed: () => FirebaseAuth.instance.signOut(),)],),
      body: Column( children: [
          Padding(padding: const EdgeInsets.all(8),
            child: Row( children: [
                Expanded(child: TextField(controller: noteController,
                    decoration:const InputDecoration(hintText: "Enter note..."),),),
                IconButton( icon: const Icon(Icons.add, color: accent),
                  onPressed: () {
                    if (noteController.text.isNotEmpty) {
                      notesRef.add({
                        'text': noteController.text,'createdAt': FieldValue.serverTimestamp(),
                      }); noteController.clear();
                      }}, )],),),
          Expanded(child: StreamBuilder<QuerySnapshot>(
              stream:
                  notesRef.orderBy('createdAt', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final docs = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    return ListTile( tileColor: const Color(0xFF161B22),
                      title: Text(data['text'] ?? "",style: const TextStyle(color: Colors.white),),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: accent),
                        onPressed: () => notesRef.doc(docs[index].id).delete(),
                      ), ); }, );},
            ),
          ),
        ],
      ),
    );
  }
}
