import 'package:flutter/material.dart';
import '../Models/quizz.dart';
import '../Controllers/listQuizzPage.dart';

class ListeQuizzPage extends StatefulWidget {
  final String categorieId;

  const ListeQuizzPage({Key? key, required this.categorieId}) : super(key: key);

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

  // List<Quizz> quizz = [];
  // bool isLoading = true;
  // @override
  // void initState() {
  //   super.initState();
  //   onInit(widget.categorieId).then((value) {
  //     setState(() {
  //       quizz = value;
  //       isLoading = false;
  //     });
  //   });
  // }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Liste des Quizz'),
      ),
      body: isLoading
        ? const CircularProgressIndicator()
        : ListView.builder(
        itemCount: quizz.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(quizz[index].nom),
            onTap: () {
              onPress(context, quizz[index]);
            },
          );
          },
        ),
    );
  }
}
 