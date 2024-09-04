import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttercontactpicker/fluttercontactpicker.dart';

import 'package:hta/language/language_constant.dart';
import 'package:hta/widgets/first_letter_capital.dart';
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
  String countryCode = 'IN';

  final _formKey = GlobalKey<FormState>();
  final address = TextEditingController();

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
    _getCountryCode();

    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  Future<void> addCustomer() async {
    if (_formKey.currentState!.validate()) {
      try {
        final SharedPreferences sharedPreferences =
            await SharedPreferences.getInstance();
        var token = sharedPreferences.getString('token');
        var organisation = sharedPreferences.getString('organisation');

        final url =
            Uri.parse('${AppConstants.backendUrl}/api/customer/addCustomer');

        // Ensure phone number includes the default country code
        String phoneNumber = mobileNumber.text;
        if (!phoneNumber.startsWith('+')) {
          phoneNumber = '${_getCountryCodePrefix()}' + phoneNumber;
        }

        final body = {
          "organisationName": organisationName.text,
          "name": name.text,
          "lastName": lastName.text,
          "mobileNumber": phoneNumber,
          "userType": "costomer",
          "organisation": organisation,
        };
        final header = {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        };

        final response =
            await http.post(url, body: jsonEncode(body), headers: header);
        final responseData = jsonDecode(response.body.toString());

        if (responseData['code'] == 1) {
          _showSuccessDialog();
        } else {
          _showErrorDialog(responseData);
        }
      } on SocketException catch (_) {
        _showGenericErrorDialog(
            'No Internet connection. Please check your network and try again.');
      } on HttpException catch (e) {
        _showGenericErrorDialog('HTTP Exception: ${e.message}');
      } on FormatException catch (e) {
        _showGenericErrorDialog('Format Exception: ${e.message}');
      } catch (e) {
        _showGenericErrorDialog('Something went wrong: ${e.toString()}');
      }
    }
  }

  String _getCountryCodePrefix() {
    // Define the default country code
    const String defaultCountryCode = '+91';

    // Check if the provided country code is valid and different from the default
    if (countryCode == 'KW') {
      return '+965'; // Kuwait country code
    } else {
      // Return the default country code if countryCode is not 'KW'
      return defaultCountryCode;
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

  Future<void> _getCountryCode() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    setState(() {
      countryCode = sharedPreferences.getString('country') ?? 'IN';
    });
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
          child: SingleChildScrollView(
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

                              String rawNumber = _phoneContact!
                                  .phoneNumber!.number
                                  .toString()
                                  .trim();

                              // Remove all non-numeric characters except the + sign
                              rawNumber =
                                  rawNumber.replaceAll(RegExp(r'[^0-9+]'), '');

                              // Remove the + sign if present
                              if (rawNumber.startsWith('+')) {
                                rawNumber = rawNumber.substring(1);
                              }

                              // Handle specific country codes
                              if (rawNumber.startsWith('91')) {
                                // If the number starts with 91, it's already in +91 format, so remove the '91'
                                rawNumber = rawNumber.substring(2);
                              }

                              // Remove leading zero if present
                              if (rawNumber.startsWith('0')) {
                                rawNumber = rawNumber.substring(1);
                              }

                              // Update mobile number field
                              mobileNumber.text = rawNumber;

                              // Update organization and name fields only if they are empty
                              if (organisationName.text.isEmpty) {
                                organisationName.text =
                                    _phoneContact!.fullName.toString();
                              }
                              if (name.text.isEmpty) {
                                name.text = _phoneContact!.fullName.toString();
                              }
                            });
                          },
                          style: TextButton.styleFrom(
                            backgroundColor:
                                const Color.fromRGBO(62, 13, 59, 1),
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
                          inputFormatters: [
                            CapitalizeFirstLetterFormatter(),
                          ],
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
                          inputFormatters: [
                            CapitalizeFirstLetterFormatter(),
                          ],
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
                          inputFormatters: [
                            CapitalizeFirstLetterFormatter(),
                          ],
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
                            } else if (!RegExp(r'^\d{10}$').hasMatch(value)) {
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
                                    color: Color.fromRGBO(62, 13, 59, 1))),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 12.0, right: 12.0, top: 12.0),
                        child: TextFormField(
                          focusNode: _focusNodes[4],
                          controller: address,
                          decoration: InputDecoration(
                              hintText: translation(context)!.hintTextAddress,
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
                          inputFormatters: [
                            CapitalizeFirstLetterFormatter(),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.2,
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
                            addCustomer();
                          },
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
      ),
    );
  }
}
