class Note {
  Object? id;
  String id_quiz;
  String id_user;
  int score;
  DateTime? date;

  Note({
    this.id,
    required this.id_quiz,
    required this.id_user,
    required this.score,
    this.date,
  });

    Map<String, dynamic> toJson() {
    return {
      'id_quiz': id_quiz,
      'id_user': id_user,
      'score': score,
      'date': date,
    };
  }
}
