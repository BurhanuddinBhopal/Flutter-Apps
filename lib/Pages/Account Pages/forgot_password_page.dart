import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hta/language/language_constant.dart';

import 'package:http/http.dart' as http;
import 'package:page_transition/page_transition.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../../constant.dart';
import 'login_page.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  List<bool> isHiddenPassword = [true, true, true];
  final _formKey = GlobalKey<FormState>();
  final oldPassword = TextEditingController();
  final newPassword = TextEditingController();

  // _togglePasswordView() {
  //   if (isHiddenPassword == true) {
  //     isHiddenPassword = false as List<bool>;
  //   } else {
  //     isHiddenPassword = true as List<bool>;
  //   }
  //   setState(() {});
  // }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text(message),
        actions: <Widget>[
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(62, 13, 59, 1)),
            child: Text(
              translation(context)!.okay,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Colors.white),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          )
        ],
      ),
    );
  }

  void _showPopupDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text(
          translation(context)!.successMessageforPassword,
          textAlign: TextAlign.center,
        ),
        actions: <Widget>[
          Container(
            // margin: EdgeInsets.symmetric(horizontal: 120),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(62, 13, 59, 1)),
              child: Text(
                translation(context)!.okay,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.white),
              ),
              onPressed: () {
                Navigator.push(
                    context,
                    PageTransition(
                        type: PageTransitionType.fade, child: LoginPage()));
              },
            ),
          )
        ],
      ),
    );
  }

  Future<void> forgetPassword() async {
    if (_formKey.currentState!.validate()) {
      final SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      var token = sharedPreferences.getString('token');
      final url =
          Uri.parse('${AppConstants.backendUrl}/api/user/change-user-password');

      final body = {
        'oldPassword': oldPassword.text,
        'newPassword': newPassword.text
      };

      final header = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      try {
        final response = await http.post(
          url,
          body: jsonEncode(body),
          headers: header,
        );

        final responseData = jsonDecode(response.body.toString());

        if (responseData['code'] == 1) {
          _showPopupDialog(context);
        } else {
          String errorMessage = 'Something went wrong';
          if (responseData is Map<String, dynamic> &&
              responseData['message'] is String) {
            errorMessage = responseData['message'];
          }
          _showErrorDialog(context, errorMessage);
        }
      } catch (error) {
        if (error is SocketException) {
          _showErrorDialog(context,
              "No internet connection. Please check your network settings.");
        } else {
          print('Error occurred: $error');
          _showErrorDialog(context, 'Error occurred: $error');
        }
      }
    }
  }

  final List<FocusNode> _focusNodes = [
    FocusNode(),
    FocusNode(),
    FocusNode(),
  ];

  @override
  void initState() {
    for (var node in _focusNodes) {
      node.addListener(() {
        setState(() {});
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return Scaffold(
      body: SingleChildScrollView(
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: Material(
            child: Form(
              key: _formKey,
              child: Container(
                child: Column(
                  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          color: const Color.fromRGBO(62, 13, 59, 1),
                          height: MediaQuery.of(context).size.height * 0.255,
                          child: Container(
                            margin: const EdgeInsets.only(top: 80),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 25),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    translation(context)!.changePassword,
                                    style: const TextStyle(
                                        fontSize: 24.0,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.white),
                                  ),
                                  IconButton(
                                      onPressed: (() {
                                        Navigator.of(context).pop();
                                      }),
                                      icon: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 30,
                                      )),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 80),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 25),
                          child: Text(
                            translation(context)!.oldPassword,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 17),
                          child: TextFormField(
                            focusNode: _focusNodes[0],
                            obscureText: isHiddenPassword[0],
                            controller: oldPassword,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return translation(context)!
                                    .validateMessagePasswordNotEmpty;
                              } else if (value.length < 6) {
                                return translation(context)!
                                    .validateMessagePasswordLength;
                              }

                              return null;
                            },
                            decoration: InputDecoration(
                                prefixIcon: Icon(
                                  Icons.lock,
                                  size: 30.0,
                                  color: _focusNodes[0].hasFocus
                                      ? const Color.fromRGBO(62, 13, 59, 1)
                                      : Colors.grey,
                                ),
                                suffixIcon: IconButton(
                                  onPressed: (() {
                                    isHiddenPassword[0] = !isHiddenPassword[0];
                                    setState(() {});
                                  }),
                                  icon: Icon(
                                    isHiddenPassword[0]
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: _focusNodes[0].hasFocus
                                        ? const Color.fromRGBO(62, 13, 59, 1)
                                        : Colors.grey,
                                  ),
                                ),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5.0)),
                                focusedBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                        width: 2,
                                        color: Color.fromRGBO(62, 13, 59, 1)))),
                          ),
                        ),
                        const SizedBox(height: 30),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 25),
                          child: Text(
                            translation(context)!.newPassword,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 17),
                          child: TextFormField(
                            focusNode: _focusNodes[1],
                            obscureText: isHiddenPassword[1],
                            controller: newPassword,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return translation(context)!
                                    .validateMessagePasswordNotEmpty;
                              } else if (value.length < 6) {
                                return translation(context)!
                                    .validateMessagePasswordLength;
                              }

                              return null;
                            },
                            decoration: InputDecoration(
                                prefixIcon: Icon(
                                  Icons.lock,
                                  size: 30.0,
                                  color: _focusNodes[1].hasFocus
                                      ? const Color.fromRGBO(62, 13, 59, 1)
                                      : Colors.grey,
                                ),
                                suffixIcon: IconButton(
                                  onPressed: (() {
                                    isHiddenPassword[1] = !isHiddenPassword[1];
                                    setState(() {});
                                  }),
                                  icon: Icon(
                                    isHiddenPassword[1]
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: _focusNodes[1].hasFocus
                                        ? const Color.fromRGBO(62, 13, 59, 1)
                                        : Colors.grey,
                                  ),
                                ),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5.0)),
                                focusedBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                        width: 2,
                                        color: Color.fromRGBO(62, 13, 59, 1)))),
                          ),
                        ),
                        const SizedBox(height: 30),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 25),
                          child: Text(
                            translation(context)!.confirmPassword,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 17),
                          child: TextFormField(
                            focusNode: _focusNodes[2],
                            obscureText: isHiddenPassword[2],
                            validator: (value) {
                              if (value!.isEmpty) {
                                return translation(context)!
                                    .validateMessagePasswordNotEmpty;
                              } else if (value.length < 6) {
                                return translation(context)!
                                    .validateMessagePasswordLength;
                              } else if (value != newPassword.text) {
                                return translation(context)!.passwordDoNotMatch;
                              }

                              return null;
                            },
                            decoration: InputDecoration(
                                prefixIcon: Icon(
                                  Icons.lock,
                                  size: 30.0,
                                  color: _focusNodes[2].hasFocus
                                      ? const Color.fromRGBO(62, 13, 59, 1)
                                      : Colors.grey,
                                ),
                                suffixIcon: IconButton(
                                  onPressed: (() {
                                    isHiddenPassword[2] = !isHiddenPassword[2];
                                    setState(() {});
                                  }),
                                  icon: Icon(
                                    isHiddenPassword[2]
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: _focusNodes[2].hasFocus
                                        ? const Color.fromRGBO(62, 13, 59, 1)
                                        : Colors.grey,
                                  ),
                                ),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5.0)),
                                focusedBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                        width: 2,
                                        color: Color.fromRGBO(62, 13, 59, 1)))),
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.08,
                        )
                      ],
                    ),
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30),
                          child: ElevatedButton(
                            style: TextButton.styleFrom(
                              backgroundColor:
                                  const Color.fromRGBO(62, 13, 59, 1),
                              shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.zero),
                              minimumSize: const Size(350, 50),
                            ),
                            onPressed: () {
                              forgetPassword();
                            },
                            child: Text(
                                translation(context)!.changePasswordCapital),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
