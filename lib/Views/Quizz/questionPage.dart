import 'dart:async';

import 'package:flutter/material.dart';
import '../../Models/question.dart';
import '../../Models/reponse.dart';
import '../../Controllers/Quizz/questionPage.dart';
import '../../Views/homPage.dart';

class QuestionPage extends StatefulWidget {
  final String quizzId;
  final String quizzNom;
  const QuestionPage({Key? key, required this.quizzId, required this.quizzNom}) : super(key: key);

  @override
  State<QuestionPage> createState() => _QuestionPageState();
}

class _QuestionPageState extends State<QuestionPage> {

  // List<Question> questions = [];
  // bool isLoading = true;

  // @override
  // void initState() {
  //   super.initState();
  //   onInit(widget.quizzId).then((value) {
  //     setState(() {
  //       questions = value;
  //       isLoading = false;
  //     });
  //   });
  // }
  // @override
  //---------------------------Liste des questions---------------------------//
  int currentQuestionIndex = 0;
  int score = 0;
  List<Question> questions = [];
  bool isLoading = false;
  @override
  void initState() {
    super.initState();
    _initQuestions();
    _startTimer();
  }
  void _initQuestions() {
    questions = [
      Question(id: "1", id_quizz: widget.quizzId, texte: "Question 1", timer: 10, reponses: [
      Reponse(id: "1", id_qu: "1", texte: "Reponse 1", is_correct: true),
      Reponse(id: "2", id_qu: "1", texte: "Reponse 2", is_correct: false),
      Reponse(id: "3", id_qu: "1", texte: "Reponse 3", is_correct: false),
      Reponse(id: "4", id_qu: "1", texte: "Reponse 4", is_correct: false),
    ]),
    Question(id: "2", id_quizz: widget.quizzId, texte: "Question 2", timer: 10, reponses: [
      Reponse(id: "5", id_qu: "2", texte: "Reponse 5", is_correct: true),
      Reponse(id: "6", id_qu: "2", texte: "Reponse 6", is_correct: false),
      Reponse(id: "7", id_qu: "2", texte: "Reponse 7", is_correct: false),
      Reponse(id: "8", id_qu: "2", texte: "Reponse 8", is_correct: false),
    ]),
    Question(id: "3", id_quizz: widget.quizzId, texte: "Question 3", timer: 10, reponses: [
      Reponse(id: "9", id_qu: "3", texte: "Reponse 9", is_correct: true),
      Reponse(id: "10", id_qu: "3", texte: "Reponse 10", is_correct: false),
      Reponse(id: "11", id_qu: "3", texte: "Reponse 11", is_correct: false),
      Reponse(id: "12", id_qu: "3", texte: "Reponse 12", is_correct: false),
    ]),
    Question(id: "4", id_quizz: widget.quizzId, texte: "Question 4", timer: 10, reponses: [
      Reponse(id: "13", id_qu: "4", texte: "Reponse 13", is_correct: true),
      Reponse(id: "14", id_qu: "4", texte: "Reponse 14", is_correct: false),
      Reponse(id: "15", id_qu: "4", texte: "Reponse 15", is_correct: false),
      Reponse(id: "16", id_qu: "4", texte: "Reponse 16", is_correct: false),
    ]),
    ];
  }

  void _onAnswerSelected(bool isCorrect) {
    if (isCorrect) {
      score++;
    }
    setState(() {
      currentQuestionIndex++;
    });
  }

  void _startTimer() {
    Timer.periodic(Duration(seconds: 1), (timer) {
      if (currentQuestionIndex < questions.length) {
        setState(() {
          if (questions[currentQuestionIndex].timer > 0) {
            questions[currentQuestionIndex].timer--;
          } else {
            timer.cancel();
            currentQuestionIndex++;
            _startTimer();
          }
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : currentQuestionIndex < questions.length
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildQuestionText(),
                      _buildTimer(),
                      _buildAnswerButtons(context),
                    ],
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Fin du quiz", style: TextStyle(fontSize: 24)),
                        Text("Score: $score/${questions.length}", style: const TextStyle(fontSize: 24)),
                        ElevatedButton(
                          onPressed: () {
                            saveResult(score, questions);
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const HomePage()),
                            );
                          },
                          child: const Text('Retour à la page d\'accueil'),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _buildTimer() {
    return Text(
      "Temps restant: ${questions[currentQuestionIndex].timer} secondes",
      style: const TextStyle(fontSize: 18),
    );
  }

  Widget _buildQuestionText() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
    child: Text(
      questions[currentQuestionIndex].texte,
      textAlign: TextAlign.center,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    ),
  );

  Widget _buildAnswerButtons(BuildContext context) => Column(
    children: [
      Wrap(
        spacing: 10.0,
        runSpacing: 10.0,
        alignment: WrapAlignment.center,
        children: questions[currentQuestionIndex].reponses!.map((reponse) {
          return SizedBox(
            width: MediaQuery.of(context).size.width * 0.4,
            child: ElevatedButton(
              onPressed: () => _onAnswerSelected(reponse.is_correct),
              child: Text(reponse.texte),
            ),
          );
        }).toList(),
      ),
      const SizedBox(height: 20),
      ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        ),
        onPressed: () => showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Confirmation'),
              content: const Text('Êtes-vous sûr de vouloir quitter le quizz ?'),
              actions: <Widget>[
                TextButton(
                  child: const Text('Annuler'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                TextButton(
                  child: const Text('Confirmer'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    onPressed(context);
                  },
                ),
              ],
            );
          },
        ),
        child: const Text("Quitter"),
      ),
    ],
  );
}