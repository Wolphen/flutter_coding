// lib/Models/reponse.dart
import 'package:mongo_dart/mongo_dart.dart';
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

  Map<String, dynamic> toJson() {
    return {
      'id_qu': ObjectId.fromHexString(id_qu!),
      'texte': texte,
      'is_correct': is_correct,
    };
  }
}
