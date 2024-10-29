// lib/Models/question.dart

class Question {
  String id;
  String id_quizz;
  String texte;
  int timer;

  Question({
    required this.id,
    required this.id_quizz,
    required this.texte,
    required this.timer,
  });
}
