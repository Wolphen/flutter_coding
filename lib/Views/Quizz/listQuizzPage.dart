import 'package:flutter/material.dart';
import '../../Models/quizz.dart';
import '../../Controllers/Quizz/listQuizzPage.dart';

class ListeQuizzPage extends StatefulWidget {
  final String categorieId;
  final Map<String, dynamic> userInfo; // Ajoutez `userInfo` ici

  const ListeQuizzPage({
    Key? key,
    required this.categorieId,
    required this.userInfo, // Ajoutez `userInfo` ici
  }) : super(key: key);

  @override
  State<ListeQuizzPage> createState() => _ListeQuizzPageState();
}

class _ListeQuizzPageState extends State<ListeQuizzPage> {
  List<Quizz> quizz = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _initQuizzes();
  }

  void _initQuizzes() {
    quizz = [
      Quizz(id: "1", nom: "Quizz 1", id_categ: widget.categorieId),
      Quizz(id: "2", nom: "Quizz 2", id_categ: widget.categorieId),
      Quizz(id: "3", nom: "Quizz 3", id_categ: widget.categorieId),
      Quizz(id: "4", nom: "Quizz 4", id_categ: widget.categorieId),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Liste des Quizz'),
      ),
      body: Center(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Choisissez un quizz :',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(8.0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10.0,
                  mainAxisSpacing: 10.0,
                ),
                itemCount: quizz.length + 1, // Added +1 for the add new quizz card
                itemBuilder: (context, index) {
                  if (index < quizz.length) {
                    return _buildCard(quizz[index], index);
                  } else {
                    return _buildAddNewQuizzCard();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  //---------------------------Cards---------------------------//
  Widget _buildCard(Quizz quizz, int index) {
    return GestureDetector(
      onTap: () {
        onPress(context, quizz, widget.userInfo); // Utilisez `widget.userInfo`
      },
      onLongPress: () {
        onAddQuizz(context, quizz.id!, widget.categorieId);
      },
      child: Card(
        child: Center(
          child: Text(quizz.nom),
        ),
      ),
    );
  }

  Widget _buildAddNewQuizzCard() {
    return GestureDetector(
      onTap: () {
        onAddQuizz(context, "", widget.categorieId);
      },
      child: const Card(
        child: Center(
          child: Icon(Icons.add),
        ),
      ),
    );
  }
}
