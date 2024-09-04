// ignore_for_file: prefer_const_literals_to_create_immutables, use_key_in_widget_constructors, prefer_const_constructors, use_build_context_synchronously, unused_local_variable

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hta/Pages/App%20Pages/bottom_navigation_page.dart';
import 'package:hta/Pages/App%20Pages/home_page.dart';
import 'package:hta/google%20anaylitics/anaylitics_services.dart';
import 'package:hta/language/language_constant.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../../constant.dart';

class EditCustomerPage extends StatefulWidget {
  final customerData;

  const EditCustomerPage({super.key, required this.customerData});
  @override
  State<EditCustomerPage> createState() => _EditCustomerPageState();
}

class _EditCustomerPageState extends State<EditCustomerPage> {
  final AnalyticsService analytics = AnalyticsService();
  // ignore: unused_field
  var _organization;
  var _organizationName;
  var _name;
  var _lastname;
  var _mobileNumber;
  var _location;

  var _customerData = {};

  @override
  void initState() {
    for (var node in _focusNodes) {
      node.addListener(() {
        setState(() {});
      });
    }
    setState(() {
      _customerData = widget.customerData;
      _organizationName = _customerData['organisationName'];
      _name = _customerData['name'];
      _lastname = _customerData['lastName'];
      _mobileNumber = _customerData['mobileNumber'];
      _location = _customerData['location'] ?? "";
      organisationName.text = _organizationName;
      name.text = _name;
      lastName.text = _lastname;
      mobileNumber.text = _mobileNumber;
      location.text = _location;
    });
    analytics.trackPage('EditCustomerPage');

    super.initState();
  }

  // PhoneContact? _phoneContact;
  final organisationName = TextEditingController();
  final name = TextEditingController();
  final lastName = TextEditingController();
  final mobileNumber = TextEditingController();
  final location = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final List<FocusNode> _focusNodes = [
    FocusNode(),
    FocusNode(),
    FocusNode(),
    FocusNode(),
    FocusNode(),
  ];

