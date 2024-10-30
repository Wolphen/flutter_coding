import 'package:flutter/material.dart';
import '../../../Models/quizz.dart';
import '../../../Models/question.dart';
import '../../../Controllers/Quizz/newQuizz/newQuizz.dart';

class NewQuizz extends StatefulWidget {
  final String? quizzId;
  final String categorieId;

  const NewQuizz({super.key,this.quizzId, required this.categorieId});

  @override
  State<NewQuizz> createState() => _NewQuizzState();
}

class _NewQuizzState extends State<NewQuizz> {

  bool isEdit = false;
  late Quizz quizz;
  late Question newQuestion;
  @override
  void initState() {
    super.initState();
    initQuizz();
    initQuestion();
    if (widget.quizzId != "") {
      // onInit(widget.quizzId!, widget.categorieId).then((value) {
      //   setState(() {
      //     quizz = value;
      //   });
      // });
    }
  }

  void initQuizz() {
    quizz = Quizz(id: widget.quizzId!, nom: "", id_categ: widget.categorieId, questions: []);
  }
  void initQuestion() {
    newQuestion = Question(texte: "", reponses: [], id_quizz: widget.quizzId!, timer: 0);
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Créer un nouveau quizz'),
    ),
    body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _QuizForm(
            quizzName: quizz.nom,
            onAddQuestion: () {
              setState(() {
                isEdit = editQuestion(context);
              });
            },
          ),
          if (isEdit) _buildQuestion(context, newQuestion),
        ],
      ),
    ),
    bottomNavigationBar: Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton(
        onPressed: () {
          //onSubmit(quizz);
        },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: const Text('Créer', style: TextStyle(fontSize: 18)),
        ),
      ),
    );
  }

  Widget _buildQuestion(BuildContext context, Question question) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: TextEditingController(text: question.texte),
              decoration: const InputDecoration(labelText: 'Nom'),
            ),
            TextField(
              controller: TextEditingController(text: question.timer.toString()),
              decoration: const InputDecoration(labelText: 'Timer'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: TextEditingController(text: question.reponses![0].texte),
            decoration: const InputDecoration(labelText: 'Réponse 1'),
            ),
            TextField(
              controller: TextEditingController(text: question.reponses![1].texte),
              decoration: const InputDecoration(labelText: 'Réponse 2'),
            ),
            TextField(
              controller: TextEditingController(text: question.reponses![2].texte),
              decoration: const InputDecoration(labelText: 'Réponse 3'),
            ),
            TextField(
              controller: TextEditingController(text: question.reponses![3].texte),
              decoration: const InputDecoration(labelText: 'Réponse 4'),
            ),
          ],
        ),
      ),
    );
  }
}

// New widget for the quiz form
Widget _QuizForm({required String quizzName, required VoidCallback onAddQuestion}) {
  return Card(
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'New Quizz',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          TextField(
            controller: TextEditingController(text: quizzName),
            decoration: const InputDecoration(
              labelText: 'Nom',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: onAddQuestion,
            child: const Text('Ajouter une question'),
          ),
        ],
      ),
    ),
  );
}

