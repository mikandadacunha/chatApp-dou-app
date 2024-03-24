import 'package:chatap/pages/signin.dart';
import 'package:chatap/pages/signup.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final _formkey = GlobalKey<FormState>();
  String email = '';

  final usermailcontroller = TextEditingController();

  resetPassword() async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
        'The password has been resseted sucessifuly',
        style: TextStyle(
          fontSize: 20.0,
          color: Colors.amber,
        ),
      )));
    } on FirebaseException catch (e) {
      if (e.code == 'user-not-found') {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
          'User not found, please try a new email',
          style: TextStyle(
            fontSize: 20.0,
            color: Colors.amber,
          ),
        )));
      }
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> const SignIn()));
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  'Recovery your password',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 25,
                      color: Colors.white),
                )),

                ///The subtitle of the page
                const Center(
                    child: Text(
                  'Enter your e-mail',
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
                      height: MediaQuery.of(context).size.height / 3,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10)),
                      child: Form(
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
                                key: _formkey,
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
                              height: 50.0,
                            ),
                            GestureDetector(
                              onTap: () {
                                if (_formkey.currentState!.validate()) {
                                  setState(() {
                                    email = usermailcontroller.text;
                                  });
                                  resetPassword();
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
                                          'Send Email',
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
