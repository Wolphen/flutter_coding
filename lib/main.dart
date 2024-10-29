import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;

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
    var db = await mongo.Db.create('mongodb+srv://root:$encodedPassword@flutter.d1rxd.mongodb.net/?retryWrites=true&w=majority&appName=Flutter');
    try {
      // Tente de te connecter
      await db.open();
      print("Connexion réussie à MongoDB !");
    } catch (e) {
      print("Échec de la connexion à MongoDB : $e");
    } finally {
      // Ferme la connexion, même si elle échoue
      await db.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("MongoDB Connection Check")),
      body: Center(
        child: ElevatedButton(
          onPressed: checkConnection,
          child: Text('Vérifier la connexion à MongoDB'),
        ),
      ),
    );
  }
}
