import 'package:flutter/material.dart';
import 'package:flutter_coding/Views/Quizz/newQuizz.dart';
import '../../Models/quizz.dart';
import '../../Views/Quizz/quizzPage.dart';
import '../../bdd/connectToDTB.dart';
import '../../Views/Quizz/editQuizz.dart';

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

void editQuizz(BuildContext context, String categorieId, Quizz quizz, Map<String, dynamic> userInfo) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => EditQuizz(categorieId: categorieId, userInfo: userInfo, quizz: quizz)),
  );
}

Future<List<Quizz>> listQuizz(String categorieId) async {
  List<Quizz> listQuizz = await MongoDBService().getListQuizz(categorieId);
  return listQuizz;
}
