import '../../Models/question.dart';
import '../../Models/reponse.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'package:flutter/material.dart';
import '../../Views/homPage.dart';
import '../../Models/note.dart';

void onPressed(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const HomePage()), // Redirection vers HomePage
  );
}

Future<List<Question>> onInit(String quizzId) async {
  List<Question> listeQuestions = [];
  var password = 'root';
  final encodedPassword = Uri.encodeComponent(password);
  var db = await mongo.Db.create('mongodb+srv://root:$encodedPassword@Flutter.d1rxd.mongodb.net/Flutter?retryWrites=true&w=majority&appName=Flutter');
  try {
    await db.open();
    final collectionQuestion = db.collection('Question');
    var filter = {'id_quizz': quizzId};
    var questions = await collectionQuestion.find(filter).toList();
    for (var question in questions) {
      List<Reponse> listeReponses = [];
      final collectionReponse = db.collection('Reponse');
      var filterReponse = {'id_question': question['id']};
      var reponses = await collectionReponse.find(filterReponse).toList();
      for (var reponse in reponses) {
        listeReponses.add(Reponse(id: reponse['id'].toString(), id_qu: reponse['id_question'].toString(), texte: reponse['texte'], is_correct: reponse['is_correct']));
      }
      listeQuestions.add(Question(id: question['id'].toString(), id_quizz: question['id_quizz'].toString(), texte: question['texte'], timer: question['timer'], reponses: listeReponses));
    }
  } catch (e) {
    print("Échec de la connexion à MongoDB : $e");
  } finally {
    await db.close();
  }
  return listeQuestions;
}

Future<void> saveResult(int score, List<Question> questions) async {
  var password = 'root';
  final encodedPassword = Uri.encodeComponent(password);
  var db = await mongo.Db.create('mongodb+srv://root:$encodedPassword@Flutter.d1rxd.mongodb.net/Flutter?retryWrites=true&w=majority&appName=Flutter');
  try {
    await db.open();
    final collectionNote = db.collection('Note');
    var note = Note(id_quiz: questions[0].id_quizz, id_user: 'userId', score: score);
    await collectionNote.insertOne(note.toJson());
    print('Note enregistrée avec succès');
  } catch (e) {
    print("Échec de la connexion à MongoDB : $e");
  } finally {
    await db.close();
  }
}
