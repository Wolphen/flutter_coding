// lib/auth/signUp.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'login.dart';
import '../bdd/connectToDTB.dart';
import '../Views/homPage.dart';

import 'package:email_validator/email_validator.dart';

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
    mongoDBService.connect();
  }

  @override
  void dispose() {
    mongoDBService.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('SignUp'),
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
            const LoginPage(),
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

class SignUpCard extends StatefulWidget {
  final MongoDBService mongoDBService;

  const SignUpCard({super.key, required this.mongoDBService});

  @override
  _SignUpCardState createState() => _SignUpCardState();
}

class _SignUpCardState extends State<SignUpCard> {
  final GlobalKey<FormState> _signUpFormKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final prenomController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final ageController = TextEditingController();
  final adresseController = TextEditingController();

  double passwordStrength = 0.0;

  void _signUpUser(BuildContext context) async {
    if (_signUpFormKey.currentState!.validate()) {
      String email = emailController.text;

      bool emailAlreadyExists = await widget.mongoDBService.emailExists(email);

      if (emailAlreadyExists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Cet email est déjà utilisé")),
        );
        return;
      }

      String nom = nameController.text;
      String prenom = prenomController.text;
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

      await widget.mongoDBService.insertUser(documentToInsert);
      print("Inscription réussie pour l'utilisateur : $nom");

      nameController.clear();
      prenomController.clear();
      emailController.clear();
      passwordController.clear();
      ageController.clear();
      adresseController.clear();

      DefaultTabController.of(context).animateTo(1); // Bascule vers l'onglet Login
    }
  }

  void checkPasswordStrength(String password) {
    double strength = 0;

    if (password.length >= 8) strength += 0.25;
    if (RegExp(r"[A-Z]").hasMatch(password)) strength += 0.25;
    if (RegExp(r"[a-z]").hasMatch(password)) strength += 0.25;
    if (RegExp(r"[0-9]").hasMatch(password)) strength += 0.25;

    setState(() {
      passwordStrength = strength;
    });
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
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Nom'),
                      validator: (value) => value!.isEmpty ? 'Nom requis' : null,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: prenomController,
                      decoration: const InputDecoration(labelText: 'Prénom'),
                      validator: (value) => value!.isEmpty ? 'Prénom requis' : null,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: emailController,
                      decoration: const InputDecoration(labelText: 'Email'),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Email requis';
                        if (!EmailValidator.validate(value)) return 'Email invalide';
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: passwordController,
                      decoration: const InputDecoration(labelText: 'Mot de passe'),
                      obscureText: true,
                      onChanged: checkPasswordStrength,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Mot de passe requis';
                        if (passwordStrength < 1) return 'Mot de passe faible';
                        return null;
                      },
                    ),
                    const SizedBox(height: 5),
                    LinearProgressIndicator(value: passwordStrength, minHeight: 6),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: ageController,
                      decoration: const InputDecoration(labelText: 'Age'),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: adresseController,
                      decoration: const InputDecoration(labelText: 'Adresse Postale'),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 10),
                    const Text('Situation'),
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
                    const SizedBox(height: 20),
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
                      child: const Text('Signup'),
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
