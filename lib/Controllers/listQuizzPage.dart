import 'package:flutter/material.dart';
import '../Models/quizz.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import '../Views/quizzPage.dart';

  
void onPress(BuildContext context, Quizz quizz) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => QuizzPage(quizzId: quizz.id)),
  );
}

Future<List<Quizz>> onInit(String categorieId) async {
  List<Quizz> listeQuizz = [];
  var password = 'root';
  final encodedPassword = Uri.encodeComponent(password);
  var db = await mongo.Db.create('mongodb+srv://root:$encodedPassword@Flutter.d1rxd.mongodb.net/Flutter?retryWrites=true&w=majority&appName=Flutter');
  try {
    await db.open();
    final collection = db.collection('quizz');
    var filter = {'id_categ': categorieId};
    var result = await collection.find(filter).toList();
    for (var doc in result) {
      listeQuizz.add(Quizz(id: doc['id'].toString(), nom: doc['nom'], id_categ: doc['id_categ'].toString()));
    }
  } catch (e) {
    print("Échec de la connexion à MongoDB : $e");
  } finally {
    await db.close();
  }
  return listeQuizz;
}
