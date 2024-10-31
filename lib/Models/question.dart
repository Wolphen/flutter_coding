// lib/Models/question.dart
import 'reponse.dart';
import 'package:mongo_dart/mongo_dart.dart';
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

  Map<String, dynamic> toJson() {
    return {
      'id_quizz': ObjectId.fromHexString(id_quizz),
      'texte': texte,
      'timer': timer,
    };
  }
}
