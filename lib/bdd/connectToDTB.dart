import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import '../../../Models/quizz.dart';
import '../../../Models/question.dart';
import '../../../Models/reponse.dart';
import '../../../Models/note.dart';
import 'dart:math';

class MongoDBService {
  late mongo.Db db;
  mongo.DbCollection? userCollection;
  mongo.DbCollection? notesCollection;
  mongo.DbCollection? quizCollection;
  mongo.DbCollection? categorieCollection;
  bool _isConnected = false;
  static const String _secretKey = 'ton_secret_key';

  // Fonction pour initialiser la connexion à MongoDB
  Future<void> connect() async {
    try {
      var password = 'root';
      final encodedPassword = Uri.encodeComponent(password);
      db = await mongo.Db.create(
          'mongodb+srv://root:$encodedPassword@flutter.d1rxd.mongodb.net/Flutter?retryWrites=true&w=majority&appName=Flutter');
      await db.open();
      userCollection = db.collection('User');
      notesCollection = db.collection('Note');
      quizCollection = db.collection('Quiz');
      categorieCollection = db.collection('Categorie');
      _isConnected = true;
      print('Connexion réussie à MongoDB !');
    } catch (e) {
      print('Erreur de connexion à MongoDB : $e');
      _isConnected = false;
    }
  }

  // Fonction pour générer des notes aléatoires
  Future<void> generateRandomNotes() async {
    await ensureConnected();
    final random = Random();

    // Récupère tous les utilisateurs de la collection User
    final users = await userCollection!.find().toList();

    // Récupère toutes les catégories
    final categories = await categorieCollection!.find().toList();

    for (var categorie in categories) {
      // Crée un quiz pour chaque catégorie
      var quiz = {
        "nom": "Quiz for ${categorie["nom"]}",
        "id_categ": categorie["_id"],
      };
      var quizInsertResult = await quizCollection!.insertOne(quiz);
      final quizId = quizInsertResult.id;
      print("Quiz created for category ${categorie["nom"]} with ID: $quizId");

      for (var user in users) {
        for (int i = 0; i < 10; i++) {
          int score = random.nextInt(11) * 10; // Note entre 0 et 100 %
          var note = {
            "id_quiz": quizId,
            "id_user": user['_id'],
            "score": score,
            "date": DateTime.now(),
          };
          var noteInsertResult = await notesCollection!.insertOne(note);
          print("Note created with score $score% for user ${user['prenom']} ${user['nom']} in quiz $quizId");
        }
      }
    }
    print("All notes and quizzes generated successfully!");
  }

  // Fonction pour obtenir les taux de réussite par catégorie
  Future<Map<String, Map<String, double>>> getSuccessRatesByCategory() async {
    await ensureConnected();

    // Récupère toutes les catégories
    final categories = await categorieCollection!.find().toList();

    Map<String, Map<String, double>> successRates = {};

    for (var category in categories) {
      String categoryId = category['_id'].toString();
      String categoryName = category['nom'];

      // Récupère les quiz pour cette catégorie
      final quizzes = await quizCollection!.find({"id_categ": category['_id']})
          .toList();

      int totalNotes = 0;
      int totalSuccesses = 0;

      for (var quiz in quizzes) {
        // Récupère les notes pour chaque quiz
        final notes = await notesCollection!.find({"id_quiz": quiz['_id']})
            .toList();

        for (var note in notes) {
          int score = note['score'] ?? 0;
          totalNotes++;
          if (score > 5) {
            totalSuccesses++;
          }
        }
      }

      // Calcule le taux de réussite
      double successRate = totalNotes > 0
          ? (totalSuccesses / totalNotes) * 100
          : 0;
      double failureRate = 100 - successRate;

      successRates[categoryName] = {
        'Réussite': successRate,
        'Échec': failureRate,
      };

      print(
          "Category: $categoryName, Success Rate: $successRate%, Failure Rate: $failureRate%");
    }

    return successRates;


  }

 

