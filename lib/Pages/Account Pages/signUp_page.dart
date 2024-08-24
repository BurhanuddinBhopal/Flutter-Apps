import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:page_transition/page_transition.dart';
import '../../constant.dart';
import 'login_page.dart';
import 'success_page.dart';
import '../../language/language_constant.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final organisationName = TextEditingController();
  final organisationDescription = TextEditingController();
  final adminName = TextEditingController();
  final adminLastName = TextEditingController();
  final mobileNumber = TextEditingController();
  final password = TextEditingController();

  bool isHiddenPassword = true;
  final _formKey = GlobalKey<FormState>();
  String? selectedCountry;
  bool _isLoading = false;

  final Map<String, String> countryCodes = {
    'India': 'IN',
    'Kuwait': 'KW',
  };

  void _togglePasswordView() {
    setState(() {
      isHiddenPassword = !isHiddenPassword;
    });
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Center(
        child: AlertDialog(
          title: Text(translation(context)!.errorOccurred),
          content: Text(message),
          actions: <Widget>[
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(62, 13, 59, 1)),
                child: Text(
                  translation(context)!.okay,
                  style: const TextStyle(color: Colors.white),
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

  Future<void> userSignUp() async {
    if (_formKey.currentState!.validate()) {
      if (selectedCountry == null) {
        _showGenericErrorDialog('Please select a country');
        return;
      }

      setState(() {
        _isLoading = true;
      });

      final url =
          Uri.parse('${AppConstants.backendUrl}/api/orgainastion/signUp');

      final body = {
        'OrganisationName': organisationName.text,
        'OrganisationDescription': organisationDescription.text,
        'name': adminName.text,
        'lastName': adminLastName.text,
        'mobile': mobileNumber.text,
        'password': password.text,
        'country': countryCodes[selectedCountry!],
      };

      try {
        final response = await http.post(
          url,
          body: jsonEncode(body),
          headers: {'Content-Type': 'application/json'},
        );

        print('Request body: $body');
        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');

        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body.toString());

          if (responseData['code'] == 1) {
            Navigator.push(
              context,
              PageTransition(
                type: PageTransitionType.fade,
                child: SuccessPage(),
              ),
            );
          } else {
            String errorMessage =
                responseData['message'] ?? 'Something went wrong';
            _showGenericErrorDialog(errorMessage);
          }
        } else {
          _showGenericErrorDialog(
              'Server error: ${response.statusCode}. Please try again.');
        }
      } on SocketException catch (_) {
        _showGenericErrorDialog(
            'No Internet connection. Please check your network and try again.');
      } on FormatException catch (e) {
        _showGenericErrorDialog(
            'Invalid data format. Please check your input and try again.');
      } catch (e) {
        _showGenericErrorDialog('Something went wrong. Please try again.');
      } finally {
        setState(() {
          _isLoading = false;
        });
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

  Future<bool> _onBackButtonPressed(BuildContext context) async {
    bool exitApp = false;

    // Show dialog
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(translation(context)!.confirmExit,
              style: const TextStyle(color: Colors.black, fontSize: 20.0)),
          content: Text(translation(context)!.sureExit),
          actions: <Widget>[
            TextButton(
              child: Text(translation(context)!.yes,
                  style: const TextStyle(fontSize: 18.0)),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
            TextButton(
              child: Text(translation(context)!.no,
                  style: const TextStyle(fontSize: 18.0)),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            )
          ],
        );
      },
    ).then((value) {
      if (value != null) {
        exitApp = value;
      }
    });

    return exitApp;
  }

  final List<FocusNode> _focusNodes = [
    FocusNode(),
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
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return Scaffold(
      appBar: PreferredSize(
        preferredSize:
            Size.fromHeight(MediaQuery.of(context).size.height * 0.14),
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: const Color.fromRGBO(62, 13, 59, 1),
          flexibleSpace: SafeArea(
            child: Container(
              margin: const EdgeInsets.only(top: 50),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      translation(context)!.signUp,
                      style: const TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.w400,
                          color: Colors.white),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoginPage()));
                      },
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: WillPopScope(
          onWillPop: () => _onBackButtonPressed(context),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 20),
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
                        hintText: translation(context)!.hintTextOrganisation,
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
                            color: Color.fromRGBO(62, 13, 59, 1),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: organisationDescription,
                      focusNode: _focusNodes[1],
                      keyboardType: TextInputType.multiline,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return translation(context)!
                              .validateMessageOrganisationDescriptionNotEmpty;
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: translation(context)!
                            .hintTextOrganisationDescription,
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
                            color: Color.fromRGBO(62, 13, 59, 1),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: adminName,
                      focusNode: _focusNodes[2],
                      validator: (value) {
                        if (value!.isEmpty) {
                          return translation(context)!
                              .validateMessageAdminNameNotEmpty;
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: translation(context)!.hintTextAdminName,
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
                            color: Color.fromRGBO(62, 13, 59, 1),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: adminLastName,
                      focusNode: _focusNodes[3],
                      validator: (value) {
                        if (value!.isEmpty) {
                          return translation(context)!
                              .validateMessageAdminLastNameNotEmpty;
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: translation(context)!.hintTextAdminLastName,
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
                            color: Color.fromRGBO(62, 13, 59, 1),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: mobileNumber,
                      focusNode: _focusNodes[4],
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return translation(context)!
                              .validateMessageMobileNumber;
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: translation(context)!.hintTextMobileNumber,
                        contentPadding: const EdgeInsets.only(left: 10.0),
                        hintStyle: TextStyle(
                          color: _focusNodes[4].hasFocus
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
                            color: Color.fromRGBO(62, 13, 59, 1),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedCountry,
                      onChanged: (newValue) {
                        setState(() {
                          selectedCountry = newValue;
                        });
                      },
                      decoration: InputDecoration(
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 10.0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        hintText: 'Select Country',
                        hintStyle: const TextStyle(fontSize: 14.0),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(
                            width: 2,
                            color: Color.fromRGBO(62, 13, 59, 1),
                          ),
                        ),
                      ),
                      items: countryCodes.keys.map((String country) {
                        return DropdownMenuItem<String>(
                          value: country,
                          child: Text(country),
                        );
                      }).toList(),
                      validator: (value) =>
                          value == null ? 'Please select a country' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: password,
                      focusNode: _focusNodes[5],
                      obscureText: isHiddenPassword,
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
                        hintText: translation(context)!.hintTextPassword,
                        contentPadding: const EdgeInsets.only(left: 10.0),
                        hintStyle: TextStyle(
                          color: _focusNodes[5].hasFocus
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
                            color: Color.fromRGBO(62, 13, 59, 1),
                          ),
                        ),
                        suffixIcon: InkWell(
                          onTap: _togglePasswordView,
                          child: Icon(
                            isHiddenPassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                        ),
                      ),
                    ),
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 30),
                          child: ElevatedButton(
                            style: TextButton.styleFrom(
                              backgroundColor:
                                  const Color.fromRGBO(62, 13, 59, 1),
                              shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.zero),
                              minimumSize: const Size(350, 50),
                            ),
                            onPressed: () {
                              userSignUp();
                            },
                            child: Text(translation(context)!.signUpCapital),
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
