import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../App Pages/login_page.dart';

class ForgotPassword extends StatefulWidget {
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

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('An Error Occurred!'),
        content: Text(message),
        actions: <Widget>[
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromRGBO(62, 13, 59, 1)),
            child: Text(
              'Okay',
              style: TextStyle(
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

  void _showPopupDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Password Changed Successfuly',
          textAlign: TextAlign.center,
        ),
        actions: <Widget>[
          Container(
            margin: EdgeInsets.symmetric(horizontal: 120),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromRGBO(62, 13, 59, 1)),
              child: Text(
                'Okay',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.white),
              ),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => LoginPage()));
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
      final url = Uri.parse(
          'https://hta.hatimtechnologies.in/api/user/change-user-password');

      final body = {
        'oldPassword': oldPassword.text,
        'newPassword': newPassword.text
      };
      print(body);
      final header = {
        'Authorization': 'Bearer $token',
      };

      try {
        final response = await http.post(
          url,
          body: body,
          headers: header,
        );

        if (response.statusCode == 200) {
          _showPopupDialog();

          print(response.body);
        }
      } catch (error) {
        print(error);
        const errorMessage = 'Incorrect old password';
        _showErrorDialog(errorMessage);
      }
    }
  }

  List<FocusNode> _focusNodes = [
    FocusNode(),
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
                          color: Color.fromRGBO(62, 13, 59, 1),
                          height: MediaQuery.of(context).size.height * 0.255,
                          child: Container(
                            margin: EdgeInsets.only(top: 80),
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 25),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    'Change Password',
                                    style: TextStyle(
                                        fontSize: 24.0,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.white),
                                  ),
                                  IconButton(
                                      onPressed: (() {
                                        Navigator.of(context).pop();
                                      }),
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
                        SizedBox(height: 80),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 25),
                          child: Text(
                            'Old Password',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 17),
                          child: TextFormField(
                            focusNode: _focusNodes[0],
                            obscureText: isHiddenPassword[0],
                            controller: oldPassword,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Password cannot be empty';
                              } else if (value.length < 6) {
                                return 'Password length should be atleast 6';
                              }

                              return null;
                            },
                            decoration: InputDecoration(
                                prefixIcon: Icon(
                                  Icons.lock,
                                  size: 30.0,
                                  color: _focusNodes[0].hasFocus
                                      ? Color.fromRGBO(62, 13, 59, 1)
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
                        SizedBox(height: 30),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 25),
                          child: Text(
                            'New Password',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 17),
                          child: TextFormField(
                            focusNode: _focusNodes[1],
                            obscureText: isHiddenPassword[1],
                            controller: newPassword,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Password cannot be empty';
                              } else if (value.length < 6) {
                                return 'Password length should be atleast 6';
                              }

                              return null;
                            },
                            decoration: InputDecoration(
                                prefixIcon: Icon(
                                  Icons.lock,
                                  size: 30.0,
                                  color: _focusNodes[1].hasFocus
                                      ? Color.fromRGBO(62, 13, 59, 1)
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
                        SizedBox(height: 30),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 25),
                          child: Text(
                            'Confirm New Password',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 17),
                          child: TextFormField(
                            focusNode: _focusNodes[2],
                            obscureText: isHiddenPassword[2],
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Password cannot be empty';
                              } else if (value.length < 6) {
                                return 'Password length should be atleast 6';
                              }

                              return null;
                            },
                            decoration: InputDecoration(
                                prefixIcon: Icon(
                                  Icons.lock,
                                  size: 30.0,
                                  color: _focusNodes[2].hasFocus
                                      ? Color.fromRGBO(62, 13, 59, 1)
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
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.08,
                        )
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
                              forgetPassword();
                            },
                            child: Text("CHANGE PASSWORD"),
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
