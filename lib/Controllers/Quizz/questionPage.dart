import '../../Models/question.dart';
import '../../bdd/connectToDTB.dart';
import 'package:flutter/material.dart';
import '../../Views/homPage.dart';

void onPressed(BuildContext context, Map<String, dynamic> userInfo) { // Ajoutez le paramètre userInfo
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => HomePage(userInfo: userInfo), // Passez userInfo ici
    ),
  );
}


Future<List<Question>> getListQuestions(String quizzId) async {
  return await MongoDBService().getListQuestions(quizzId);
}

Future<void> saveResult(int score, List<Question> questions, Map<String, dynamic> userInfo) async {
  await MongoDBService().saveResult(score, questions, userInfo);
}
