import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
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
    final userIds = List.generate(10, (index) => mongo.ObjectId()); // 10 utilisateurs aléatoires

    // Récupère les catégories
    final categories = await categorieCollection!.find().toList();

    for (var categorie in categories) {
      // Crée un quiz pour chaque catégorie
      var quiz = {
        "id_user": userIds[random.nextInt(userIds.length)], // Utilisateur aléatoire pour le quiz
        "nom": "Quiz for ${categorie["nom"]}",
        "id_categ": categorie["_id"],
      };
      var quizInsertResult = await quizCollection!.insertOne(quiz);
      final quizId = quizInsertResult.id;
      print("Quiz created for category ${categorie["nom"]} with ID: $quizId");

      for (int i = 0; i < 10; i++) {
        int score = random.nextInt(11); // Note entre 0 et 10
        var note = {
          "id_quiz": quizId,
          "id_user": userIds[random.nextInt(userIds.length)], // Utilisateur aléatoire
          "score": score,
        };
        var noteInsertResult = await notesCollection!.insertOne(note);
        print("Note created with score $score for quiz $quizId in category ${categorie["nom"]}");
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
      final quizzes = await quizCollection!.find({"id_categ": category['_id']}).toList();

      int totalNotes = 0;
      int totalSuccesses = 0;

      for (var quiz in quizzes) {
        // Récupère les notes pour chaque quiz
        final notes = await notesCollection!.find({"id_quiz": quiz['_id']}).toList();

        for (var note in notes) {
          int score = note['score'] ?? 0;
          totalNotes++;
          if (score > 5) {
            totalSuccesses++;
          }
        }
      }

      // Calcule le taux de réussite
      double successRate = totalNotes > 0 ? (totalSuccesses / totalNotes) * 100 : 0;
      double failureRate = 100 - successRate;

      successRates[categoryName] = {
        'Réussite': successRate,
        'Échec': failureRate,
      };

      print("Category: $categoryName, Success Rate: $successRate%, Failure Rate: $failureRate%");
    }

    return successRates;
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
}
