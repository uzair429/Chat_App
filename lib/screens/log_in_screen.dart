import 'package:chap_app/model/uihelper_model.dart';
import 'package:chap_app/model/user_model.dart';
import 'package:chap_app/screens/home_screen.dart';
import 'package:chap_app/screens/sign_up_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LogInScreen extends StatefulWidget {
  const LogInScreen({Key? key}) : super(key: key);

  @override
  _LogInScreenState createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> {

  var emailController = TextEditingController();
  var passwordController = TextEditingController();


  void check(){

    var email = emailController.text.trim();
    var password = passwordController.text.trim();

    if(email.isEmpty || password.isEmpty){
      print('Complete Fields');
    }else{
      signIn(email,password);
    }
  }

  void signIn(String email, String password) async{

    UserCredential? userCredential;
    UIHelper.showLoadingDialog(context, "Loading....");
    try{
      userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch(ex){
      Navigator.pop(context);
      UIHelper.showAlertDialog(context, "An Error occurred", ex.message.toString());
      print(ex.message.toString());
    }
    if(userCredential != null){
      String uid = userCredential.user!.uid;

      DocumentSnapshot userData = await FirebaseFirestore.instance
          .collection('users').doc(uid).get();


      UserModel userModel =
        UserModel.fromMap(userData.data() as Map<String , dynamic>);

      print("******************Successful******************");
      Navigator.popUntil(context, (route) => route.isFirst);
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context){
        return  HomeScreen(userModel: userModel, firebaseUser: userCredential!.user!,);
      }));
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 40),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Text('CHAT BUDDY', style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),),

                const SizedBox(
                  height: 20,
                ),

                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: "Email Address"
                  ),
                ),

                const SizedBox(
                  height: 20,
                ),

                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                      labelText: "Password"
                  ),
                ),

                const SizedBox(
                  height: 20,
                ),
                CupertinoButton(
                    child: Text("Log In"),
                    onPressed: (){
                      check();
                    },
                  color: Theme.of(context).colorScheme.secondary,

                ),

              ],
            ),
          ),
        ),
      ),
      ),
      bottomNavigationBar: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Don't have an account? "
            ),
            CupertinoButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context){
                  return SignUPScreen();
                }));
              },
              child: Text('Sign Up',style: TextStyle(
                color: Colors.blue,
                fontSize: 16
              ),),
            )
          ],
        ),
      ),
    );
  }
}
