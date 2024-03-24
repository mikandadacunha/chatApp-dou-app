import 'package:chatap/pages/home.dart';
import 'package:chatap/pages/service/database.dart';
import 'package:chatap/pages/service/shared_pref.dart';
import 'package:chatap/pages/signin.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:random_string/random_string.dart';

class SingUp extends StatefulWidget {
  const SingUp({super.key});

  @override
  State<SingUp> createState() => _SingUpState();
}

class _SingUpState extends State<SingUp> {
  String email = '', name = '', password = '', confirmPassword = '';

  TextEditingController emailController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  final _formkey = GlobalKey<FormState>();
//// That is the function that resgist all the user into database
  registration() async {
    ///condition that verify the password information and test the nulleble or not and if each other
    ///is the same with confirm password
    if (password == confirmPassword) {
      ///try that test every information given by the user, try catch
      try {
        String Id = randomAlphaNumeric(10);
        String user = emailController.text.replaceAll('@gmail.com', '');
        String updateusername =
            user.replaceFirst(user[0], user[0].toUpperCase());
        String firstletter = user.substring(0, 1).toUpperCase();

        ///Function used to upload the user information into the database
        Map<String, dynamic> userInfoMap = {
          'Name': nameController.text,
          'E-mail': emailController.text,
          'username': updateusername.toUpperCase(),
          'searchKey': firstletter,
          'Phote': '',
          'id': Id,
        };
        await SharedPreferencesHelper().saveUserId(Id);
        await SharedPreferencesHelper()
            .saveUserDisplayname(nameController.text);
        await SharedPreferencesHelper().saveUserEmail(emailController.text);
        await SharedPreferencesHelper().saveUserPic('');
        await SharedPreferencesHelper().saveUserName(
            emailController.text.replaceAll('@gmail.com', '').toUpperCase());
        //// future function used to upload the details, its coming from database file
        ///what we have done here is, we call a DatabaseMethods, where we have a variable named addUserDetails
        /// *(function).
        await DatabaseMethods().addUserDetails(userInfoMap, Id);

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
          'Sucessefuly on the registration!!',
          style: TextStyle(fontSize: 20.0),
        )));

        // ignore: use_build_context_synchronously
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => HomePage(
                      myName: name,
                      myEmail: email,
                      myProfilePic: '',
                      myUserName: updateusername.toUpperCase(),
                    )));
      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text(
            'Provide a diferente P-W',
            style: TextStyle(fontSize: 20.0, color: Colors.amber),
          )));
        } else if (e.code == 'email-already-in-use') {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text(
            'Provide a diferente P-W',
            style: TextStyle(fontSize: 20.0, color: Colors.amber),
          )));
        }
      }
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
            child: Column(
              children: [
                ///The title of the page
                const Center(
                    child: Text(
                  'Sign Up Now',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 25,
                      color: Colors.white),
                )),

                ///The subtitle of the page
                const Center(
                    child: Text(
                  'Create your account to login',
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
                      height: MediaQuery.of(context).size.height / 1.5,
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
                              'Name',
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
                                controller: nameController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter name';
                                  }
                                  return null;
                                },
                                decoration: const InputDecoration(
                                    prefixIcon: Icon(
                                      Icons.person_2_outlined,
                                      color: Color(0xffCA7236),
                                    ),
                                    border: InputBorder.none),
                              ),
                            ),
                            const SizedBox(
                              height: 30,
                            ),

                            ///Begin of Mail csection

                            const Text(
                              'E-mail',
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
                                controller: emailController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter an Email';
                                  }
                                  return null;
                                },
                                decoration: const InputDecoration(
                                    prefixIcon: Icon(
                                      Icons.mail_outline_outlined,
                                      color: Color(0xffCA7236),
                                    ),
                                    border: InputBorder.none),
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),

                            ///End of Mail csection
                            /// Begin of Password csection
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
                            Container(
                              padding: const EdgeInsets.only(left: 10),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.white,
                                  border: Border.all(
                                      width: 1.0, color: Colors.black45)),
                              child: TextFormField(
                                obscureText: true,
                                controller: passwordController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter Password';
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
                              height: 30,
                            ),

                            ///The end of Mail section

                            const Text(
                              'Confirm password',
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                  fontSize: 15.0),
                            ),
                            const SizedBox(
                              height: 10,
                            ),

                            //// confirm p-w container
                            Container(
                              padding: const EdgeInsets.only(left: 10),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.white,
                                  border: Border.all(
                                      width: 1.0, color: Colors.black45)),
                              child: TextFormField(
                                obscureText: true,
                                controller: confirmPasswordController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter confirm password';
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
                              height: 30.0,
                            ),

                            ///Bottom of signup section, I use container here,
                            ///becouse of facility to personali it
                            GestureDetector(
                              onTap: () {
                                if (_formkey.currentState!.validate()) {
                                  setState(() {
                                    email = emailController.text;
                                    name = nameController.text;
                                    password = passwordController.text;
                                    confirmPassword =
                                        confirmPasswordController.text;
                                  });
                                }
                                registration();
                              },
                              child: Center(
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
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
                                          'SIGN UP',
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
                      const Text('Do you have an account?'),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const SignIn()));
                        },
                        child: const Text(' Login Now',
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
