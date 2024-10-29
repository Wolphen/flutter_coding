import 'package:flutter/material.dart';
import '../Models/categorie.dart';
import '../Views/listQuizzPage.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;

  
void onPress(BuildContext context, Categorie categorie) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => ListeQuizzPage(categorieId: categorie.id)),
  );
}

Future<List<Categorie>> onInit() async {
  List<Categorie> categories = [];
  var password = 'root';
  final encodedPassword = Uri.encodeComponent(password);
  var db = await mongo.Db.create('mongodb+srv://root:$encodedPassword@Flutter.d1rxd.mongodb.net/Flutter?retryWrites=true&w=majority&appName=Flutter');
  try {
    await db.open();
    final collection = db.collection('Categorie');
    var result = await collection.find().toList();
    for (var doc in result) {
      categories.add(Categorie(id: doc['id'].toString(), nom: doc['nom']));
    }
  } catch (e) {
    print("Échec de la connexion à MongoDB : $e");
  } finally {
    await db.close();
  }
  return categories;
}
