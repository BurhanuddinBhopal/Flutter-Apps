// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, use_build_context_synchronously

import 'dart:convert';
// import 'dart:html';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:hta/home_page.dart';
import 'package:hta/utils/routes.dart';
import 'package:http/http.dart' as http;
import 'models/http_exception.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final mobileNumber = TextEditingController();
  final password = TextEditingController();

  bool isHiddenPassword = true;
  final _formKey = GlobalKey<FormState>();
  var width;
  var height;

  // var physicalWidth = physicalScreenSize.width;
  // var physicalHeight = physicalScreenSize.height;

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
      builder: (ctx) => AlertDialog(
        title: Text('An Error Occurred!'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: Text('Okay'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          )
        ],
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

        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body.toString());
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
          print(name);
          if (responseData['error'] != null) {
            throw HttpException(responseData['error']['message']);
          }
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => HomePage()));
          print(response.body);
        }
      } catch (error) {
        print(error);
        const errorMessage = 'Please enter valid Mobile Number and Password';
        _showErrorDialog(errorMessage);
      }
    }
  }

  @override
  void initState() {
    // var pixelRatio = window.devicePixelRatio;
    // var physicalScreenSize = window.physicalSize.height;
    // print('hellllo');
    // print(pixelRatio);
    // print(physicalScreenSize);
    setState(() {
      width = window.physicalSize.width;
      height = window.physicalSize.height;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
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
                    height: MediaQuery.of(context).size.height * 0.255,
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 25, vertical: 50),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Sign In',
                            style: TextStyle(
                                fontSize: 24.0,
                                fontWeight: FontWeight.w400,
                                color: Colors.white),
                          ),
                          Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 30,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 40),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 25),
                    child: Text(
                      'Hello, Welcome back to HTA',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                    ),
                  ),
                  SizedBox(height: 30),
                  Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: 10.0, horizontal: 25),
                    child: Text(
                      'Mobile Number',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 17),
                    child: TextFormField(
                      keyboardType: TextInputType.phone,
                      controller: mobileNumber,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Mobile Number cannot be empty';
                        }

                        return null;
                      },
                      decoration: InputDecoration(
                          hintText: "Enter Mobile Number",
                          hintStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 14.0,
                          ),
                          prefixIcon: Icon(
                            Icons.call_rounded,
                            size: 18.0,
                          ),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0))),
                    ),
                  ),
                  SizedBox(height: 30),
                  Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: 10.0, horizontal: 25),
                    child: Text(
                      'Password',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 17),
                    child: TextFormField(
                      controller: password,
                      obscureText: isHiddenPassword,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Password cannot be empty';
                        } else if (value.length < 6) {
                          return 'Password length should be atleast 6';
                        }

                        return null;
                      },
                      decoration: InputDecoration(
                          hintText: "Enter Password",
                          hintStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 14.0,
                          ),
                          prefixIcon: Icon(
                            Icons.lock,
                            size: 18.0,
                          ),
                          suffixIcon: InkWell(
                            onTap: _togglePasswordView,
                            child: Icon(isHiddenPassword
                                ? Icons.visibility
                                : Icons.visibility_off),
                          ),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0))),
                    ),
                  ),
                  Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: 10.0, horizontal: 25),
                    child: Text(
                      "Forgot Password?",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color.fromRGBO(62, 13, 59, 1),
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
                      child: Text("SIGN IN"),
                    ),
                  ),
                  SizedBox(height: 10),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 80),
                    child: Row(
                      children: [
                        Text(
                          "I don't have an account.",
                          style: TextStyle(
                            fontSize: 12.0,
                          ),
                        ),
                        Text(
                          "Request Access",
                          style: TextStyle(
                            color: Color.fromRGBO(62, 13, 59, 1),
                            fontWeight: FontWeight.bold,
                            fontSize: 12.0,
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
    );
  }
}
