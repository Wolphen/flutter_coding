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
  }

  Future<void> updateUser(Map<String, dynamic> document, String id) async {
    print("UpdateUser en cours");
    if (!_isConnected) {
      await connect();
    }
    await userCollection.updateOne(
      mongo.where.eq('_id', mongo.ObjectId.parse(id)),
      mongo.modify.set('nom', document['nom'])
          .set('prenom', document['prenom'])
          .set('mail', document['mail'])
          .set('age', document['age'])
          .set('adresse_postale', document['adresse_postale'])
          .set('motivation', document['motivation']),
    );

  }

  Future<Map<String, dynamic>?> findUserById(String id) async {
    print("UserProfil détecté");
    if (!_isConnected) {
      await connect();
    }
    final objectId = mongo.ObjectId.parse(id);
    final user = await userCollection.findOne({"_id": objectId});
    print("UserProfil détecté $user");
    return user;
  }



  Future<void> close() async {
    await db.close();
    _isConnected = false;
    print('Connexion à MongoDB fermée.');
  }
}