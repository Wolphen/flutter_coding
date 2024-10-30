import '../../../Models/quizz.dart';
import '../../../Models/question.dart';
import '../../../Models/reponse.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'package:flutter/material.dart';
import '../../../Views/Quizz/newQuizz/newQuestion.dart';

Future<void> removeQuestion(Quizz quizz, int index) async {
  quizz.questions!.removeAt(index);
}

Future<void> newQuestion(BuildContext context, String quizzId) async {
  Navigator.push(context, MaterialPageRoute(builder: (context) => NewQuestion(quizzId: quizzId)));
}

bool editQuestion(BuildContext context) {
  return true;
}


Future<Quizz> onInit(String quizzId, String categorieId) async {
  Quizz quizz = Quizz(id: quizzId, nom: "", id_categ: categorieId);
  final encodedPassword = Uri.encodeComponent('root');
  final dbUrl = 'mongodb+srv://root:$encodedPassword@Flutter.d1rxd.mongodb.net/Flutter?retryWrites=true&w=majority&appName=Flutter';
  mongo.Db? db;
  try {
    db = await mongo.Db.create(dbUrl);
    await db.open();
    final collectionQuizz = db.collection('Quizz');
    final filter = {'id': quizzId};
    final result = await collectionQuizz.find(filter).toList();
    for (var doc in result) {
      final questions = await fetchQuestions(db, quizzId);
      quizz = Quizz(
        id: doc['id'].toString(),
        nom: doc['nom'],
        id_categ: doc['id_categ'].toString(),
        questions: questions,
      );
    }
  } catch (e) {
    print("Échec de la connexion à MongoDB : $e");
  } finally {
    if (db != null) {
      await db.close();
    }
  }
  return quizz;
}

Future<List<Question>> fetchQuestions(mongo.Db db, String quizzId) async {
  final collectionQuestion = db.collection('Question');
  final filterQuestion = {'id_quizz': quizzId};
  final resultQuestion = await collectionQuestion.find(filterQuestion).toList();
  return await Future.wait(resultQuestion.map((docQuestion) async {
    final reponses = await fetchReponses(db, docQuestion['id'].toString());
    return Question(
      id: docQuestion['id'].toString(),
      id_quizz: docQuestion['id_quizz'].toString(),
      texte: docQuestion['texte'],
      timer: docQuestion['timer'],
      reponses: reponses,
    );
  }).toList());
}

Future<List<Reponse>> fetchReponses(mongo.Db db, String questionId) async {
  final collectionReponse = db.collection('Reponse');
  final filterReponse = {'id_qu': questionId};
  final resultReponse = await collectionReponse.find(filterReponse).toList();
  return resultReponse.map((docReponse) => Reponse(
    id: docReponse['id'].toString(),
    id_qu: docReponse['id_qu'].toString(),
    texte: docReponse['texte'],
    is_correct: docReponse['is_correct'],
  )).toList();
}

