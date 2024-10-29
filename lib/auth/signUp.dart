// lib/auth/signUp.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'login.dart';
import '../bdd/connectToDTB.dart';
import '../Views/homPage.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  late MongoDBService mongoDBService;

  @override
  void initState() {
    super.initState();
    mongoDBService = MongoDBService();
    mongoDBService.connect(); // Connexion à MongoDB au lancement
  }

  @override
  void dispose() {
    mongoDBService.close(); // Ferme la connexion lors de la destruction du widget
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('SignUp'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Login'),
              Tab(text: 'Sign Up'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            SignUpCard(mongoDBService: mongoDBService),
            LoginPage(),
          ],
        ),
      ),
    );
  }
}

class DropDownButton with ChangeNotifier {
  int selectedMotivationIndex = 0;

  void setSelectedMotivationIndex(int index) {
    selectedMotivationIndex = index;
    notifyListeners();
  }
}

const List<String> list = <String>['Poursuite d\'étude', 'Réorientation', 'Reconversion'];

class SignUpCard extends StatelessWidget {
  final MongoDBService mongoDBService;
  final GlobalKey<FormState> _signUpFormKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final prenomController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final ageController = TextEditingController();
  final adresseController = TextEditingController();

  SignUpCard({required this.mongoDBService});

  void _signUpUser(BuildContext context) async {
    if (_signUpFormKey.currentState!.validate()) {
      String nom = nameController.text;
      String prenom = prenomController.text;
      String email = emailController.text;
      String password = passwordController.text;
      int age = int.tryParse(ageController.text) ?? 0;
      int adressePostale = int.tryParse(adresseController.text) ?? 0;
      int motivation = Provider.of<DropDownButton>(context, listen: false).selectedMotivationIndex;

      final documentToInsert = {
        'nom': nom,
        'prenom': prenom,
        'mail': email,
        'password': password,
        'age': age,
        'adresse_postale': adressePostale,
        'admin': false,
        'motivation': motivation,
      };

      // Appel de la fonction d'insertion dans MongoDB
      await mongoDBService.insertUser(documentToInsert);
      print("Inscription réussie pour l'utilisateur : $nom");

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final motivationProvider = Provider.of<DropDownButton>(context);

    return Scaffold(
      body: Center(
        child: Card(
          child: SingleChildScrollView(
            child: Form(
              key: _signUpFormKey,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextFormField(
                      controller: nameController,
                      decoration: InputDecoration(labelText: 'Nom'),
                    ),
                    TextFormField(
                      controller: prenomController,
                      decoration: InputDecoration(labelText: 'Prénom'),
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: emailController,
                      decoration: InputDecoration(labelText: 'Email'),
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: passwordController,
                      decoration: InputDecoration(labelText: 'Password'),
                      obscureText: true,
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: ageController,
                      decoration: InputDecoration(labelText: 'Age'),
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: adresseController,
                      decoration: InputDecoration(labelText: 'Adresse Postale'),
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 20),
                    Text('Motivation'),
                    Column(
                      children: List.generate(list.length, (index) {
                        return RadioListTile<int>(
                          title: Text(list[index]),
                          value: index,
                          groupValue: motivationProvider.selectedMotivationIndex,
                          onChanged: (int? value) {
                            if (value != null) {
                              motivationProvider.setSelectedMotivationIndex(value);
                            }
                          },
                        );
                      }),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => HomePage()), // Redirection vers HomePage
                        );
                      },
                      child: Text('Retour à la page d\'accueil'),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => _signUpUser(context),
                      child: Text('Signup'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
