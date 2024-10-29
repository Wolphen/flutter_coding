// lib/Models/reponse.dart

class Reponse {
  String id;
  String id_quizz;
  String texte;
  bool is_correct;

  Reponse({
    required this.id,
    required this.id_quizz,
    required this.texte,
    required this.is_correct,
  });
}
