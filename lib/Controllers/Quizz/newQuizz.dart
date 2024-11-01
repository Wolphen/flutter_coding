import 'package:flutter_coding/Views/Quizz/listQuizzPage.dart';

import '../../Models/quizz.dart';
import '../../Models/question.dart';
import '../../Models/reponse.dart';
import 'package:flutter/material.dart';
import '../../bdd/connectToDTB.dart';


Future<void> removeQuestion(Quizz quizz, int index) async {
  quizz.questions!.removeAt(index);
}


bool editQuestion(BuildContext context) {
  return true;
}

Future<void> onSubmit(BuildContext context, Quizz quizz, Map<String, dynamic> userInfo) async {
  await MongoDBService().insertQuizz(quizz);
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (context) => ListeQuizzPage(userInfo: userInfo, categorieId: quizz.id_categ), // Assurez-vous de fournir userInfo ici
    ),
  );
}

Quizz onInitNew(String categorieId) {
  Quizz quizz = initQuizz(categorieId);
  return quizz;
}


// Initialisation du quiz
Quizz initQuizz(String categorieId) {
  return Quizz(
    nom: '',
    id_categ: categorieId,
    questions: [],
  );
}

// Initialisation d'une nouvelle question
Question initQuestion() {
  return Question(
    texte: '',
    reponses: [],
    id_quizz: '',
    timer: 0,
  );
}

// Initialisation des réponses
List<Reponse> initReponses() {
    return List.generate(4, (index) => Reponse(id_qu: "", texte: "", is_correct: false));
}

