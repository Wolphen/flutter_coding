import 'package:flutter/material.dart';
import 'package:flutter_coding/auth/signUp.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
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
              SignUpCard(),
              LoginCard()
            ],
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
        child:Card(
        child: Form(
          key: _loginFormKey,
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(labelText: 'Email'),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: passwordController,
                  decoration: InputDecoration(labelText: 'Password'),
                  obscureText: true,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    // Handle login logic here
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
