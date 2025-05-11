import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'page1.dart'; // Importation de la page 1
import 'Homepage.dart'; // Importation de la page 2

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Skin Cancer Detection',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const Page1(), // Page d'accueil
        '/Homepage': (context) => const HomePage(), // Page de détection
      },
    );
  }
}
