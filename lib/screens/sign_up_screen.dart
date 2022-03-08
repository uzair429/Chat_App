import 'package:chap_app/model/uihelper_model.dart';
import 'package:chap_app/model/user_model.dart';
import 'package:chap_app/screens/completeprofile_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SignUPScreen extends StatefulWidget {
  const SignUPScreen({Key? key}) : super(key: key);

  @override
  _SignUPScreenState createState() => _SignUPScreenState();
}

class _SignUPScreenState extends State<SignUPScreen> {
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  var cPasswordController = TextEditingController();

  // Check The values of All Fields
  void check(){
    var email = emailController.text.trim();
    var password = passwordController.text.trim();
    var cPassword = cPasswordController.text.trim();

    if(email.isEmpty || password.isEmpty || cPassword.isEmpty){
      UIHelper.showAlertDialog(context, "InComplete Data", "Please Fill all the Fields");
    }else if(password != cPassword){
      UIHelper.showAlertDialog(context, "Password Mismatch", "Password You Enter Don't Match");

    }else{
      signUP(email,password);
    }
  }

  // Function For Creating New User In FireBase Auth
  void signUP(String email, String password) async {
    UserCredential? userCredential;
    UIHelper.showLoadingDialog(context, "Signing UP...");
    try{
      userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch(ex){
      UIHelper.showAlertDialog(context, "Error", ex.message.toString());
    }

    if(userCredential != null){
      // Asign the Current User Id To uid
      String uid = userCredential.user!.uid;
      // Assign the Values To The UserModel
      UserModel newUser = UserModel(
        uid: uid,
        email: email,
        fullname: '',
        profilepic: '',
      );
      // Store Data On 'Firestore Database'
      await FirebaseFirestore.instance
          .collection('users').doc(uid).set(newUser.toMap());

      print('new User Created');
      // Navigated to CompleteProfileScreen Where The userModel and UserCredentials and the required Parameters
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context){
        return CompleteProfileScreen(userModel: newUser, firebaseUser: userCredential!.user!,);
      }));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 40),
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
                        labelText: "Passeord"
                    ),
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  TextField(
                    controller: cPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                        labelText: "Conform Password"
                    ),
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  CupertinoButton(
                    child: Text("Sign Up"),
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
            const Text(
                "Already have an account? "
            ),
            CupertinoButton(
              onPressed: () {  },
              child: const Text('Log In',style: TextStyle(
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
