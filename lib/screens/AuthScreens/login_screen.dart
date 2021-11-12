import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login_app/main.dart';
import 'package:flutter_login_app/providers/auth_provider.dart';
import 'package:flutter_login_app/screens/AuthScreens/register.dart';
import 'package:flutter_login_app/screens/AuthScreens/reset_screen.dart';
import 'package:flutter_login_app/screens/home_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
      ),
      body: isLoading == false
          ? Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  TextFormField(
                    controller: _email,
                    decoration: InputDecoration(hintText: "Email"),
                  ),
                  TextFormField(
                    controller: _password,
                    decoration: InputDecoration(hintText: "PassWord"),
                  ),
                  ElevatedButton(
                      onPressed: () {
                        setState(() {
                          isLoading = true;
                        });
                        AuthClass()
                            .signIn(
                                email: _email.text.trim(),
                                password: _password.text.trim())
                            .then((value) {
                          if (value == "Welcome") {
                            setState(() {
                              isLoading = false;
                            });
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => HomePage()));
                          } else {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(SnackBar(content: Text(value)));
                          }
                        });
                      },
                      child: const Text('Log in')),
                  const SizedBox(
                    height: 20,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => RegisterScreen()));
                    },
                    child: Text("Don't have acount? register"),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ResetScreen()));
                    },
                    child: Text("Forgot password"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      //sign in with google
                      AuthClass()
                          .signinWithGoogle()
                          .then((UserCredential value) {
                        bool IsfirstTime = value.additionalUserInfo!.isNewUser;
                        if (IsfirstTime) {
                          if (value.additionalUserInfo!.isNewUser) {
                            AuthClass().postDetailsTofireStore(
                                value.user!.displayName.toString());
                          }
                        }
                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (_) => HomePage()),
                            (route) => false);
                      });
                    },
                    child: Text('Login with Google'),
                    style: ElevatedButton.styleFrom(primary: Colors.red),
                  ),
                  ElevatedButton(
                      onPressed: () {
                        AuthClass()
                            .signInWithFaceBook()
                            .then((UserCredential value) {
                          print(value.user!.displayName);
                          if (value.additionalUserInfo!.isNewUser) {
                            AuthClass().postDetailsTofireStore(
                                value.user!.displayName.toString());
                          }
                          Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (_) => HomePage()),
                              (route) => false);
                        });
                      },
                      child: Text('Login with Facebook'))
                ],
              ),
            )
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}
