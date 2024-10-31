import 'package:flutter/material.dart';
import '../../../Models/quizz.dart';
import '../../../Models/question.dart';
import '../../../Models/reponse.dart';
import '../../../Controllers/Quizz/editQuizz.dart' as editQuizz;
class EditQuizz extends StatefulWidget {
  final String categorieId;
  final Map<String, dynamic> userInfo; // Ajoutez ce paramètre pour userInfo
  final Quizz quizz;
  const EditQuizz({super.key, required this.categorieId, required this.userInfo, required this.quizz});

  @override
  State<EditQuizz> createState() => _EditQuizzState();
}

class _EditQuizzState extends State<EditQuizz> {
  bool isLoading = true;
  bool isEdit = false; // Indique si nous sommes en mode édition
  late Quizz quizz;
  late Question newQuestion;
  late List<Reponse> reponses;
  final TextEditingController quizzNameController = TextEditingController();
  List<TextEditingController> reponseControllers = [];

  @override
  void initState() {
    super.initState();
    editQuizz.detailQuizz(widget.quizz.id!).then((value) {
      setState(() {
        quizz = value;
        newQuestion = editQuizz.initQuestion();
        reponses = editQuizz.initReponses();
        isLoading = false;
        quizzNameController.text = quizz.nom;

        // Initialiser les contrôleurs pour chaque réponse
        reponseControllers = List.generate(reponses.length, (_) => TextEditingController());
      });
    });
  }

  @override
  void dispose() {
    // Nettoyer les contrôleurs pour éviter les fuites de mémoire
    quizzNameController.dispose();
    for (var controller in reponseControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Modifier le quizz')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
          children: [
            _QuizForm(
              quizzName: quizz.nom,
              onAddQuestion: () {
                setState(() {
                  isEdit = true; // Passer en mode édition
                });
              },
            ),
            if (isEdit) _buildQuestion(context, newQuestion),
            Expanded(
              child: ListView.builder(
                itemCount: quizz.questions!.length,
                itemBuilder: (context, index) => _buildQuestionTile(quizz.questions![index]),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () => editQuizz.onSubmit(context, quizz, widget.userInfo), // Soumettre le quiz
              child: const Text('Modifier', style: TextStyle(fontSize: 18)),
            ),
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text("Confirmation"),
                      content: const Text("Voulez-vous vraiment supprimer ce quizz?"),
                      actions: <Widget>[
                        TextButton(
                          child: const Text("Annuler"),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        TextButton(
                          child: const Text("Supprimer"),
                          onPressed: () {
                            editQuizz.deleteQuizz(context, quizz, widget.userInfo);
                          },
                        ),
                      ],
                    );
                  },
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Supprimer', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }

  // Construire une tuile de question
  Widget _buildQuestionTile(Question question) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: ListTile(
        title: Text(question.texte),
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () {
            setState(() {
              quizz.questions!.remove(question); // Supprimer la question
            });
          },
        ),
      ),
    );
  }

  // Construire le formulaire de question
  Widget _buildQuestion(BuildContext context, Question question) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTextField(
              labelText: 'Nom de la question',
              controller: TextEditingController(text: question.texte),
              onChanged: (value) => question.texte = value,
            ),
            const SizedBox(height: 10),
            _buildTextField(
              labelText: 'Timer (secondes)',
              controller: TextEditingController(text: question.timer.toString()),
              keyboardType: TextInputType.number,
              onChanged: (value) => question.timer = int.tryParse(value) ?? 0,
            ),
            const SizedBox(height: 10),
            ...List.generate(reponses.length, (index) {
              return _buildAnswerField('Réponse ${index + 1}', reponses[index], reponseControllers[index]);
            }),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                question.reponses!.addAll(reponses); // Ajouter les réponses à la question
                setState(() {
                  quizz.questions!.add(question); // Ajouter la question au quiz
                  isEdit = false; // Sortir du mode édition
                  newQuestion = editQuizz.initQuestion(); // Réinitialiser la question
                  reponses = editQuizz.initReponses(); // Réinitialiser les réponses
                  reponseControllers = List.generate(reponses.length, (_) => TextEditingController());
                });
              },
              child: const Text('Ajouter la question'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String labelText,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    required Function(String) onChanged,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(labelText: labelText, border: const OutlineInputBorder()),
      keyboardType: keyboardType,
      onChanged: onChanged,
    );
  }

  // Construire un champ de réponse avec un contrôleur dédié
  Widget _buildAnswerField(String label, Reponse reponse, TextEditingController controller) {
    controller.text = reponse.texte; // Initialiser le contrôleur avec le texte de la réponse
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
              onChanged: (value) {
                setState(() {
                  reponse.texte = value; // Mettre à jour le texte de la réponse
                });
              },
            ),
          ),
          const SizedBox(width: 10),
          DropdownButton<String>(
            value: reponse.is_correct ? 'Correct' : 'Incorrect',
            items: const [
              DropdownMenuItem(value: 'Correct', child: Text('Correct')),
              DropdownMenuItem(value: 'Incorrect', child: Text('Incorrect')),
            ],
            onChanged: (newValue) {
              setState(() {
                reponse.is_correct = newValue == 'Correct'; // Mettre à jour la valeur de la réponse
              });
            },
          ),
        ],
      ),
    );
  }

  // Construire le formulaire du quiz
  Widget _QuizForm({required String quizzName, required VoidCallback onAddQuestion}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Nouveau Quizz', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            const SizedBox(height: 20),
            TextField(
              controller: quizzNameController,
              decoration: const InputDecoration(labelText: 'Nom', border: OutlineInputBorder()),
              onChanged: (value) => quizz.nom = value,
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: onAddQuestion, child: const Text('Ajouter une question')),
          ],
        ),
      ),
    );
  }
}


