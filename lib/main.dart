import 'package:chatap/pages/home.dart';
import 'package:chatap/pages/service/auth.dart';
import 'package:chatap/pages/signin.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    String email = '', name = '', pic = '', username = '';


    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: 
      const SignIn()
      
      // FutureBuilder(
      //     future: AuthMethods().getCurrentUser(),
      //     builder: (context, AsyncSnapshot<dynamic> snapshot) {
          
      //       if (snapshot.hasData) {
      //         return HomePage(
      //             myName: name,
      //             myProfilePic: pic,
      //             myUserName: username,
      //             myEmail: email);
      //       }else{
      //         return const SignIn();
      //       }
      //     }),
    );
  }
}