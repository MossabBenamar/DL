import 'package:flutter_test/flutter_test.dart';

import 'package:cancer_diagno_test1/main.dart'; // Importez votre application principale

void main() {
  testWidgets('Test de la présence d\'un texte', (WidgetTester tester) async {
    // Construire le widget pour la page principale
    await tester.pumpWidget(MyApp());

    // Vérifier si le texte "Skin cancer Diagno" est présent dans l'interface utilisateur
    expect(find.text('Skin cancer Diagno'), findsOneWidget);
  });

  testWidgets('Test du bouton dans l\'interface', (WidgetTester tester) async {
    // Construire le widget pour la page principale
    await tester.pumpWidget(const MyApp());

    // Trouver un bouton en utilisant son texte
    final buttonFinder = find.text('Commencer');

    // Vérifier si le bouton est affiché une seule fois
    expect(buttonFinder, findsOneWidget);

    // Simuler un clic sur le bouton
    await tester.tap(buttonFinder);

    // Attendre que les animations soient terminées
    await tester.pump();

    // Ajouter ici des assertions pour vérifier le comportement après le clic
    // Par exemple, vérifier si une autre page s'affiche ou si un état change
  });
}
