import 'dart:async';

import 'package:flutter/material.dart';
import '../../Models/question.dart';
import '../../Controllers/Quizz/questionPage.dart';
import '../../Views/homPage.dart';
import '../../Models/reponse.dart';

class QuestionPage extends StatefulWidget {
  final String quizzId;
  final String quizzNom;
  final Map<String, dynamic> userInfo;

  const QuestionPage({
    Key? key,
    required this.quizzId,
    required this.quizzNom,
    required this.userInfo,
  }) : super(key: key);

  @override
  State<QuestionPage> createState() => _QuestionPageState();
}

class _QuestionPageState extends State<QuestionPage> {
  int currentQuestionIndex = 0;
  int score = 0;
  List<Question> questions = [];
  bool isLoading = true;
  bool revealAnswer = false;
  bool showContinueButton = false; // Nouveau booléen pour changer le texte du bouton
  List<Reponse> reponsesSelected = [];
  List<Reponse> reponsesCorrect = [];

  @override
  void initState() {
    super.initState();
    getListQuestions(widget.quizzId).then((value) {
      setState(() {
        _startTimer();
        questions = value;
        isLoading = false;
      });
    });
  }

  void _startTimer() {
    revealAnswer = false;
    Timer.periodic(const Duration(seconds: 1), (timer) {
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

  void _onAnswerValidate(Question question) {
    reponsesSelected.clear();
    reponsesCorrect.clear();

    for (Reponse reponse in question.reponses!) {
      if (reponse.isSelected) {
        reponsesSelected.add(reponse);
      }
      if (reponse.is_correct) {
        reponsesCorrect.add(reponse);
      }
    }

    // Vérifie si toutes les réponses sélectionnées sont correctes
    bool isCorrect = reponsesSelected.length == reponsesCorrect.length &&
        reponsesSelected.every((reponse) => reponsesCorrect.contains(reponse));

    if (isCorrect) {
      score++;
    }

    setState(() {
      revealAnswer = true; // Afficher les réponses correctes et incorrectes
      showContinueButton = true; // Afficher le bouton Continuer
    });
  }

  void _continueToNextQuestion() {
    setState(() {
      revealAnswer = false;
      showContinueButton = false;
      reponsesSelected.clear();
      reponsesCorrect.clear();
      currentQuestionIndex++;
      _startTimer();
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
                            saveResult(score, questions, widget.userInfo);
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => HomePage(userInfo: widget.userInfo),
                              ),
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
            child: CheckboxListTile(
              title: Text(
                reponse.texte,
                style: TextStyle(
                  color: revealAnswer
                      ? (reponse.is_correct ? Colors.green : Colors.red)
                      : Colors.black,
                ),
              ),
              value: reponse.isSelected,
              onChanged: revealAnswer
                  ? null // Désactiver les boutons après validation
                  : (bool? value) {
                      setState(() {
                        reponse.isSelected = value!;
                      });
                    },
            ),
          );
        }).toList(),
      ),
      const SizedBox(height: 20),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
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
                        onPressed(context, widget.userInfo);
                      },
                    ),
                  ],
                );
              },
            ),
            child: const Text("Quitter"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            ),
            onPressed: showContinueButton
                ? _continueToNextQuestion // Passer à la prochaine question
                : () => _onAnswerValidate(questions[currentQuestionIndex]),
            child: Text(showContinueButton ? "Continuer" : "Valider"),
          ),
        ],
      ),
    ],
  );
}
