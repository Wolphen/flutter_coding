// lib/Models/quizz.dart
import 'question.dart';

class Quizz {
  Object id;
  String nom;
  String id_categ;
  List<Question>? questions;

  Quizz({
    required this.id,
    required this.nom,
    required this.id_categ,
    this.questions,
  });

  Map<String, dynamic> toJson() {
    return {
      'nom': nom,
      'id_categ': id_categ,
    };
  }
}
