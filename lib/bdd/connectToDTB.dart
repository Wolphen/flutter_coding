import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;

import '../Models/note.dart';
import '../Models/quizz.dart';

class MongoDBService {
  late mongo.Db db;
  mongo.DbCollection? userCollection;
  mongo.DbCollection? notesCollection;
  mongo.DbCollection? quizCollection;
  mongo.DbCollection? categorieCollection;
  bool _isConnected = false;
  static const String _secretKey = 'ton_secret_key';

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

  Future<List<Map<String, dynamic>>> getCategories() async {
    final collection = db.collection('Categorie');
    final categories = await collection.find().toList();
    return categories.map((category) => category as Map<String, dynamic>).toList();
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
    var filter = {'id_user': userId};
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

  /*Future<Map<String, double>> getAverageScoresByCategory(String userId, String categoryId) async {
    await ensureConnected();

    if (categorieCollection == null || quizCollection == null || notesCollection == null) {
      throw Exception("Collections non initialisées");
    }

    final categories = await categorieCollection!.find().toList();
    print('Categories: $categories');

    Map<String, double> averageScores = {};
    for (var category in categories) {
      String categoryName = category['nom'];
      final quizzes = await quizCollection!.find({"id_categ": category['_id']}).toList();
      print('Quizzes for category $categoryName: $quizzes');

      double moyenneScores = 0.0;
      int totalNotes = 0;

      for (var quiz in quizzes) {


        final notes = await notesCollection!.find({"id_quiz": quiz['_id'], "id_user": userId}).toList();
        for (var note in notes) {
          print("Voici toutes les notes ");
          double score = note['score']?.toDouble() ?? 0.0;
          print('Francois renvoie $score');
          moyenneScores += score;
          totalNotes++;
        }
      }
      double averageScore = totalNotes > 0 ? (moyenneScores / totalNotes) : 0;
      averageScores[categoryName] = averageScore;
    }
    return averageScores;
  }*/

  Future<void> updateUser(Map<String, dynamic> document, String id) async {
    await ensureConnected();
    print("UpdateUser en cours");
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
    await ensureConnected();
    print("ID reçu dans findUserById: $id");
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
        'userId': userId.toString().replaceAll('ObjectId("', '').replaceAll('")', ''), // Utilise uniquement la partie hexadécimale
        'nom': nom,
        'mail': email,
        'admin': admin,
      },
    );
    return jwt.sign(SecretKey(_secretKey), expiresIn: const Duration(minutes: 2));
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
    print('Connexion à MongoDB fermée.');
  }
}
