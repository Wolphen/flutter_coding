import 'package:flutter/material.dart';
import '../connectToDTB.dart';
import 'signUp.dart';

class UserProfilePage extends StatefulWidget {
  final String userId;

  UserProfilePage({required this.userId});

  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  Map<String, dynamic>? user;
  late MongoDBService mongoDBService;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nomController = TextEditingController();
  final TextEditingController prenomController = TextEditingController();
  final TextEditingController mailController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController adressePostaleController = TextEditingController();
  int? selectedMotivation;

  @override
  void initState() {
    super.initState();
    mongoDBService = MongoDBService();
    loadUserData();
    if (user != null) {
      selectedMotivation = user!['motivation'];
    }
  }

  Future<void> loadUserData() async {
    final fetchedUser = await mongoDBService.findUserById(widget.userId);
    setState(() {
      user = fetchedUser;
      nomController.text = user?['nom'] ?? '';
      prenomController.text = user?['prenom'] ?? '';
      mailController.text = user?['mail'] ?? '';
      ageController.text = user?['age'].toString() ?? '';
      adressePostaleController.text = user?['adresse_postale'].toString() ?? '';
      selectedMotivation = user?['motivation'];
    });
  }

  Future<void> updateUser() async {
   // On créer un document avec les données update
    Map<String, dynamic> updatedUser = {
      'nom': nomController.text,
      'prenom': prenomController.text,
      'mail': mailController.text,
      'age': int.parse(ageController.text),
      'adresse_postale': int.parse(adressePostaleController.text),
      'motivation': selectedMotivation,
    };

    await mongoDBService.updateUser(updatedUser, widget.userId);
    Navigator.of(context).pop();
    loadUserData();
  }

  @override
  void dispose() {
    mongoDBService.close();
    super.dispose();
  }

  void showEditDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        insetPadding: EdgeInsets.symmetric(horizontal: 20),
        title: Text("Modifier le profil"),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nomController,
                    decoration: InputDecoration(labelText: 'Nom'),
                    validator: (value) => value!.isEmpty ? 'Entrez un nom' : null,
                    onSaved: (value) {
                      user!['nom'] = value;
                    },
                  ),
                  TextFormField(
                    controller: prenomController,
                    decoration: InputDecoration(labelText: 'Prénom'),
                    validator: (value) => value!.isEmpty ? 'Entrez un prénom' : null,
                    onSaved: (value) {
                      user!['prenom'] = value;
                    },
                  ),
                  TextFormField(
                    controller: mailController,
                    decoration: InputDecoration(labelText: 'Email'),
                    validator: (value) => value!.isEmpty ? 'Entrez un email' : null,
                    onSaved: (value) {
                      user!['email'] = value;
                    },
                  ),
                  TextFormField(
                    controller: adressePostaleController,
                    decoration: InputDecoration(labelText: 'Adresse Postale'),
                    keyboardType: TextInputType.number,
                    validator: (value) => value!.isEmpty ? 'Entrez votre adresse postale' : null,
                    onSaved: (value) {
                      user!['adresse_postale'] = value;
                    },
                  ),
                  TextFormField(
                    controller: ageController,
                    decoration: InputDecoration(labelText: 'Âge'),
                    keyboardType: TextInputType.number,
                    validator: (value) => value!.isEmpty ? 'Entrez votre âge' : null,
                    onSaved: (value) {
                      user!['age'] = value;
                    },
                  ),
                  Column(
                    children: List.generate(list.length, (index) {
                      return RadioListTile(
                        title: Text(list[index]),
                        value: index,
                        groupValue: selectedMotivation,
                        onChanged: (value) {
                          setState(() {
                            selectedMotivation = value;
                          });
                        },
                      );
                    }),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: ElevatedButton(
                      child: const Text('Enregistrer'),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          updateUser();
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profil Utilisateur"),
      ),
      body: user == null
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${user!['nom']} ${user!['prenom']}',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 15),
            Row(
              children: [
                Icon(Icons.email, color: Colors.deepPurple),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Email: ${user!['mail']}',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.cake, color: Colors.deepPurple),
                SizedBox(width: 10),
                Text(
                  'Âge: ${user!['age']}',
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.deepPurple),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Adresse postale: ${user!['adresse_postale']}',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.emoji_emotions, color: Colors.deepPurple),
                SizedBox(width: 10),
                Text(
                  'Motivation: ${list[user!['motivation']]}',
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
            SizedBox(height: 25),
            ElevatedButton.icon(
              onPressed: () {
                showEditDialog();
              },
              icon: Icon(Icons.edit),
              label: Text("Modifier le profil"),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.deepPurple,
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 40),
            Divider(thickness: 1.5),
            /*Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Text(
                "Scores de l'utilisateur",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  "L'utilisateur n'a pas de scores",
                  style: TextStyle(fontSize: 18, color: Colors.black54),
                ),
              ),
            ),*/
          ],
        ),
      ),
    );
  }
}