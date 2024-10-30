import 'package:flutter/material.dart';
import '../../Controllers/Quizz/quizzPage.dart';

class QuizzPage extends StatefulWidget {
  final String quizzId;
  final String quizzNom;
  final Map<String, dynamic> userInfo; // Ajoutez `userInfo` ici

  const QuizzPage({
    Key? key,
    required this.quizzId,
    required this.quizzNom,
    required this.userInfo, // Assurez-vous que userInfo est requis ici
  }) : super(key: key);

  @override
  State<QuizzPage> createState() => _QuizzPageState();
}

class _QuizzPageState extends State<QuizzPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.quizzNom),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('Est vous sûr de vouloir commencer ?'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Passez `userInfo` ici
                onPress(context, widget.quizzId, widget.quizzNom, widget.userInfo);
              },
              child: const Text('Commencer'),
            ),
          ],
        ),
      ),
    );
  }
}
