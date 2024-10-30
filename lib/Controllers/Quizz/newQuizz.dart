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
    for (var reponse in question.reponses!) {
      print(reponse.texte);
    }
  }
}

Quizz onInitNew(String categorieId) {
  Quizz quizz = initQuizz(categorieId);
  print(quizz);
  return quizz;
}


// Initialisation du quiz
Quizz initQuizz(String categorieId) {
  return Quizz(
    id: '',
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

