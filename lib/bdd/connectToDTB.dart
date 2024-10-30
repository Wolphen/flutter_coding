import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;

class MongoDBService {
  late mongo.Db db;
  mongo.DbCollection? userCollection; // Rendre userCollection nullable
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

  Future<void> updateUser(Map<String, dynamic> document, String id) async {
    print("UpdateUser en cours");

    if (!_isConnected) {
      await connect();
    }
    // Nettoie l'Object id pour qu'il ne contienne que la partie décimale
    final match = RegExp(r'ObjectId\("([a-fA-F0-9]{24})"\)').firstMatch(id);
    final cleanedId = match != null ? match.group(1) : id;  // Si l'ID est déjà propre, on l'utilise tel quel

    print("ID nettoyé dans updateUser: $cleanedId");  // Affiche l'ID nettoyé

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
    print("ID reçu dans findUserById: $id");  // Affiche l'ID reçu

    if (!_isConnected) {
      await connect();
    }
    // Vérifie que userCollection n'est pas null
    if (userCollection == null) {
      print("userCollection est null. Assurez-vous que la connexion à MongoDB a réussi.");
      return null;
    }

    // Nettoie l'ID pour qu'il ne contienne que la partie hexadécimale
    final match = RegExp(r'ObjectId\("([a-fA-F0-9]{24})"\)').firstMatch(id);
    final cleanedId = match != null ? match.group(1) : id;  // Si l'ID est déjà propre, on l'utilise tel quel

    print("ID nettoyé dans findUserById: $cleanedId");  // Affiche l'ID nettoyé

    try {
      final objectId = mongo.ObjectId.fromHexString(cleanedId!); // Utilise uniquement l'ID hexadécimal
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

  // Attendre que la connexion soit établie et que userCollection soit initialisé
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
    print('Connexion à MongoDB fermée.');
  }
}
