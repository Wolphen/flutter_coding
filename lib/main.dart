import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth/signUp.dart';
import 'splash_screen.dart';
import 'bdd/connectToDTB.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DropDownButton()),
        Provider(create: (_) => MongoDBService()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(), // La première page pour vérifier la connexion
        '/login': (context) => const SignUpPage(),
        // Supprimez la route nommée vers '/home' ici, car HomePage nécessite des paramètres.
      },
    );
  }
}
