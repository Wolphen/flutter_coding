import 'package:flutter/material.dart';
import '../../../Models/question.dart';
import '../../../Controllers/Quizz/newQuizz/newQuestion.dart';

class NewQuestion extends StatefulWidget {
  final String? quizzId;
  const NewQuestion({super.key,this.quizzId});

  @override
  State<NewQuestion> createState() => _NewQuestionState();
}

class _NewQuestionState extends State<NewQuestion> {
  late Question question;
  @override
  void initState() {
    super.initState();
    initQuestion();
  }
  void initQuestion() {
    question = Question(texte: "", reponses: [], id_quizz: widget.quizzId!, timer: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Créer une nouvelle question')),
      body: Column(
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
          ElevatedButton(
            onPressed: () {
              newResponse(context, question.id!);
            },
            child: const Text('Ajouter une réponse'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: question.reponses!.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(question.reponses![index].texte),
                  trailing: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      removeResponse(question, index);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: ElevatedButton(
          onPressed: () {
            onSubmit(context, question);
          },
          child: const Text('Créer'),
        ),
      ),
    );
  }
}

