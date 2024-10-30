// lib/Models/quizz.dart
import 'question.dart';

class Quizz {
  String? id;
  String nom;
  String id_categ;
  List<Question>? questions;

  Quizz({
    this.id,
    required this.nom,
    required this.id_categ,
    this.questions,
  });
}
