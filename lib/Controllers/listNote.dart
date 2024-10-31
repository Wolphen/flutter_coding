import 'package:flutter_coding/Models/note.dart';
import 'package:flutter_coding/bdd/connectToDTB.dart';


Future<List<Note>> getListNote(String categoryId, String userId) async {
  List<Note> notes = await MongoDBService().getListNoteByQuizz(categoryId, userId);
  return notes;
}