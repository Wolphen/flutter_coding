import 'package:flutter/material.dart';
import '../Models/categorie.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Categorie> categories = [
    Categorie(id: '1', nom: 'HTML/CSS'),
    Categorie(id: '2', nom: 'JavaScript'),
    Categorie(id: '3', nom: 'Algorithme'),
  ];

  static const double buttonPaddingHorizontal = 30.0;
  static const double buttonPaddingVertical = 30.0;
  static const double buttonVerticalSpacing = 2.0;

  Widget _buildButton(Categorie categorie) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: buttonVerticalSpacing),
      child: SizedBox(
        child: ElevatedButton(
          onPressed: () {
            // Action à effectuer lors du clic sur le bouton
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 215, 65, 0),
            padding: const EdgeInsets.symmetric(
              horizontal: buttonPaddingHorizontal,
              vertical: buttonPaddingVertical,
            ),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(5)),
            ),
          ),
          child: Text(
            categorie.nom,
            style: const TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Page d\'Accueil')),
      body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Tester ces compétences',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Column(
              children: categories.map(_buildButton).toList(),
            ),
          ],
      ),
    );
  }
}
