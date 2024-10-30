import '../../../Models/quizz.dart';
import '../../../Models/question.dart';
import '../../../Models/reponse.dart';
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

Future<void> onSubmit(Quizz quizz) async {
  for (var question in quizz.questions!) {
    print(question.texte);
  }
}

Quizz onInit(String quizzId, String categorieId) {
  Quizz quizz = initQuizz(quizzId, categorieId);
  quizz.questions = [initQuestion(quizzId)];
  for (var question in quizz.questions!) {
    question.reponses = initReponses();
  }
  return quizz;
}


// Initialisation du quiz
Quizz initQuizz(String quizzId, String categorieId) {
  return Quizz(
    id: quizzId,
    nom: '',
    id_categ: categorieId,
    questions: [],
  );
}

// Initialisation d'une nouvelle question
Question initQuestion(String quizzId) {
  return Question(
    texte: '',
    reponses: [],
    id_quizz: quizzId,
    timer: 0,
  );
}

// Initialisation des réponses
List<Reponse> initReponses() {
  return List.generate(4, (index) => Reponse(id: "", id_qu: "", texte: "", is_correct: false));
}

