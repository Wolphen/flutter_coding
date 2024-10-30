import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../bdd/session_manager.dart';
import '../Views/homPage.dart'; // Assurez-vous de bien importer home_page.dart ici
import '../bdd/connectToDTB.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void _login() async {
    final email = emailController.text;
    final password = passwordController.text;
    final mongoDBService = Provider.of<MongoDBService>(context, listen: false);

    final result = await mongoDBService.loginUser(email, password);
    if (result != null) {
      final token = result["token"];
      final userInfo = result["userInfo"];
      await SessionManager.saveToken(token); // Sauvegarde du token
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(userInfo: userInfo),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email ou mot de passe incorrect")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Connexion")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Mot de passe'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login,
              child: const Text("Se connecter"),
            ),
          ],
        ),
      ),
    );
  }
}


class LoginCard extends StatelessWidget {
  final GlobalKey<FormState> _loginFormKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  LoginCard({super.key});

  @override
  Widget build(BuildContext context) {
    final mongoDBService = Provider.of<MongoDBService>(context, listen: false);

    return Scaffold(
      body: Center(
        child: Card(
          child: Form(
            key: _loginFormKey,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: passwordController,
                    decoration: const InputDecoration(labelText: 'Password'),
                    obscureText: true,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      final email = emailController.text.trim();
                      final password = passwordController.text.trim();

                      print("Tentative de connexion avec Email: '$email' et Password: '$password'");

                      bool userExists = await mongoDBService.findUser(email, password);

                      if (userExists) {
                        print("Utilisateur trouvé");
                      } else {
                        print("Utilisateur non trouvé.");
                      }
                    },
                    child: const Text('Login'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}



