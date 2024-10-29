import 'package:flutter/material.dart';
import '../Models/categorie.dart';
import '../Controllers/homePage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

//---------------------------Butons---------------------------//

  final List<Color> buttonColors = [
    Colors.red, // Couleur pour HTML/CSS
    Colors.blue, // Couleur pour JavaScript
    Colors.green, // Couleur pour Algorithme
  ];

  static const double buttonPaddingHorizontal = 30.0;
  static const double buttonPaddingVertical = 30.0;
  static const double buttonVerticalSpacing = 2.0;

  Widget _buildButton(Categorie categorie, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: buttonVerticalSpacing),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            onPress(context, categorie);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: buttonColors[index],
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

  //---------------------------Liste des catégories---------------------------//

  List<Categorie> categories = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    onInit().then((value) {
      setState(() {
        categories = value;
        isLoading = false;
      });
    });
  }
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Page d\'Accueil')),
      body: Center(
        child: isLoading
        ? const CircularProgressIndicator()
        : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Tester ces compétences',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Column(
                children: List.generate(categories.length, (index) => _buildButton(categories[index], index)),
              ),
            ],
          ),
      ),  
    );
  }
}
