import 'package:flutter/material.dart';
import '../../Models/quizz.dart';
import '../../Controllers/Quizz/listQuizzPage.dart';

class ListeQuizzPage extends StatefulWidget {
  final String categorieId;

  const ListeQuizzPage({Key? key, required this.categorieId}) : super(key: key);

  @override
  State<ListeQuizzPage> createState() => _ListeQuizzPageState();
}

class _ListeQuizzPageState extends State<ListeQuizzPage> {

  //---------------------------Liste des quizz---------------------------//

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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Liste des Quizz'),
      ),
      body: isLoading
        ? const CircularProgressIndicator()
        : GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10.0,
          mainAxisSpacing: 10.0,
        ),
        itemCount: quizz.length,
        itemBuilder: (context, index) {
          return _buildCard(quizz[index], index);
        },
      ),
    );
  }

  //---------------------------Cards---------------------------//
  
  Widget _buildCard(Quizz quizz, int index) {
    return GestureDetector(
      onTap: () {
        onPress(context, quizz);
      },
      child: Card(
        child: Center(
          child: Text(quizz.nom),
        ),
      ),
    );
  }
}
 