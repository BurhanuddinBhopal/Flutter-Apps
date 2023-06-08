// ignore_for_file: prefer_const_literals_to_create_immutables, use_key_in_widget_constructors, prefer_const_constructors, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttercontactpicker/fluttercontactpicker.dart';

import 'package:hta/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class AddCustomerPage extends StatefulWidget {
  State<AddCustomerPage> createState() => _AddCustomerPageState();
}

class _AddCustomerPageState extends State<AddCustomerPage> {
  PhoneContact? _phoneContact;

  final organisationName = TextEditingController();
  final name = TextEditingController();
  final lastName = TextEditingController();
  final mobileNumber = TextEditingController();
  final address = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  List<FocusNode> _focusNodes = [
    FocusNode(),
    FocusNode(),
    FocusNode(),
    FocusNode(),
    FocusNode(),
  ];

  Future<void> addCustomer() async {
    if (_formKey.currentState!.validate()) {
      final SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      var token = sharedPreferences.getString('token');

      final url = Uri.parse(
          'https://hta.hatimtechnologies.in/api/customer/addCustomer');

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

      print(body);

      final response = await http.post(url, body: body, headers: header);

      _showErrorDialog();

      print(response.body);
    }
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Customer Added Successfully'),
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
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => HomePage()));
              },
            ),
          )
        ],
      ),
    );
  }

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
          'Add Customer',
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
                      Padding(
                        padding: EdgeInsets.only(top: 16.0),
                        child: ElevatedButton(
                          onPressed: () async {
                            final PhoneContact contact =
                                await FlutterContactPicker.pickPhoneContact();

                            setState(() {
                              _phoneContact = contact;
                              name.text = _phoneContact!.fullName.toString();
                              mobileNumber.text =
                                  _phoneContact!.phoneNumber!.number.toString();
                            });
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: Color.fromRGBO(62, 13, 59, 1),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.zero),
                            minimumSize: Size(250, 40),
                          ),
                          child: Text(
                            "Select from PhoneBook",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      Padding(
                        padding:
                            EdgeInsets.only(left: 12.0, right: 12.0, top: 12.0),
                        child: TextFormField(
                          controller: organisationName,
                          focusNode: _focusNodes[0],
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Organization Name cannot be empty';
                            }

                            return null;
                          },
                          decoration: InputDecoration(
                              hintText: "Organization Name",
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
                                      color: Color.fromRGBO(62, 13, 59, 1)))),
                        ),
                      ),
                      Padding(
                        padding:
                            EdgeInsets.only(left: 12.0, right: 12.0, top: 12.0),
                        child: TextFormField(
                          controller: name,
                          focusNode: _focusNodes[1],
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Name cannot be empty';
                            }

                            return null;
                          },
                          decoration: InputDecoration(
                              hintText: "Name",
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
                                      color: Color.fromRGBO(62, 13, 59, 1)))),
                        ),
                      ),
                      Padding(
                        padding:
                            EdgeInsets.only(left: 12.0, right: 12.0, top: 12.0),
                        child: TextFormField(
                          controller: lastName,
                          focusNode: _focusNodes[2],
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Last Name cannot be empty';
                            }

                            return null;
                          },
                          decoration: InputDecoration(
                              hintText: "Last Name",
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
                                      color: Color.fromRGBO(62, 13, 59, 1)))),
                        ),
                      ),
                      Padding(
                        padding:
                            EdgeInsets.only(left: 12.0, right: 12.0, top: 12.0),
                        child: TextFormField(
                          focusNode: _focusNodes[3],
                          controller: mobileNumber,
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Phone Number cannot be empty';
                            }

                            return null;
                          },
                          decoration: InputDecoration(
                              hintText: "Phone Number",
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
                                      color: Color.fromRGBO(62, 13, 59, 1)))),
                        ),
                      ),
                      Padding(
                        padding:
                            EdgeInsets.only(left: 12.0, right: 12.0, top: 12.0),
                        child: TextFormField(
                          controller: address,
                          focusNode: _focusNodes[4],
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Address cannot be empty';
                            }

                            return null;
                          },
                          decoration: InputDecoration(
                              hintText: "Address",
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
                                      color: Color.fromRGBO(62, 13, 59, 1)))),
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
      ),
    );
  }
}
