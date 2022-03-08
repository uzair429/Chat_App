// import 'package:chap_app/model/firbase_helper.dart';
// import 'package:chap_app/screens/home_screen.dart';
// import 'package:chap_app/screens/log_in_screen.dart';
// import 'package:chap_app/screens/sign_up_screen.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
// import 'package:uuid/uuid.dart';
//
// var uuid = Uuid();
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();
//   User? currentUser = FirebaseAuth.instance.currentUser;
//   UserModel? thisUserModel = await FirebaseHelper
//       .getUserModelById(currentUser!.uid);
//   runApp(MyApp());
// }
//
// class MyApp2 extends StatelessWidget {
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       //home : SignUPScreen()
//           home : LogInScreen()
//     );
//   }
// }
// class MyApp extends StatelessWidget {
//    const MyApp({Key? key}) : super(key: key);
//
//   //User? currentUser = FirebaseAuth.instance.currentUser;
//   get currentUser => null;
//   get thisUserModel => null;
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       //home : SignUPScreen()
//       home: FirebaseAuth.instance.currentUser == null? LogInScreen():
//            HomeScreen(userModel: thisUserModel,firebaseUser: currentUser,),
//     );
//   }
// }
//
//
//

import 'package:chap_app/screens/home_screen.dart';
import 'package:chap_app/screens/log_in_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'model/firbase_helper.dart';
import 'model/user_model.dart';

var uuid = Uuid();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  User? currentUser = FirebaseAuth.instance.currentUser;
  if(currentUser != null) {
    // Logged In
    UserModel? thisUserModel = await FirebaseHelper.getUserModelById(currentUser.uid);
    if(thisUserModel != null) {
     // runApp(MyApp());
      runApp(MyAppLoggedIn(userModel: thisUserModel, firebaseUser: currentUser));
    }
    else {
      runApp(MyApp());
    }
  }
  else {
    // Not logged in
    runApp(MyApp());
  }
}


// Not Logged In
class MyApp extends StatelessWidget {
  const MyApp({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LogInScreen(),
    );
  }
}


// Already Logged In
class MyAppLoggedIn extends StatelessWidget {
  final UserModel userModel;
  final User firebaseUser;

  const MyAppLoggedIn({Key? key, required this.userModel, required this.firebaseUser}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(userModel: userModel, firebaseUser: firebaseUser),
    );
  }
}
