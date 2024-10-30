import '../../../Models/question.dart';
import 'package:flutter/material.dart';


// Future<void> newQuestion(BuildContext context) async {
//   Navigator.push(context, MaterialPageRoute(builder: (context) => const NewQuestion()));
// }
Future<void> onSubmit(BuildContext context, Question question) async {
  Navigator.pop(context);
}

Future<void> removeQuestion(Question question, int index) async {
  question.reponses!.removeAt(index);
}

Future<void> newResponse(BuildContext context, String questionId) async {
  //Navigator.push(context, MaterialPageRoute(builder: (context) => NewResponse(questionId: questionId)));
}

Future<void> removeResponse(Question question, int index) async {
  question.reponses!.removeAt(index);
}
