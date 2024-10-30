import 'package:flutter/material.dart';
import '../../Views/Quizz/questionPage.dart';

void onPress(BuildContext context, String quizzId, String quizzNom, Map<String, dynamic> userInfo) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => QuestionPage(
        quizzId: quizzId,
        quizzNom: quizzNom,
        userInfo: userInfo, // Transmettez userInfo ici
      ),
    ),
  );
}
