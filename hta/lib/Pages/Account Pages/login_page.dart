// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hta/Pages/Account%20Pages/signUp_page.dart';
import 'package:hta/Pages/App%20Pages/bottom_navigation_page.dart';
import 'package:hta/language/language_constant.dart';

import 'package:http/http.dart' as http;
import 'package:page_transition/page_transition.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../Account Pages/forgot_password_page.dart';

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final mobileNumber = TextEditingController();
  final password = TextEditingController();

  bool isHiddenPassword = true;
  // bool? exitApp;
  final _formKey = GlobalKey<FormState>();

  void _togglePasswordView() {
    if (isHiddenPassword == true) {
      isHiddenPassword = false;
    } else {
      isHiddenPassword = true;
    }
    setState(() {});
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => Center(
        child: AlertDialog(
          title: Text(translation(context).errorOccurred),
          content: Text(message),
          actions: <Widget>[
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromRGBO(62, 13, 59, 1)),
                child: Text(
                  translation(context).okay,
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> userLogin() async {
    if (_formKey.currentState!.validate()) {
      final url = Uri.parse('https://hta.hatimtechnologies.in/api/user/login');

      final body = {
        'mobileNumber': mobileNumber.text,
        'password': password.text,
        'userType': 'customer',
      };

      try {
        final response = await http.post(
          url,
          body: body,
        );

        final responseData = jsonDecode(response.body.toString());

        print(responseData);

        var code = responseData['code'];
        if (code == 1) {
          var mobileNumber = responseData["user"]['mobileNumber'];
          var token = responseData['token'];
          var name = responseData["user"]['name'];
          var lastName = responseData["user"]['lastName'];
          var organisation = responseData["user"]['organisation'];

          final SharedPreferences sharedPreferences =
              await SharedPreferences.getInstance();
          sharedPreferences.setString('mobileNumber', mobileNumber);
          sharedPreferences.setString('token', token);
          sharedPreferences.setString('organisation', organisation);
          sharedPreferences.setString('name', name);
          sharedPreferences.setString('lastName', lastName);

          Navigator.push(
            context,
            PageTransition(
              type: PageTransitionType.fade,
              child: BottomNavigationPage(),
            ),
          );
        } else if (code == 2) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("Account Reviewing"),
                content: Text("Your account is on review, So please wait"),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("OK"),
                  ),
                ],
              );
            },
          );
        } else {
          // Handle other response codes if needed
        }
      } catch (error) {
        print('Error occurred: $error');
        var errorMessage = error;
        _showErrorDialog(errorMessage.toString());
      }
    }
  }

  Future<bool> _onBackButtonPressed(BuildContext context) async {
    bool exitApp = false; // Default value

    // Show dialog
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(translation(context).confirmExit,
              style: TextStyle(color: Colors.black, fontSize: 20.0)),
          content: Text(translation(context).sureExit),
          actions: <Widget>[
            TextButton(
              child: Text(translation(context).yes,
                  style: TextStyle(fontSize: 18.0)),
              onPressed: () {
                Navigator.of(context)
                    .pop(true); // Return true when 'Yes' is pressed
              },
            ),
            TextButton(
              child: Text(translation(context).no,
                  style: TextStyle(fontSize: 18.0)),
              onPressed: () {
                Navigator.of(context)
                    .pop(false); // Return false when 'No' is pressed
              },
            )
          ],
        );
      },
    ).then((value) {
      // Handle the value returned from dialog
      if (value != null) {
        exitApp = value;
      }
    });

    return exitApp;
  }

  List<FocusNode> _focusNodes = [
    FocusNode(),
    FocusNode(),
  ];

  @override
  void initState() {
    _focusNodes.forEach((node) {
      node.addListener(() {
        setState(() {});
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: WillPopScope(
        onWillPop: () => _onBackButtonPressed(context),
        child: Material(
          child: Form(
            key: _formKey,
            child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        color: Color.fromRGBO(62, 13, 59, 1),
                        height: MediaQuery.of(context).size.height * 0.2,
                        child: Container(
                          margin: EdgeInsets.only(top: 80),
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 25),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  translation(context).signInSmall,
                                  // 'Sign In',
                                  style: TextStyle(
                                      fontSize: 24.0,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.white),
                                ),
                                IconButton(
                                    onPressed: () {
                                      _onBackButtonPressed(context);
                                    },
                                    icon: Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 30,
                                    )),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 40),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 25),
                        child: Text(
                          translation(context).welcomeBack,
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w600),
                        ),
                      ),
                      SizedBox(height: 30),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 25),
                        child: Text(
                          translation(context).mobileNumber,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 17),
                        child: TextFormField(
                          focusNode: _focusNodes[0],
                          keyboardType: TextInputType.phone,
                          controller: mobileNumber,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return translation(context)
                                  .validateMessageMobileNumber;
                            }

                            return null;
                          },
                          decoration: InputDecoration(
                              hintText:
                                  translation(context).hintTextMobileNumber,
                              hintStyle: TextStyle(
                                color: _focusNodes[0].hasFocus
                                    ? Color.fromRGBO(62, 13, 59, 1)
                                    : Colors.grey,
                                fontSize: 14.0,
                              ),
                              prefixIcon: Icon(
                                Icons.call_rounded,
                                size: 18.0,
                                color: _focusNodes[0].hasFocus
                                    ? Color.fromRGBO(62, 13, 59, 1)
                                    : Colors.grey,
                              ),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5.0)),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      width: 2,
                                      color: Color.fromRGBO(62, 13, 59, 1)))),
                        ),
                      ),
                      SizedBox(height: 30),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 25),
                        child: Text(
                          translation(context).password,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 17),
                        child: TextFormField(
                          focusNode: _focusNodes[1],
                          controller: password,
                          obscureText: isHiddenPassword,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return translation(context)
                                  .validateMessagePasswordNotEmpty;
                            } else if (value.length < 6) {
                              return translation(context)
                                  .validateMessagePasswordLength;
                            }

                            return null;
                          },
                          decoration: InputDecoration(
                              hintText: translation(context).hintTextPassword,
                              hintStyle: TextStyle(
                                color: _focusNodes[1].hasFocus
                                    ? Color.fromRGBO(62, 13, 59, 1)
                                    : Colors.grey,
                                fontSize: 14.0,
                              ),
                              prefixIcon: Icon(
                                Icons.lock,
                                size: 18.0,
                                color: _focusNodes[1].hasFocus
                                    ? Color.fromRGBO(62, 13, 59, 1)
                                    : Colors.grey,
                              ),
                              suffixIcon: InkWell(
                                onTap: _togglePasswordView,
                                child: Icon(
                                  isHiddenPassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: _focusNodes[1].hasFocus
                                      ? Color.fromRGBO(62, 13, 59, 1)
                                      : Colors.grey,
                                ),
                              ),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5.0)),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      width: 2,
                                      color: Color.fromRGBO(62, 13, 59, 1)))),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ForgotPassword()));
                          },
                          child: Text(
                            translation(context).forgotPassword,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color.fromRGBO(62, 13, 59, 1),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 30),
                        child: ElevatedButton(
                          style: TextButton.styleFrom(
                            backgroundColor: Color.fromRGBO(62, 13, 59, 1),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.zero),
                            minimumSize: Size(350, 50),
                          ),
                          onPressed: () {
                            userLogin();
                          },
                          child: Text(translation(context).signInCapital),
                        ),
                      ),
                      SizedBox(height: 10),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 80),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                              translation(context).dontHaveAccount,
                              style: TextStyle(
                                fontSize: 12.0,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => SignUpPage()));
                              },
                              child: Text(
                                translation(context).signUp,
                                style: TextStyle(
                                  color: Color.fromRGBO(62, 13, 59, 1),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14.0,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 30),
                      Image.asset("assets/images/TransperantLogo.png",
                          width: MediaQuery.of(context).size.width * 0.25),
                    ],
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
