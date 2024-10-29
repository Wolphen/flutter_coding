import 'package:flutter/material.dart';
import 'package:flutter_coding/auth/login.dart';
import '../main.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  @override
   Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DefaultTabController(
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
              SignUpCard(),
              LoginPage()
            ],
          ),
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

const List<String> list = <String>['Poursuite d\'étude','Réorientation','Reconversion'];

class SignUpCard extends StatelessWidget {

  final GlobalKey<FormState> _signUpFormKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final prenomController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final ageController = TextEditingController();
  final adresseController = TextEditingController();
  final motivationController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Card(
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
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: adresseController,
                  decoration: InputDecoration(labelText: 'Adresse Postale'),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    final newUser = new User(
                      name: nameController.text, 
                      surname: prenomController.text, 
                      mail: emailController.text, 
                      age: int.parse(ageController.text), 
                      adresse_postale: int.parse(adresseController.text),
                      nb_quizz: 0,
                      admin: true,
                      motivation: 0
                    );
                    register(newUser);
                  },
                  child: Text('Signup'),
                ),
              ],
            ),
          ),
        ),
        ),
      ),
    );
  }

  Future<void> register(User newUser) async {
    var password = 'root';
    final encodedPassword = Uri.encodeComponent(password);
    var db = await mongo.Db.create('mongodb+srv://root:$encodedPassword@Flutter.d1rxd.mongodb.net/Flutter?retryWrites=true&w=majority&appName=Flutter');
    try {
      // Tente de te connecter
      print("Inshallah");
      await db.open();
      var collection = db.collection('users');
      await collection.insert({
        'name': newUser.name,
        'surname': newUser.surname,
        'mail': newUser.mail,
        'age': newUser.age,
        'adresse_postale': newUser.adresse_postale,
        'nb_quizz': newUser.nb_quizz,
        'admin': newUser.admin,
        'motivation': newUser.motivation
      });
    } catch (e) {
      print("Échec de la connexion à MongoDB : $e");
    } finally {
      // Ferme la connexion, même si elle échoue
      await db.close();
    }
  }
}

