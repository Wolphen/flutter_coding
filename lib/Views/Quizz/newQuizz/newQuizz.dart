import 'package:flutter/material.dart';
import '../../../Models/quizz.dart';
import '../../../Controllers/Quizz/newQuizz/newQuizz.dart';
class NewQuizz extends StatefulWidget {
  final String? quizzId;
  final String categorieId;
  const NewQuizz({super.key,this.quizzId, required this.categorieId});

  @override
  State<NewQuizz> createState() => _NewQuizzState();
}

class _NewQuizzState extends State<NewQuizz> {

  
  Quizz quizz = Quizz(id: "", nom: "", id_categ: "", questions: []);
  @override
  void initState() {
    super.initState();
    if (widget.quizzId != null) {
      onInit(widget.quizzId!, widget.categorieId).then((value) {
        setState(() {
          quizz = value;
        });
      });
    } else {
      // Handle the case where quizzId is null, if necessary
      // For example, you might want to initialize quizz with default values
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Créer un nouveau quizz')),
      body: Column(
        children: [
          const Text('NewQuizz'),
          TextField(
            controller: TextEditingController(text: quizz.nom),
            decoration: const InputDecoration(labelText: 'Nom'),
          ),
          ElevatedButton(
            onPressed: () {
              newQuestion(context, quizz.id!);
            },
            child: const Text('Ajouter une question'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: quizz.questions!.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(quizz.questions![index].texte),
                  trailing: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      removeQuestion(quizz, index);
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
            //onSubmit(quizz);
          },
          child: const Text('Créer'),
        ),
      ),
    );
  }
}

