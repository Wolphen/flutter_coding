import 'package:flutter/material.dart';
import '../Models/categorie.dart';
import '../Controllers/homePage.dart';
import '../bdd/session_manager.dart';
import '../header.dart';


class HomePage extends StatefulWidget {
  final Map<String, dynamic> userInfo;

  const HomePage({super.key, required this.userInfo});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //---------------------------Liste des catégories---------------------------//
  late String pseudo;
  late bool isAdmin;
  late Object id;

  void _logout() async {
    await SessionManager.clearToken();
    Navigator.pushReplacementNamed(context, '/login'); // Redirige vers la page de connexion après déconnexion
  }

  List<Categorie> categories = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    pseudo = widget.userInfo['nom'] ?? 'Utilisateur';
    isAdmin = widget.userInfo['admin'] ?? false;
    id = widget.userInfo['_id'] ?? 'pas d\'id';
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
      appBar: Header(
        nom: pseudo,
        isAdmin: isAdmin,
        id: id,
        onLogout: _logout,
      ),      body: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Text(
                'Tester ces compétences:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: GridView.builder(
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
          ],
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
        onPress(context, categorie, widget.userInfo); // Passez `userInfo` ici
      },
      child: Card(
        color: buttonColors[index % buttonColors.length],
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
