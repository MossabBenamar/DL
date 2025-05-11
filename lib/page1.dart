import 'package:flutter/material.dart';

class Page1 extends StatelessWidget {
  const Page1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Affichage du logo
            Image.asset('assets/images/logo_skin_cancer2.png',
                width: 200), // Redimensionner l'image
            const SizedBox(height: 50), // Espacement entre l'image et le bouton
            ElevatedButton(
              onPressed: () {
                // Naviguer vers la page 2 (détection)
                Navigator.pushNamed(context, '/Homepage');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue, // Couleur de fond du bouton
                padding: const EdgeInsets.symmetric(
                    horizontal: 50, vertical: 15), // Taille du bouton
              ),
              child: const Text('Get Started', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
