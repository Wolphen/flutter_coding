// lib/Models/question.dart
import 'reponse.dart';

class Question {
  String? id;
  String id_quizz;
  String texte;
  int timer;
  List<Reponse>? reponses;

  Question({
    this.id,
    required this.id_quizz,
    required this.texte,
    required this.timer,
    this.reponses,
  });
}
