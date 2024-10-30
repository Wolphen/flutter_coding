// lib/Models/reponse.dart

class Reponse {
  Object? id;
  String? id_qu;
  String texte;
  bool is_correct;

  Reponse({
    this.id,
    this.id_qu,
    required this.texte,
    required this.is_correct,
  });

  Map<String, dynamic> toJson() {
    return {
      'id_qu': id_qu,
      'texte': texte,
      'is_correct': is_correct,
    };
  }
}