  Future<List<Map<String, dynamic>>> getRecentResults() async {
    await ensureConnected();

    // Utilisation de l'agrégation pour trier et limiter les résultats récents
    var notes = await notesCollection!.aggregateToStream([
      {
        '\$sort': {'date': -1}  // Tri par date décroissante
      },
      {
        '\$limit': 100  // Limitation à 100 résultats
      }
    ]).toList();

    List<Map<String, dynamic>> results = [];

    for (var note in notes) {
      // Récupération des informations de l'utilisateur
      var user = await userCollection!.findOne({'_id': note['id_user']});

      // Récupération des informations du quiz
      var quiz = await quizCollection!.findOne({'_id': note['id_quiz']});

      // Vérification et extraction de l'année à partir de la date
      String annee = "N/A";
      if (note['date'] != null) {
        if (note['date'] is DateTime) {
          annee = note['date'].year.toString();
        } else if (note['date'] is String) {
          annee = DateTime.parse(note['date']).year.toString();
        }
      }

      // Construction du résultat avec les informations obtenues
      results.add({
        'nom': user?['nom'] ?? 'Nom inconnu',
        'prenom': user?['prenom'] ?? 'Prénom inconnu',
        'score': note['score'] ?? 0,
        'annee': annee,
      });
    }

    return results;
  }

  Future<List<Map<String, dynamic>>> getCategories() async {
    final collection = db.collection('Categorie');
    final categories = await collection.find().toList();
    return categories.map((category) => category as Map<String, dynamic>).toList();
  }

  Future<void> updateUser(Map<String, dynamic> document, String id) async {
    print("UpdateUser en cours");

    if (!_isConnected) {
      await connect();
    }

    final match = RegExp(r'ObjectId\("([a-fA-F0-9]{24})"\)').firstMatch(id);
    final cleanedId = match != null ? match.group(1) : id;

    print("ID nettoyé dans updateUser: $cleanedId");

    try {
      final objectId = mongo.ObjectId.fromHexString(cleanedId!);
      await userCollection!.updateOne(
        mongo.where.eq('_id', objectId),
        mongo.modify
            .set('nom', document['nom'])
            .set('prenom', document['prenom'])
            .set('mail', document['mail'])
            .set('age', document['age'])
            .set('adresse_postale', document['adresse_postale'])
            .set('motivation', document['motivation']),
      );
      print("Mise à jour réussie pour l'utilisateur avec ID $cleanedId");
    } catch (e) {
      print("Erreur lors de la conversion de l'ID dans updateUser : $e");
    }
  }

  Future<Map<String, dynamic>?> findUserById(String id) async {
    print("ID reçu dans findUserById: $id");

    if (!_isConnected) {
      await connect();
    }

    if (userCollection == null) {
      print("userCollection est null. Assurez-vous que la connexion à MongoDB a réussi.");
      return null;
    }

    final match = RegExp(r'ObjectId\("([a-fA-F0-9]{24})"\)').firstMatch(id);
    final cleanedId = match != null ? match.group(1) : id;

    print("ID nettoyé dans findUserById: $cleanedId");

    try {
      final objectId = mongo.ObjectId.fromHexString(cleanedId!);
      final user = await userCollection!.findOne({"_id": objectId});
      print("Utilisateur trouvé : $user");
      return user;
    } catch (e) {
      print("Erreur lors de la conversion de l'ID : $e");
      return null;
    }
  }

  bool isConnected() {
    return _isConnected;
  }

  Future<void> ensureConnected() async {
    if (!_isConnected || userCollection == null) {
      await connect();
    }
  }

  Future<bool> emailExists(String email) async {
    await ensureConnected();
    final user = await userCollection!.findOne({"mail": email});
    return user != null;
  }

  Future<void> insertUser(Map<String, dynamic> document) async {
    await ensureConnected();
    await userCollection!.insert(document);
    print("Document inséré avec succès dans MongoDB !");
  }

  String generateToken(String userId, String nom, String email, String admin) {
    final jwt = JWT(
      {
        'userId': userId.toString().replaceAll('ObjectId("', '').replaceAll('")', ''),
        'nom': nom,
        'mail': email,
        'admin': admin,
      },
    );
    return jwt.sign(SecretKey(_secretKey), expiresIn: const Duration(hours: 2));
  }

