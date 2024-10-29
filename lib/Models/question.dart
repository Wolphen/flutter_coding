// lib/Models/question.dart
import 'reponse.dart';

class Question {
  String id;
  String id_quizz;
  String texte;
  int timer;
  List<Reponse> reponses;

  Question({
    required this.id,
    required this.id_quizz,
    required this.texte,
    required this.timer,
    required this.reponses,
  });
}
