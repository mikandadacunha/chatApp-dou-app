// ignore_for_file: use_build_context_synchronously

import 'package:chatap/pages/forgotpassword.dart';
import 'package:chatap/pages/home.dart';
import 'package:chatap/pages/service/database.dart';
import 'package:chatap/pages/service/shared_pref.dart';
import 'package:chatap/pages/signup.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  @override
  Widget build(BuildContext context) {
    String email = '', name = '', pic = '', username = '', id = '';
    TextEditingController usermailcontroller = TextEditingController();
    TextEditingController userpasswordcontroller = TextEditingController();

    // ignore: no_leading_underscores_for_local_identifiers
    final _formkey = GlobalKey<FormState>();


    userLogin() async {
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: usermailcontroller.text,
            password: userpasswordcontroller.text);
        QuerySnapshot querySnapshot =
            await DatabaseMethods().getUserbyemail(email);

        name = '${querySnapshot.docs[0]['Name']}';
        username = '${querySnapshot.docs[0]['username']}';
        pic = '${querySnapshot.docs[0]['Phote']}';
        id = querySnapshot.docs[0].id;

        await SharedPreferencesHelper().saveUserDisplayname(name);
        await SharedPreferencesHelper().saveUserEmail(email);
        await SharedPreferencesHelper().saveUserName(username);
        await SharedPreferencesHelper().saveUserId(id);
        await SharedPreferencesHelper().saveUserPic(pic);

        ///Function to call anather page, to be repleced the scen
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => HomePage(
                      myName: name,
                      myEmail: email,
                      myProfilePic: pic,
                      myUserName: username,
                    )));
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text(
            'We soory, seems to be, that dont have an account',
            style: TextStyle(color: Colors.amber, fontSize: 15.0),
          )));
        } else if (e.code == 'wrong-password') {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text(
            'The password or email is wrong, did you forget?',
            style: TextStyle(color: Colors.amber, fontSize: 15.0),
          )));
        }
      }
    }

    return Scaffold(
      body: Container(
          child: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height / 3.5,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [Color(0xffCA7236), Color(0xffE8B64F)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight),
                borderRadius: BorderRadius.vertical(
                    bottom: Radius.elliptical(
                        MediaQuery.of(context).size.width, 105.0))),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 70),

            /// The main column of the login saction, with that we can find, title and subtitle
            ///  of page, container of login, create an account, forgot pw.
            /// The password or email is wrong, did you forget?
            child: Column(
              children: [
                ///The title of the page
                const Center(
                    child: Text(
                  'Login',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 25,
                      color: Colors.white),
                )),

                ///The subtitle of the page
                const Center(
                    child: Text(
                  'Login into your account',
                  style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 18.0,
                      color: Color.fromARGB(255, 236, 236, 236)),
                )),

                /// Conatainer with information of login, email, name and password
                Container(
                  margin: const EdgeInsets.symmetric(
                      vertical: 20.0, horizontal: 20.0),
                  child: Material(
                    borderRadius: BorderRadius.circular(10),
                    elevation: 5.0,
                    child:

                        /// the login section
                        Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 20.0, horizontal: 20.0),
                      height: MediaQuery.of(context).size.height / 2,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10)),
                      child: Form(
                        key: _formkey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ///name container
                            const Text(
                              'Email',
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                  fontSize: 15.0),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Container(
                              padding: const EdgeInsets.only(left: 10),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.white,
                                  border: Border.all(
                                      width: 1.0, color: Colors.black45)),
                              child: TextFormField(
                                controller: usermailcontroller,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please verify your email and try again';
                                  }
                                  return null;
                                },
                                decoration: const InputDecoration(
                                    prefixIcon: Icon(
                                      Icons.email_outlined,
                                      color: Color(0xffCA7236),
                                    ),
                                    border: InputBorder.none),
                              ),
                            ),
                            const SizedBox(
                              height: 30,
                            ),

                            const Text(
                              'Password',
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                  fontSize: 15.0),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            //// mail container
                            Container(
                              padding: const EdgeInsets.only(left: 10),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.white,
                                  border: Border.all(
                                      width: 1.0, color: Colors.black45)),

                              ///Form to enter the email
                              child: TextFormField(
                                obscureText: true,
                                controller: userpasswordcontroller,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please verify your password and try again';
                                  }
                                  return null;
                                },
                                decoration: const InputDecoration(
                                    prefixIcon: Icon(
                                      Icons.password_outlined,
                                      color: Color(0xffCA7236),
                                    ),
                                    border: InputBorder.none),
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const ForgotPassword()));
                              },
                              child: Container(
                                alignment: Alignment.bottomRight,
                                child: const Text(
                                  'Forgot the password?',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 50.0,
                            ),
                            GestureDetector(
                              onTap: () {
                                if (_formkey.currentState!.validate()) {
                                  setState(() {
                                    email = usermailcontroller.text;
                                  });
                                  userLogin();
                                }
                              },
                              child: Center(
                                child: Container(
                                  width: 130.0,
                                  child: Material(
                                    elevation: 5.0,
                                    child: Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: const Color(0xffCA7236),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Center(
                                        child: Text(
                                          'Login',
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account? "),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const SingUp()));
                        },
                        child: const Text(' Sing Up Now',
                            style: TextStyle(
                              color: Color(0xffCA7236),
                              fontWeight: FontWeight.bold,
                            )),
                      )
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      )),
    );
  }
}
