// lib/Models/reponse.dart

class Reponse {
  String? id;
  String? id_qu;
  String texte;
  bool is_correct;

  Reponse({
    this.id,
    this.id_qu,
    required this.texte,
    required this.is_correct,
  });
}