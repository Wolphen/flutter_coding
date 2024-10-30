import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'signUp.dart';
import '../connectToDTB.dart';
import 'profile.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    final mongoDBService = Provider.of<MongoDBService>(context, listen: false);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: Text('Login'),
            bottom: const TabBar(
              tabs: [
                Tab(text: 'SignUp'),
                Tab(text: 'Login'),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              SignUpCard(mongoDBService: mongoDBService), // Passe mongoDBService ici
              LoginCard(),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserProfilePage(userId: '672108069258caa56a000000'), // Redirige vers la page UserProfile avec un userId fictif à remplacer par l'id de l'utilisateur connecté avec la Session
                ),
              );
            },
            child: Icon(Icons.person),
          ),
        ),
      ),
    );
  }
}

class LoginCard extends StatelessWidget {
  final GlobalKey<FormState> _loginFormKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Card(
          child: Form(
            key: _loginFormKey,
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
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
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      // Logic de connexion
                      print("Email: ${emailController.text}, Password: ${passwordController.text}");
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