  void _showSuccesDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text('Customer Edited Successfully'),
        actions: <Widget>[
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromRGBO(62, 13, 59, 1),
              ),
              child: Text(
                'Okay',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                analytics.trackEvent('Customer', 'Edited',
                    label: _customerData['_id']);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => BottomNavigationPage()));
              },
            ),
          )
        ],
      ),
    );
  }

  void _showErrorDialog(responseData) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text(responseData['message']),
        actions: <Widget>[
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromRGBO(62, 13, 59, 1),
              ),
              child: Text(
                'Okay',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          )
        ],
      ),
    );
  }

  Future<void> editCustomer() async {
    if (_formKey.currentState!.validate()) {
      final SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      var token = sharedPreferences.getString('token');
      var organisation = sharedPreferences.getString('organisation');

      final url =
          Uri.parse('${AppConstants.backendUrl}/api/customer/editCustomer');

      final body = {
        "organisationName": organisationName.text,
        "name": name.text,
        "lastName": lastName.text,
        "address": location.text.isNotEmpty ? location.text : "",
        "location": location.text.isNotEmpty ? location.text : "",
        "customerId": _customerData['_id'],
      };

      final header = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json', // Ensure content type is JSON
      };

      try {
        final response =
            await http.post(url, body: jsonEncode(body), headers: header);

        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body.toString());

          if (responseData['code'] == 1) {
            _showSuccesDialog(); // Success response
          } else {
            _showErrorDialog(
                responseData['message'] ?? 'Unknown error occurred');
          }
        } else {
          // Handle non-200 status codes (e.g., 400, 500, etc.)
          _showErrorDialog(
              'Server error: ${response.statusCode}. Please try again.');
        }
      } on SocketException catch (_) {
        // No Internet connection or failed to reach the server
        _showGenericErrorDialog(
            'No Internet connection. Please check your network and try again.');
      } on FormatException catch (e) {
        // Invalid format or data issue
        _showGenericErrorDialog(
            'Invalid data format. Please check your input and try again.');
      } catch (e) {
        // Other unexpected errors
        _showGenericErrorDialog('Something went wrong. Please try again.');
      }
    }
  }

  void _showGenericErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Error"),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: (() {
              Navigator.pop(context);
            }),
            icon: Icon(
              Icons.arrow_back_ios,
              size: 18.0,
            )),
        backgroundColor: Color.fromRGBO(62, 13, 59, 1),
        centerTitle: true,
        title: Text(
          'Edit Customer',
          style: TextStyle(
            fontSize: 16.0,
          ),
        ),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Material(
          child: Form(
            key: _formKey,
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      // Padding(
                      //   padding: EdgeInsets.only(top: 16.0),
                      //   child: ElevatedButton(
                      //     onPressed: () async {
                      //       final PhoneContact contact =
                      //           await FlutterContactPicker.pickPhoneContact();

                      //       setState(() {
                      //         _phoneContact = contact;
                      //         name.text = _phoneContact!.fullName.toString();
                      //         mobileNumber.text =
                      //             _phoneContact!.phoneNumber!.number.toString();
                      //       });
                      //     },
                      //     style: TextButton.styleFrom(
                      //       backgroundColor: Color.fromRGBO(62, 13, 59, 1),
                      //       shape: RoundedRectangleBorder(
                      //           borderRadius: BorderRadius.zero),
                      //       minimumSize: Size(250, 40),
                      //     ),
                      //     child: Text(
                      //       "Select from PhoneBook",
                      //       style: TextStyle(color: Colors.white),
                      //     ),
                      //   ),
                      // ),
                      Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(
                                left: 12.0, right: 12.0, top: 12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  translation(context)!.hintTextOrganisation,
                                  style: TextStyle(
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.w600,
                                    color: Color.fromRGBO(
                                        62, 13, 59, 1), // Label color
                                  ),
                                ),
                                SizedBox(
                                    height:
                                        5.0), // Margin between label and text field
                                TextFormField(
                                  controller: organisationName,
                                  focusNode: _focusNodes[0],
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return translation(context)!
                                          .validateMessageOrganisationNotEmpty;
                                    }
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                    hintText: translation(context)!
                                        .hintTextOrganisation,
                                    contentPadding: EdgeInsets.only(left: 10.0),
                                    hintStyle: TextStyle(
                                      color: _focusNodes[0].hasFocus
                                          ? Color.fromRGBO(62, 13, 59, 1)
                                          : Colors.grey,
                                      fontSize: 14.0,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5.0),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        width: 2,
                                        color: Color.fromRGBO(62, 13, 59, 1),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                                left: 12.0, right: 12.0, top: 12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  translation(context)!.hintTextAdminName,
                                  style: TextStyle(
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.w600,
                                    color: Color.fromRGBO(
                                        62, 13, 59, 1), // Label color
                                  ),
                                ),
                                SizedBox(
                                    height:
                                        5.0), // Margin between label and text field
                                TextFormField(
                                  controller: name,
                                  focusNode: _focusNodes[1],
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return translation(context)!
                                          .validateMessageNameNotEmpty;
                                    }
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                    hintText:
                                        translation(context)!.hintTextAdminName,
                                    contentPadding: EdgeInsets.only(left: 10.0),
                                    hintStyle: TextStyle(
                                      color: _focusNodes[1].hasFocus
                                          ? Color.fromRGBO(62, 13, 59, 1)
                                          : Colors.grey,
                                      fontSize: 14.0,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5.0),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        width: 2,
                                        color: Color.fromRGBO(62, 13, 59, 1),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                                left: 12.0, right: 12.0, top: 12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  translation(context)!.hintTextLastName,
                                  style: TextStyle(
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.w600,
                                    color: Color.fromRGBO(
                                        62, 13, 59, 1), // Label color
                                  ),
                                ),
                                SizedBox(
                                    height:
                                        5.0), // Margin between label and text field
                                TextFormField(
                                  controller: lastName,
                                  focusNode: _focusNodes[2],
                                  decoration: InputDecoration(
                                    hintText:
                                        translation(context)!.hintTextLastName,
                                    contentPadding: EdgeInsets.only(left: 10.0),
                                    hintStyle: TextStyle(
                                      color: _focusNodes[2].hasFocus
                                          ? Color.fromRGBO(62, 13, 59, 1)
                                          : Colors.grey,
                                      fontSize: 14.0,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5.0),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        width: 2,
                                        color: Color.fromRGBO(62, 13, 59, 1),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                                left: 12.0, right: 12.0, top: 12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  translation(context)!.mobileNumber,
                                  style: TextStyle(
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.w600,
                                    color: Color.fromRGBO(
                                        62, 13, 59, 1), // Label color
                                  ),
                                ),
                                SizedBox(
                                    height:
                                        5.0), // Margin between label and text field
                                TextFormField(
                                  enabled: false,
                                  focusNode: _focusNodes[3],
                                  controller: mobileNumber,
                                  keyboardType: TextInputType.phone,
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return translation(context)!
                                          .validateMessageMobileNumber;
                                    }
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                    hintText: translation(context)!
                                        .hintTextMobileNumber,
                                    contentPadding: EdgeInsets.only(left: 10.0),
                                    hintStyle: TextStyle(
                                      color: _focusNodes[3].hasFocus
                                          ? Color.fromRGBO(62, 13, 59, 1)
                                          : Colors.grey,
                                      fontSize: 14.0,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5.0),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        width: 2,
                                        color: Color.fromRGBO(62, 13, 59, 1),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                                left: 12.0, right: 12.0, top: 12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  translation(context)!.hintTextAddress,
                                  style: TextStyle(
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.w600,
                                    color: Color.fromRGBO(
                                        62, 13, 59, 1), // Label color
                                  ),
                                ),
                                SizedBox(
                                    height:
                                        5.0), // Margin between label and text field
                                TextFormField(
                                  controller: location,
                                  focusNode: _focusNodes[4],
                                  decoration: InputDecoration(
                                    hintText:
                                        translation(context)!.hintTextAddress,
                                    contentPadding: EdgeInsets.only(left: 10.0),
                                    hintStyle: TextStyle(
                                      color: _focusNodes[4].hasFocus
                                          ? Color.fromRGBO(62, 13, 59, 1)
                                          : Colors.grey,
                                      fontSize: 14.0,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5.0),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        width: 2,
                                        color: Color.fromRGBO(62, 13, 59, 1),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                  Column(
                    children: [
                      Container(
                        color: Color.fromRGBO(62, 13, 59, 1),
                        height: 70.0,
                        width: 420.0,
                        child: ElevatedButton(
                          onPressed: () {
                            editCustomer();
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: Color.fromRGBO(62, 13, 59, 1),
                          ),
                          child: Text("Edit"),
                        ),
                      ),
                    ],
                  ),
                ]),
          ),
        ),
      ),
    );
  }
}
