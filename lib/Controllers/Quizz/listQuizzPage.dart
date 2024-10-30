import 'package:flutter/material.dart';
import 'package:flutter_coding/Views/Quizz/newQuizz.dart';
import '../../Models/quizz.dart';
import '../../Views/Quizz/quizzPage.dart';
import '../../bdd/connectToDTB.dart';

void onPress(BuildContext context, Quizz quizz, Map<String, dynamic> userInfo) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => QuizzPage(
        quizzId: quizz.id!,
        quizzNom: quizz.nom,
        userInfo: userInfo, // Passez `userInfo` ici
      ),
    ),
  );
}

void onAddQuizz(BuildContext context, String categorieId, Map<String, dynamic> userInfo) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => NewQuizz(categorieId: categorieId, userInfo: userInfo),
    ),
  );
}

Future<List<Quizz>> listQuizz(String categorieId) async {
  List<Quizz> listQuizz = [];
  listQuizz = await MongoDBService().getListQuizz(categorieId);
  return listQuizz;
}
