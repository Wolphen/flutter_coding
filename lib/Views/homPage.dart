import 'package:flutter/material.dart';
import '../Models/categorie.dart';
import '../Controllers/homePage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Page d\'Accueil')),
      body: Center(
        child: isLoading
        ? const CircularProgressIndicator()
        : GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10.0,
              mainAxisSpacing: 10.0,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              return _buildCard(categories[index], index);
            },
          ),
      ),  
    );
  }
//---------------------------Cards---------------------------//

  final List<Color> buttonColors = [
    Colors.red, // Couleur pour HTML/CSS
    Colors.blue, // Couleur pour JavaScript
    Colors.green, // Couleur pour Algorithme
  ];

  Widget _buildCard(Categorie categorie, int index) {
    return GestureDetector(
      onTap: () {
        onPress(context, categorie);
      },
      child: Card(
        color: buttonColors[index],
        child: Center(
          child: Text(
            categorie.nom,
            style: const TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
      ),
    );
  }
}
