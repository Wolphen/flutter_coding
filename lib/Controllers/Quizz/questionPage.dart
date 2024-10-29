import '../../Models/question.dart';
import '../../Models/reponse.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;

Future<List<Question>> onInit(String quizzId) async {
  List<Question> listeQuestions = [];
  var password = 'root';
  final encodedPassword = Uri.encodeComponent(password);
  var db = await mongo.Db.create('mongodb+srv://root:$encodedPassword@Flutter.d1rxd.mongodb.net/Flutter?retryWrites=true&w=majority&appName=Flutter');
  try {
    await db.open();
    final collectionQuestion = db.collection('Question');
    var filter = {'id_quizz': quizzId};
    var questions = await collectionQuestion.find(filter).toList();
    for (var question in questions) {
      List<Reponse> listeReponses = [];
      final collectionReponse = db.collection('Reponse');
      var filterReponse = {'id_question': question['id']};
      var reponses = await collectionReponse.find(filterReponse).toList();
      for (var reponse in reponses) {
        listeReponses.add(Reponse(id: reponse['id'].toString(), id_quizz: reponse['id_quizz'].toString(), texte: reponse['texte'], is_correct: reponse['is_correct']));
      }
      listeQuestions.add(Question(id: question['id'].toString(), id_quizz: question['id_quizz'].toString(), texte: question['texte'], timer: question['timer'], reponses: listeReponses));
    }
  } catch (e) {
    print("Échec de la connexion à MongoDB : $e");
  } finally {
    await db.close();
  }
  return listeQuestions;
}