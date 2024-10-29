import 'package:flutter/material.dart';

class QuizzPage extends StatefulWidget {
  final String quizzId;
  const QuizzPage({Key? key, required this.quizzId}) : super(key: key);
  @override
  State<QuizzPage> createState() => _QuizzPageState();
}

class _QuizzPageState extends State<QuizzPage> {

  @override
  void initState() {
    super.initState();
  }
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}