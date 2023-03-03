// ignore_for_file: prefer_const_literals_to_create_immutables, use_key_in_widget_constructors, prefer_const_constructors, use_build_context_synchronously

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:fluttercontactpicker/fluttercontactpicker.dart';

import 'package:hta/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddCustomerPage extends StatefulWidget {
  State<AddCustomerPage> createState() => _AddCustomerPageState();
}

class _AddCustomerPageState extends State<AddCustomerPage> {
  PhoneContact? _phoneContact;
  String? _contact;
  var width;
  var height;

  final organisationName = TextEditingController();
  final name = TextEditingController();
  final lastName = TextEditingController();
  final mobileNumber = TextEditingController();
  final address = TextEditingController();

  @override
  void initState() {
    setState(() {
      width = window.physicalSize.width;
      height = window.physicalSize.height;
    });
    print(height);
    super.initState();
  }

  Future<void> addCustomer() async {
    // if (_formKey.currentState!.validate()) {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    var token = sharedPreferences.getString('token');
    print('hello1234');

    final url =
        Uri.parse('https://hta.hatimtechnologies.in/api/customer/addCustomer');

    final body = {
      "organisationName": organisationName.text,
      "name": name.text,
      "lastName": lastName.text,
      "mobileNumber": mobileNumber.text,
      "address": address.text,
      "location": address.text,
      "userType": "costomer",
      "organisation": "5f6057c54f9dc9627e2c2e3d"
    };
    final header = {
      'Authorization': 'Bearer $token',
    };
    print('gfre');
    print(body);

    final response = await http.post(url, body: body, headers: header);

    _showErrorDialog();

    print('hello');

    print(response.body);

    // }
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Customer Added Successfully'),
        actions: <Widget>[
          TextButton(
            child: Text('Okay'),
            onPressed: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => HomePage()));
            },
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Material(
        child: Form(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    Container(
                      color: Color.fromRGBO(62, 13, 59, 1),
                      height: 97.0 / 2361 * height,
                      child: Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(top: 50.0),
                            child: IconButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: Icon(
                                Icons.arrow_back_ios,
                                color: Colors.white,
                                size: 18.0,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 100),
                            child: Padding(
                              padding: EdgeInsets.only(top: 50),
                              child: Text(
                                "Add Customer",
                                style: TextStyle(
                                  fontSize: 16.0,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 16.0),
                      child: ElevatedButton(
                        onPressed: () async {
                          final PhoneContact contact =
                              await FlutterContactPicker.pickPhoneContact();
                          print(contact);
                          setState(() {
                            _phoneContact = contact;
                          });
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: Color.fromRGBO(62, 13, 59, 1),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero),
                          minimumSize:
                              Size(250 / 1080 * width, 40 / 2361 * height),
                        ),
                        child: Text(
                          "Select from PhoneBook",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          left: 12.0 / 1080 * width,
                          right: 12.0 / 1080 * width,
                          top: 12.0 / 2361 * height),
                      child: TextFormField(
                        controller: organisationName,
                        decoration: InputDecoration(
                            hintText: "Organization Name",
                            contentPadding:
                                EdgeInsets.only(left: 10.0 / 1080 * width),
                            hintStyle: TextStyle(
                              color: Colors.grey,
                              fontSize: 14.0,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0),
                            )),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          left: 12.0 / 1080 * width,
                          right: 12.0 / 1080 * width,
                          top: 12.0),
                      child: TextFormField(
                        onChanged: (value) {
                          Text("Name: ${_phoneContact!.fullName}");
                        },
                        controller: name,
                        decoration: InputDecoration(
                            hintText: "Name",
                            contentPadding: EdgeInsets.only(left: 10.0),
                            hintStyle: TextStyle(
                              color: Colors.grey,
                              fontSize: 14.0,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0),
                            )),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          left: 12.0, right: 12.0, top: 12.0 / 2361 * height),
                      child: TextFormField(
                        controller: lastName,
                        decoration: InputDecoration(
                            hintText: "Last Name",
                            contentPadding: EdgeInsets.only(left: 10.0),
                            hintStyle: TextStyle(
                              color: Colors.grey,
                              fontSize: 14.0,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0),
                            )),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          left: 12.0, right: 12.0, top: 12.0 / 2361 * height),
                      child: TextFormField(
                        controller: mobileNumber,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                            hintText: "Phone Number",
                            contentPadding: EdgeInsets.only(left: 10.0),
                            hintStyle: TextStyle(
                              color: Colors.grey,
                              fontSize: 14.0,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0),
                            )),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          left: 12.0, right: 12.0, top: 12.0 / 2361 * height),
                      child: TextFormField(
                        controller: address,
                        decoration: InputDecoration(
                            hintText: "Address",
                            contentPadding: EdgeInsets.only(left: 10.0),
                            hintStyle: TextStyle(
                              color: Colors.grey,
                              fontSize: 14.0,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0),
                            )),
                      ),
                    ),
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
                          addCustomer();
                        },
                        child: Text("Save"),
                        style: TextButton.styleFrom(
                          backgroundColor: Color.fromRGBO(62, 13, 59, 1),
                        ),
                      ),
                    ),
                  ],
                ),
              ]),
        ),
      ),
    );
  }
}