  Future<Map<String, dynamic>?> loginUser(String email, String password) async {
    await ensureConnected();
    final user = await userCollection!.findOne({"mail": email.trim()});
    if (user != null && user['password'] == password.trim()) {
      final token = generateToken(user['_id'].toString(), user['nom'], user['mail'], user['admin'].toString());
      print("Token généré pour l'utilisateur $email : $token");
      return {
        "token": token,
        "userInfo": user,
      };
    } else {
      print("Identifiants incorrects");
      return null;
    }
  }

  Future<bool> findUser(String email, String password) async {
    await ensureConnected();
    final userByEmail = await userCollection!.findOne({"mail": email.trim()});
    if (userByEmail != null) {
      print("Utilisateur trouvé avec email uniquement : $userByEmail");
      return userByEmail['password'] == password.trim();
    } else {
      print("Aucun utilisateur trouvé avec cet email.");
      return false;
    }
  }


  Future<void> close() async {
    await db.close();
    _isConnected = false;
    userCollection = null;
    notesCollection = null;
    quizCollection = null;
    categorieCollection = null;
    print('Connexion à MongoDB fermée.');
  }

  Future<Quizz> detailQuizz(String quizzId) async {
    Quizz quizz = Quizz(id: quizzId, nom: "", id_categ: "");
    await ensureConnected();
    final collectionQuizz = db.collection('Quizz');
    final filter = {'_id': mongo.ObjectId.fromHexString(quizzId)};
    final result = await collectionQuizz.findOne(filter);
    if (result != null) {
      final questions = await fetchQuestions(quizzId);
      quizz = Quizz(
        id: result['_id'].toHexString(),
        nom: result['nom'],
        id_categ: result['id_categ'].toHexString(),
        questions: questions,
      );
    }
    return quizz;
  }

  Future<List<Question>> fetchQuestions(String quizzId) async {
    List<Question> questions = [];
    final collectionQuestion = db.collection('Question');
    final filterQuestion = {'id_quizz': mongo.ObjectId.fromHexString(quizzId)};
    final resultQuestion = await collectionQuestion.find(filterQuestion).toList();
    for (var docQuestion in resultQuestion) {
      final reponses = await fetchReponses(docQuestion['_id'].toHexString());
      questions.add(Question(
        id: docQuestion['_id'].toHexString(),
        id_quizz: docQuestion['id_quizz'].toHexString(),
        texte: docQuestion['texte'],
        timer: docQuestion['timer'],
        reponses: reponses,
      ));
    }
    return questions;
  }

  Future<List<Reponse>> fetchReponses(String questionId) async {
    List<Reponse> reponses = [];
    final collectionReponse = db.collection('Reponse');
    final filterReponse = {'id_qu': mongo.ObjectId.fromHexString(questionId)};
    final resultReponse = await collectionReponse.find(filterReponse).toList();
    for (var docReponse in resultReponse) {
      reponses.add(Reponse(
        id: docReponse['_id'].toHexString(),
        id_qu: docReponse['id_qu'].toHexString(),
        texte: docReponse['texte'],
        is_correct: docReponse['is_correct'],
      ));
    }
    return reponses;
  }

  Future<void> insertQuizz(Quizz quizz) async {
    await ensureConnected();
    var result = await db.collection('Quizz').insertOne(quizz.toJson());
    print("Quizz inséré avec succès dans MongoDB !");
    final idQuizz = result.id.toHexString();
    for (var question in quizz.questions!) {
      question.id_quizz = idQuizz;
      var result = await db.collection('Question').insertOne(question.toJson());
      print("Questions inséré avec succès dans MongoDB !");
      final idQuestion = result.id.toHexString();
      for (var reponse in question.reponses!) {
        reponse.id_qu = idQuestion;
        await db.collection('Reponse').insertOne(reponse.toJson());
        print("Reponse inséré avec succès dans MongoDB !");
      }
    }
  }


  Future<List<Quizz>> getListQuizz(String categorieId) async {
    List<Quizz> listeQuizz = [];
    await ensureConnected();
    final collection = db.collection('Quizz');
    var filter = {'id_categ': mongo.ObjectId.fromHexString(categorieId)};
    var result = await collection.find(filter).toList();
    for (var doc in result) {
        listeQuizz.add(Quizz(id: doc['_id'].toHexString(), nom: doc['nom'], id_categ: doc['id_categ'].toString()));
    }
    return listeQuizz;
  }

