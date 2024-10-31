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
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    listQuizz(widget.categorieId).then((value) {
      setState(() {
        quizz = value;
        isLoading = false;
      });
    });
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
                  } else if (widget.userInfo['admin']) {
                    return _buildAddNewQuizzCard();
                  } else {
                    return const SizedBox.shrink();
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
        if (widget.userInfo['admin']) {
          onAddQuizz(context, widget.categorieId, widget.userInfo);
        }
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
        onAddQuizz(context, widget.categorieId, widget.userInfo);
      },
      child: const Card(
        child: Center(
          child: Icon(Icons.add),
        ),
      ),
    );
  }
}
