import 'package:flutter/material.dart';

class QuestionPage extends StatefulWidget {
  final String quizzId;
  final String quizzNom;
  const QuestionPage({Key? key, required this.quizzId, required this.quizzNom}) : super(key: key);

  @override
  State<QuestionPage> createState() => _QuestionPageState();
}

class _QuestionPageState extends State<QuestionPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.quizzNom)),
    );
  }
}