import 'package:flutter/material.dart';
import 'package:flutter_coding/Models/note.dart';
import 'package:flutter_coding/bdd/connectToDTB.dart';
import '../Models/categorie.dart';
import '../Views/Quizz/listQuizzPage.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;


Future<List<Note>> getListNote(String categoryId, String userId) async {
  List<Note> notes = await MongoDBService().getListNoteByQuizz(categoryId, userId);

  return notes;
}