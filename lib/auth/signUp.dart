import 'package:flutter/material.dart';
import 'package:flutter_coding/auth/login.dart';
import 'package:provider/provider.dart';

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
                    // Handle signup logic here
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
}