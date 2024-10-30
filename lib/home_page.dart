import 'package:flutter/material.dart';
import './bdd/session_manager.dart';
import 'header.dart';

class HomePage extends StatefulWidget {
  final Map<String, dynamic> userInfo;

  const HomePage({Key? key, required this.userInfo}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late String pseudo;
  late bool isAdmin;
  late Object id;

  @override
  void initState() {
    super.initState();

    pseudo = widget.userInfo['nom'] ?? 'Utilisateur';
    isAdmin = widget.userInfo['admin'] ?? false;
    id = widget.userInfo['_id'].toString();
  }

  // Fonction de déconnexion de l'utilisateur
  void _logout() async {
    await SessionManager.clearToken();
    Navigator.pushReplacementNamed(context, '/login'); // Redirige vers la page de connexion après déconnexion
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Header(
        nom: pseudo,
        isAdmin: isAdmin,
        id: id,
        onLogout: _logout,
      ),
      body: Center(
        child: Text(
          "Bienvenue sur la page d'accueil, $pseudo",
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
