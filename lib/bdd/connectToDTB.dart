import 'package:mongo_dart/mongo_dart.dart' as mongo;

class MongoDBService {
  late mongo.Db db;
  late mongo.DbCollection userCollection;
  bool _isConnected = false;

  Future<void> connect() async {
    if (!_isConnected) {
      var password = 'root';
      final encodedPassword = Uri.encodeComponent(password);
      db = await mongo.Db.create(
          'mongodb+srv://root:$encodedPassword@flutter.d1rxd.mongodb.net/Flutter?retryWrites=true&w=majority&appName=Flutter');
      await db.open();
      userCollection = db.collection('User');
      _isConnected = true;
      print('Connexion réussie à MongoDB !');
    }
  }

  Future<void> insertUser(Map<String, dynamic> document) async {
    if (!_isConnected) {
      await connect();
    }
    await userCollection.insert(document);
    print("Document inséré avec succès dans MongoDB !");
  }

  Future<void> close() async {
    await db.close();
    _isConnected = false;
    print('Connexion à MongoDB fermée.');
  }
}