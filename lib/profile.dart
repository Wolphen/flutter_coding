import 'package:flutter/material.dart';
import 'package:flutter_coding/Models/note.dart';
import './bdd/connectToDTB.dart';
import './auth/signUp.dart';
import './Controllers/homePage.dart';
import 'Models/categorie.dart';
import './Controllers/listNote.dart';

class UserProfilePage extends StatefulWidget {
  final String id;

  const UserProfilePage({Key? key, required this.id}) : super(key: key);

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
  List<Categorie> categories = [];
  List averageScores = [];
  List<Note> notes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    mongoDBService = MongoDBService();
    loadUserData().then((_) {
      loadCategories().then((_) {
        for (var categorie in categories) {
          getListNote(categorie.id, widget.id).then((value) {
            notes = value;
            print(notes);
            print('Average scores loaded for category ${categorie.id}');
            averageScores = notes.map((note) => note.score).toList();
          });

        }
      });
      for (var score in averageScores) {
        print(score.score);
        print(score.id_quiz);
        print(score.id_user);
        print(score.date);
      }
    });
  }

  Future<List<Categorie>> loadCategories() async {
    final fetchedCategories = await onInit();
    setState(() {
      categories = fetchedCategories;
      isLoading = false;
    });
    return categories;
  }

  Future<Map<String, dynamic>?> loadUserData() async {
    final fetchedUser = await mongoDBService.findUserById(widget.id);
    setState(() {
      user = fetchedUser;
      nomController.text = user?['nom'] ?? '';
      prenomController.text = user?['prenom'] ?? '';
      mailController.text = user?['mail'] ?? '';
      ageController.text = user?['age'].toString() ?? '';
      adressePostaleController.text = user?['adresse_postale'].toString() ?? '';
      selectedMotivation = user?['motivation'];
    });
    return user;
  }

  Future<void> updateUser() async {
    Map<String, dynamic> updatedUser = {
      'nom': nomController.text,
      'prenom': prenomController.text,
      'mail': mailController.text,
      'age': int.parse(ageController.text),
      'adresse_postale': int.parse(adressePostaleController.text),
      'motivation': selectedMotivation,
    };

    try {
      await mongoDBService.updateUser(updatedUser, widget.id);
      Navigator.of(context).pop();
      loadUserData();
    } catch (e) {
      showErrorDialog("Erreur lors de la mise à jour des données.");
    }
  }

  void showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) =>
          AlertDialog(
            title: Text("Erreur"),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text("OK"),
              ),
            ],
          ),
    );
  }

  @override
  void dispose() {
    mongoDBService.close();
    super.dispose();
  }

  void showEditDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) =>
              AlertDialog(
                insetPadding: EdgeInsets.symmetric(horizontal: 20),
                title: Text("Modifier le profil"),
                content: SizedBox(
                  width: MediaQuery
                      .of(context)
                      .size
                      .width * 0.9,
                  child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextFormField(
                            controller: nomController,
                            decoration: InputDecoration(labelText: 'Nom'),
                            validator: (value) =>
                            value!.isEmpty
                                ? 'Entrez un nom'
                                : null,
                          ),
                          TextFormField(
                            controller: prenomController,
                            decoration: InputDecoration(labelText: 'Prénom'),
                            validator: (value) =>
                            value!.isEmpty
                                ? 'Entrez un prénom'
                                : null,
                          ),
                          TextFormField(
                            controller: mailController,
                            decoration: InputDecoration(labelText: 'Email'),
                            validator: (value) {
                              if (value!.isEmpty) return 'Entrez un email';
                              final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                              return regex.hasMatch(value)
                                  ? null
                                  : 'Entrez un email valide';
                            },
                          ),
                          TextFormField(
                            controller: adressePostaleController,
                            decoration: InputDecoration(
                                labelText: 'Adresse Postale'),
                            keyboardType: TextInputType.number,
                            validator: (value) =>
                            value!.isEmpty
                                ? 'Entrez votre adresse postale'
                                : null,
                          ),
                          TextFormField(
                            controller: ageController,
                            decoration: InputDecoration(labelText: 'Âge'),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value!.isEmpty) return 'Entrez votre âge';
                              final age = int.tryParse(value);
                              return (age != null && age > 0)
                                  ? null
                                  : 'Entrez un âge valide';
                            },
                          ),
                          Column(
                            children: List.generate(list.length, (index) {
                              return RadioListTile<int>(
                                title: Text(list[index]),
                                value: index,
                                groupValue: selectedMotivation,
                                onChanged: (int? value) {
                                  setDialogState(() {
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
      },
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
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Text(
                "Scores de l'utilisateur",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
            ),
            Center(
              child: isLoading
                  ? const CircularProgressIndicator()
                  : Wrap(
                spacing: 10.0,
                runSpacing: 10.0,
                alignment: WrapAlignment.center,
                children: categories.map((categorie) {
                  return _buildCard(categorie);
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  final List<Color> buttonColors = [
    Colors.red,
    Colors.blue,
    Colors.green,
  ];

  Widget _buildCard(Categorie categorie) {

    return SizedBox(
      width: 400,
      height: 300,
      child: Card(
        color: buttonColors[categories.indexOf(categorie) %
            buttonColors.length],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              categorie.nom,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Moyenne: ',
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
