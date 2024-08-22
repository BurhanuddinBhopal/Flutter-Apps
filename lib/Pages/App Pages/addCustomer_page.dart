import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttercontactpicker/fluttercontactpicker.dart';

import 'package:hta/language/language_constant.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../constant.dart';
import 'bottom_navigation_page.dart';

class AddCustomerPage extends StatefulWidget {
  const AddCustomerPage({super.key});

  @override
  _AddCustomerPageState createState() => _AddCustomerPageState();
}

class _AddCustomerPageState extends State<AddCustomerPage> {
  final organisationName = TextEditingController();
  final name = TextEditingController();
  final lastName = TextEditingController();
  final mobileNumber = TextEditingController();
  PhoneContact? _phoneContact;

  final _formKey = GlobalKey<FormState>();
  late TextEditingController address;

  final List<FocusNode> _focusNodes = [
    FocusNode(),
    FocusNode(),
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    address = TextEditingController(text: 'India');
  }

  Future<void> addCustomer() async {
    if (_formKey.currentState!.validate()) {
      final SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      var token = sharedPreferences.getString('token');
      var organisation = sharedPreferences.getString('organisation');

      final url =
          Uri.parse('${AppConstants.backendUrl}/api/customer/addCustomer');

      final body = {
        "organisationName": organisationName.text,
        "name": name.text,
        "lastName": lastName.text,
        "mobileNumber": mobileNumber.text,
        "userType": "costomer",
        "organisation": organisation,
      };
      final header = {
        'Authorization': 'Bearer $token',
      };
      print('print body: $body');

      final response = await http.post(url, body: body, headers: header);
      final responseData = jsonDecode(response.body.toString());
      print("print responseData: $responseData");
      if (responseData['code'] == 1) {
        _showSuccessDialog();
      } else {
        _showErrorDialog(responseData);
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text(translation(context)!.customersAddedSuccessfully),
        actions: <Widget>[
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(62, 13, 59, 1),
              ),
              child: Text(
                translation(context)!.okay,
                style: const TextStyle(color: Colors.white),
              ),
              onPressed: () {
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
                backgroundColor: const Color.fromRGBO(62, 13, 59, 1),
              ),
              child: Text(
                translation(context)!.okay,
                style: const TextStyle(color: Colors.white),
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
            icon: const Icon(
              Icons.arrow_back_ios,
              size: 18.0,
            )),
        backgroundColor: const Color.fromRGBO(62, 13, 59, 1),
        centerTitle: true,
        title: Text(
          translation(context)!.addCustomer,
          style: const TextStyle(
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
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: ElevatedButton(
                        onPressed: () async {
                          final PhoneContact contact =
                              await FlutterContactPicker.pickPhoneContact();
                          setState(() {
                            _phoneContact = contact;
                            organisationName.text =
                                _phoneContact!.fullName.toString();
                            name.text = _phoneContact!.fullName.toString();
                            mobileNumber.text =
                                _phoneContact!.phoneNumber!.number.toString();
                          });
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: const Color.fromRGBO(62, 13, 59, 1),
                          shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero),
                          minimumSize: const Size(250, 40),
                        ),
                        child: Text(
                          translation(context)!.selectFromPhonebook,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 12.0, right: 12.0, top: 12.0),
                      child: TextFormField(
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
                            hintText:
                                translation(context)!.hintTextOrganisation,
                            contentPadding: const EdgeInsets.only(left: 10.0),
                            hintStyle: TextStyle(
                              color: _focusNodes[0].hasFocus
                                  ? const Color.fromRGBO(62, 13, 59, 1)
                                  : Colors.grey,
                              fontSize: 14.0,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            focusedBorder: const OutlineInputBorder(
                                borderSide: BorderSide(
                                    width: 2,
                                    color: Color.fromRGBO(62, 13, 59, 1)))),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 12.0, right: 12.0, top: 12.0),
                      child: TextFormField(
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
                            hintText: translation(context)!.hintTextName,
                            contentPadding: const EdgeInsets.only(left: 10.0),
                            hintStyle: TextStyle(
                              color: _focusNodes[1].hasFocus
                                  ? const Color.fromRGBO(62, 13, 59, 1)
                                  : Colors.grey,
                              fontSize: 14.0,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            focusedBorder: const OutlineInputBorder(
                                borderSide: BorderSide(
                                    width: 2,
                                    color: Color.fromRGBO(62, 13, 59, 1)))),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 12.0, right: 12.0, top: 12.0),
                      child: TextFormField(
                        controller: lastName,
                        focusNode: _focusNodes[2],
                        decoration: InputDecoration(
                            hintText: translation(context)!.hintTextLastName,
                            contentPadding: const EdgeInsets.only(left: 10.0),
                            hintStyle: TextStyle(
                              color: _focusNodes[2].hasFocus
                                  ? const Color.fromRGBO(62, 13, 59, 1)
                                  : Colors.grey,
                              fontSize: 14.0,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            focusedBorder: const OutlineInputBorder(
                                borderSide: BorderSide(
                                    width: 2,
                                    color: Color.fromRGBO(62, 13, 59, 1)))),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 12.0, right: 12.0, top: 12.0),
                      child: TextFormField(
                        focusNode: _focusNodes[3],
                        controller: mobileNumber,
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return translation(context)!
                                .validateMessageMobileNumber;
                          } else if (value.length != 10) {
                            return translation(context)!
                                .validateMessageMobileNumberForValidNumber;
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                            hintText:
                                translation(context)!.hintTextMobileNumber,
                            contentPadding: const EdgeInsets.only(left: 10.0),
                            hintStyle: TextStyle(
                              color: _focusNodes[3].hasFocus
                                  ? const Color.fromRGBO(62, 13, 59, 1)
                                  : Colors.grey,
                              fontSize: 14.0,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            focusedBorder: const OutlineInputBorder(
                                borderSide: BorderSide(
                                    width: 2,
                                    color: Color.fromRGBO(62, 13, 59, 1)))),
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Container(
                      color: const Color.fromRGBO(62, 13, 59, 1),
                      height: 70.0,
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          addCustomer();
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: const Color.fromRGBO(62, 13, 59, 1),
                        ),
                        child: Text(translation(context)!.save),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
