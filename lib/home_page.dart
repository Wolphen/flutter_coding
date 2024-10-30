import 'package:flutter/material.dart';
import './bdd/session_manager.dart';

class HomePage extends StatefulWidget {
  final Map<String, dynamic> userInfo; // Reçoit les informations utilisateur lors de la connexion

  const HomePage({Key? key, required this.userInfo}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late String pseudo;
  late String email;
  late String userId;
  late String admin;

  @override
  void initState() {
    super.initState();

    // Initialisation des informations utilisateur depuis `userInfo`
    pseudo = widget.userInfo['nom'] ?? 'Utilisateur';
    email = widget.userInfo['mail'] ?? 'Email non disponible';
    userId = widget.userInfo['_id'].toString();
    admin = widget.userInfo['admin'].toString();

  }


  // Fonction de déconnexion de l'utilisateur
  void _logout() async {
    await SessionManager.clearToken();
    Navigator.pushReplacementNamed(context, '/login'); // Redirige vers la page de connexion après déconnexion
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Accueil"),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pseudo,
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                ),
                Text(
                  email,
                  style: const TextStyle(fontSize: 14, color: Colors.white70),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: Center(
        child: Text(
          "Bienvenue, $pseudo\n mail : $email \n id : $userId \n admin: $admin",
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
