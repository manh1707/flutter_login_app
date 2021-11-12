import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_login_app/providers/user_model.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthClass {
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  //create acount
  Future<String> createAcount(
      {required String email, required String password}) async {
    try {
      // ignore: unused_local_variable
      await firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password);
      return 'Acount created';
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        return 'Password is to weak';
      } else if (e.code == 'email-already-in-use') {
        return 'The acount already exists for that email.';
      }
    } catch (e) {
      return 'Erorr occured ';
    }
    return "";
  }

  //Sign in
  Future<String> signIn(
      {required String email, required String password}) async {
    try {
      await firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      return 'Welcome';
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return ('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        return ('Wrong password provided for that user.');
      }
    }
    return "";
  }

  //Reset password
  Future<String> resetPassword({required String email}) async {
    try {
      await firebaseAuth.sendPasswordResetEmail(
        email: email,
      );
      return 'Email send';
    } catch (e) {
      return 'error happen';
    }
  }

  //Logout
  void signOut() {
    firebaseAuth.signOut();
  }

  //google auth
  Future<UserCredential> signinWithGoogle() async {
    final GoogleSignInAccount? googleSignInAccount = await GoogleSignIn(
      scopes: <String>['email'],
    ).signIn();
    final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount!.authentication;
    final credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken);

    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  //facebookauth
  Future<UserCredential> signInWithFaceBook() async {
    final LoginResult result = await FacebookAuth.instance.login();
    final facebookAuthCredential =
        FacebookAuthProvider.credential(result.accessToken!.token);

    return await FirebaseAuth.instance
        .signInWithCredential(facebookAuthCredential);
  }

  postDetailsTofireStore(String name) async {
    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
    User? user = FirebaseAuth.instance.currentUser;
    UserModel userModel = UserModel();
    userModel.email = user!.email;
    userModel.uid = user.uid;
    userModel.firstName = name;
    await firebaseFirestore
        .collection('users')
        .doc(user.uid)
        .set(userModel.toMap());
  }
}
