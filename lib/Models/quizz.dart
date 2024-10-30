// lib/Models/quizz.dart
import 'question.dart';
import 'package:mongo_dart/mongo_dart.dart';

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

  Map<String, dynamic> toJson() {
    return {
      'nom': nom,
      'id_categ': ObjectId.fromHexString(id_categ),
    };
  }
}