  Future<List<Question>> getListQuestions(String quizzId) async {
    List<Question> listeQuestions = [];
    await ensureConnected();
    final collectionQuestion = db.collection('Question');
    var filter = {'id_quizz': mongo.ObjectId.fromHexString(quizzId)};
    var questions = await collectionQuestion.find(filter).toList();
    for (var question in questions) {
      List<Reponse> listeReponses = [];
      final collectionReponse = db.collection('Reponse');
      var filterReponse = {'id_qu': mongo.ObjectId.fromHexString(question['_id'].toHexString())};
      var reponses = await collectionReponse.find(filterReponse).toList();
      for (var reponse in reponses) {
        listeReponses.add(Reponse(id: reponse['_id'].toHexString(), id_qu: reponse['id_qu'].toHexString(), texte: reponse['texte'], is_correct: reponse['is_correct']));
      }
      listeQuestions.add(Question(id: question['_id'].toHexString(), id_quizz: question['id_quizz'].toHexString(), texte: question['texte'], timer: question['timer'], reponses: listeReponses));
    }
  return listeQuestions;
  }

  Future<void> saveResult(int score, List<Question> questions, Map<String, dynamic> userInfo) async {
    await ensureConnected();
    final userId = userInfo['_id'];
    final collectionNote = db.collection('Note');
    var note = Note(id_quiz: questions[0].id_quizz, id_user: userId.toHexString(), score: score, date: DateTime.now());
    await collectionNote.insertOne(note.toJson());
    print('Note enregistrée avec succès');
  }

  Future<List<Quizz>> getListQuizzByCategorie(String categorieId) async {
    List<Quizz> listeQuizz = [];
    await ensureConnected();
    final collection = db.collection('Quizz');
    var filter = {'id_categ': mongo.ObjectId.fromHexString(categorieId)};
    var result = await collection.find(filter).toList();
    for (var doc in result) {
      listeQuizz.add(Quizz(id: doc['_id'].toHexString(), nom: doc['nom'], id_categ: doc['id_categ'].toHexString()));
    }
    return listeQuizz;
  }

  Future<List<Note>> getListNoteByQuizz(String categorieId, String userId) async {
    List<Quizz> listeQuizz = await getListQuizzByCategorie(categorieId);
    List<Note> listeNoteUser = [];
    await ensureConnected();
    final collection = db.collection('Note');
    var filter = {'id_user': mongo.ObjectId.fromHexString(userId)};
    var result = await collection.find(filter).toList();
    for (var note in result) {
      for (var quizz in listeQuizz) {
        if (note['id_quiz'].toHexString() == quizz.id) {
          listeNoteUser.add(Note(id: note['_id'].toHexString(), id_quiz: note['id_quiz'].toHexString(), id_user: note['id_user'].toHexString(), score: note['score'], date: note['date']));
        }
      }
    }
    return listeNoteUser;
  }

  Future<void> editQuizz(Quizz quizz) async {
    await ensureConnected();
    await db.collection('Quizz').updateOne({'_id': mongo.ObjectId.fromHexString(quizz.id!)}, mongo.modify.set('nom', quizz.nom));
    await db.collection('Question').deleteMany({'id_quizz': mongo.ObjectId.fromHexString(quizz.id!)});
    await db.collection('Reponse').deleteMany({'id_qu': mongo.ObjectId.fromHexString(quizz.questions![0].id!)});
    for (var question in quizz.questions!) {
      question.id_quizz = quizz.id!;
      await db.collection('Question').insertOne(question.toJson());
      for (var reponse in question.reponses!) {
        reponse.id_qu = question.id!;
        await db.collection('Reponse').insertOne(reponse.toJson());
      }
    }
  }

  Future<void> deleteQuizz(String quizzId) async {
    await ensureConnected();
    await db.collection('Quizz').deleteOne({'_id': mongo.ObjectId.fromHexString(quizzId)});
    await db.collection('Question').deleteMany({'id_quizz': mongo.ObjectId.fromHexString(quizzId)});
    await db.collection('Reponse').deleteMany({'id_qu': mongo.ObjectId.fromHexString(quizzId)});
  }
}
