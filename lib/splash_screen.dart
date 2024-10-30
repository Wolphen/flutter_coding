import 'package:flutter/material.dart';
import 'home_page.dart';
import 'bdd/connectToDTB.dart';
import './bdd/session_manager.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeApp();
    });
  }

  Future<void> _initializeApp() async {
    final mongoDBService = Provider.of<MongoDBService>(context, listen: false);

    // Assure que MongoDB est connecté avant de continuer
    await mongoDBService.connect();
    final isConnected = mongoDBService.isConnected();

    if (isConnected) {
      final isLoggedIn = await SessionManager.isUserLoggedIn();
      if (isLoggedIn) {
        final userInfo = await SessionManager.getUserInfo(); // Récupère les informations de l'utilisateur
        if (userInfo != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(userInfo: userInfo),
            ),
          );
        } else {
          print("Les informations utilisateur sont introuvables, redirection vers la page de connexion.");
          Navigator.pushReplacementNamed(context, '/login');
        }
      } else {
        Navigator.pushReplacementNamed(context, '/login');
      }
    } else {
      // Gérer la connexion échouée
      print("Impossible de se connecter à MongoDB.");
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()), // Indicateur de chargement
    );
  }
}
