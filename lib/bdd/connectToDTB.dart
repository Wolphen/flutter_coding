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

  bool isConnected() {
    return _isConnected;
  }

  // Attendre que la connexion soit établie et que userCollection soit initialisé
  Future<void> ensureConnected() async {
    if (!_isConnected || userCollection == null) {
      await connect(); // Appel de connect si non connecté
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
        'userId': userId,
        'nom': nom,       // Ajout du nom (ou pseudo)
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
