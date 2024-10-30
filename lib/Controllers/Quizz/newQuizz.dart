import '../../Models/quizz.dart';
import '../../Models/question.dart';
import '../../Models/reponse.dart';
import 'package:flutter/material.dart';


Future<void> removeQuestion(Quizz quizz, int index) async {
  quizz.questions!.removeAt(index);
}


bool editQuestion(BuildContext context) {
  return true;
}

Future<void> onSubmit(Quizz quizz) async {
  for (var question in quizz.questions!) {
    print(question.texte);
  }
}

Quizz onInitNew(String quizzId, String categorieId) {
  Quizz quizz = initQuizz(quizzId, categorieId);
  quizz.questions = [initQuestion()];
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
  return List.generate(4, (index) => Reponse(id: "", id_qu: "", texte: "", is_correct: false));
}

