import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'auth/login.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CounterScreen(),
    );
  }
}

class CounterScreen extends StatelessWidget {
  Future<void> checkConnection() async {
    var password = 'root';
    final encodedPassword = Uri.encodeComponent(password);
    var db = await mongo.Db.create('mongodb+srv://root:$encodedPassword@Flutter.d1rxd.mongodb.net/Flutter?retryWrites=true&w=majority&appName=Flutter');
    try {
      // Tente de te connecter
      await db.open();
      print("Connexion réussie à MongoDB !");
      final collection = db.collection('contacts');
      final contacts = await collection.find().toList();
      print(contacts);
    } catch (e) {
      print("Échec de la connexion à MongoDB : $e");
    } finally {
      // Ferme la connexion, même si elle échoue
      await db.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const LoginPage(),
    );
  }
}

class User {
  final String name;
  final String surname;
  final String mail;
  final int age;
  final int adresse_postale;
  final int nb_quizz;
  final bool admin;
  final int motivation;

  User({required this.name, required this.surname, required this.mail, required this.age, required this.adresse_postale,
    required this.nb_quizz, required this.admin, required this.motivation});
}
