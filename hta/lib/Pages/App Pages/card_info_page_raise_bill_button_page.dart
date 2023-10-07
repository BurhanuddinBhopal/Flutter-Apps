// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:convert';

import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'home_page_card_info_page.dart';

class RaiseBillPage extends StatefulWidget {
  final customerData;
  final pendingAmount;

  const RaiseBillPage(
      {required this.customerData, required this.pendingAmount});

  @override
  State<RaiseBillPage> createState() => _RaiseBillPageState();
}

class _RaiseBillPageState extends State<RaiseBillPage> {
  var customerData;
  DateTime datetime = DateTime.now();
  final dateController = TextEditingController(
    text: DateFormat("yyyy-MM-dd").format(DateTime.now()),
  );
  DateTime currentDatetime = DateTime.now();
  final amount = TextEditingController();
  final description = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  var finalImage;
  var finalPendingAmount;

  File? pickedImageCamera;
  File? pickedImageGallery;
  String selectedImagePath = '';
  bool isLoading = false;
  List<FocusNode> _focusNodes = [
    FocusNode(),
    FocusNode(),
    FocusNode(),
  ];

  pickImageCamera() async {
    XFile? cameraImage = await ImagePicker()
        .pickImage(source: ImageSource.camera, imageQuality: 50);

    setState(() {
      pickedImageCamera = File(cameraImage!.path);
    });
    if (pickedImageCamera != null) {
      upload(pickedImageCamera!);
    }
    return null;
  }

  pickImageGallery() async {
    XFile? galleryImage = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 50);

    setState(() {
      pickedImageGallery = File(galleryImage!.path);
    });
    if (pickedImageGallery != null) {
      upload(pickedImageGallery!);
    }
    return null;
  }

  selectImage() async {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)), //this right here
            child: Container(
              height: MediaQuery.of(context).size.height * 0.2,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    Text(
                      'Select Image From !',
                      style: TextStyle(
                          fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          GestureDetector(
                            onTap: () async {
                              selectedImagePath = await pickImageGallery();

                              if (selectedImagePath != '') {
                                Navigator.pop(context);
                                setState(() {});
                              } else {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                  content: Text("No Image Selected !"),
                                ));
                              }
                            },
                            child: Card(
                                elevation: 5,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: [
                                      Image.asset(
                                        'assets/images/gallery.png',
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.06,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.15,
                                      ),
                                      Text('Gallery'),
                                    ],
                                  ),
                                )),
                          ),
                          GestureDetector(
                            onTap: () async {
                              selectedImagePath = await pickImageCamera();

                              if (selectedImagePath != '') {
                                Navigator.pop(context);
                                setState(() {});
                              } else {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                  content: Text("No Image Captured !"),
                                ));
                              }
                            },
                            child: Card(
                                elevation: 5,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: [
                                      Image.asset(
                                        'assets/images/camera.png',
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.06,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.15,
                                      ),
                                      Text('Camera'),
                                    ],
                                  ),
                                )),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }

  upload(File file) async {
    //hide Plus button and show text "Image uploading..."

    setState(() {
      isLoading = true;
    });

    final uploadUrl = 'https://hta.hatimtechnologies.in/api/upload-media';
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    var token = sharedPreferences.getString('token');

    Map<String, String> headers = {
      'Authorization': 'Bearer $token',
    };
    var uri = Uri.parse(uploadUrl);
    var length = await file.length();

    http.MultipartRequest request = http.MultipartRequest('POST', uri)
      ..headers.addAll(headers)
      ..files.add(
        http.MultipartFile('file', file.openRead(), length,
            filename: 'file.png'),
      );
    var response = await http.Response.fromStream(await request.send());

    var responseData = jsonDecode(response.body.toString());
    var imageUrl = responseData['fileLink'];
    setState(() {
      finalImage = imageUrl;
    });

    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    setState(() {
      customerData = widget.customerData;
      finalPendingAmount = widget.pendingAmount;
    });

    _focusNodes.forEach((node) {
      node.addListener(() {
        setState(() {});
      });
    });

    super.initState();
  }

  Future<void> raiseBill() async {
    if (_formKey.currentState!.validate()) {
      final SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      var token = sharedPreferences.getString('token');

      final url = Uri.parse(
          'https://hta.hatimtechnologies.in/api/transactions/addTransaction');

      final body = {
        "orderId": "",
        "customer": customerData['_id'],
        "amount": amount.text,
        "createdAt": dateController.text,
        "paymentStatus": "",
        "message": description.text,
        "picture": finalImage == null ? "" : finalImage,
        "orderStatus": "BILL-RAISED",
        "pendingAmount":
            ((finalPendingAmount) + int.parse(amount.text)).toString(),
      };
      final header = {
        'Authorization': 'Bearer $token',
      };

      final response = await http.post(url, body: body, headers: header);
      var responseData = jsonDecode(response.body);
      var pendingAmount = responseData['dueAmount'];
      setState(() {
        finalPendingAmount = pendingAmount;
      });

      if (responseData['code'] == 1) {
        _showSuccesDialog();
      } else {
        _showErrorDialog(responseData);
      }
    }
  }

  void _showSuccesDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Transaction completed succesfully'),
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
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => DetailedCardPage(
                              customerData: customerData,
                            )));
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

  Future<bool> _onBackButtonPressed(BuildContext context) async {
    bool exitApp = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Confirm Exit"),
            content: Text("Are you sure you want to exit?"),
            actions: <Widget>[
              TextButton(
                child: Text("YES"),
                onPressed: () {
                  SystemNavigator.pop();
                },
              ),
              TextButton(
                child: Text("NO"),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              )
            ],
          );
        }) as bool;
    return exitApp;
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return Scaffold(
      resizeToAvoidBottomInset: false,
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            color: Color.fromRGBO(186, 0, 0, 1),
                            height: 100,
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 35),
                              child: Padding(
                                padding: EdgeInsets.only(top: 40),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Raise BILL',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w900,
                                          color: Colors.white),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.close,
                                        size: 24,
                                        color: Colors.white,
                                      ),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 8),
                            child: Text(
                              'Amount',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: TextFormField(
                              focusNode: _focusNodes[0],
                              controller: amount,
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Amount cannot be empty';
                                }

                                double numericValue = double.parse(value);
                                if (numericValue <= 0) {
                                  return 'Amount should be greater than zero';
                                }

                                return null;
                              },
                              decoration: InputDecoration(
                                  hintText: "Type your amount here",
                                  hintStyle: TextStyle(
                                    color: _focusNodes[0].hasFocus
                                        ? Color.fromRGBO(62, 13, 59, 1)
                                        : Colors.grey,
                                    fontSize: 14.0,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.currency_rupee,
                                    size: 19.0,
                                    color: _focusNodes[0].hasFocus
                                        ? Color.fromRGBO(62, 13, 59, 1)
                                        : Colors.grey,
                                  ),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5.0)),
                                  focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          width: 2,
                                          color:
                                              Color.fromRGBO(62, 13, 59, 1)))),
                            ),
                          ),
                          SizedBox(height: 16),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              'Description',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(height: 8),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: TextFormField(
                              focusNode: _focusNodes[1],
                              controller: description,
                              decoration: InputDecoration(
                                  hintText: "Type your comment here",
                                  hintStyle: TextStyle(
                                    color: _focusNodes[1].hasFocus
                                        ? Color.fromRGBO(62, 13, 59, 1)
                                        : Colors.grey,
                                    fontSize: 14.0,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.message,
                                    size: 19.0,
                                    color: _focusNodes[1].hasFocus
                                        ? Color.fromRGBO(62, 13, 59, 1)
                                        : Colors.grey,
                                  ),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5.0)),
                                  focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          width: 2,
                                          color:
                                              Color.fromRGBO(62, 13, 59, 1)))),
                            ),
                          ),
                          SizedBox(height: 16),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              'Date',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(height: 8),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: TextFormField(
                              focusNode: _focusNodes[2],
                              controller: dateController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Date cannot be empty';
                                }
                                DateTime enteredDate = DateTime.parse(value);

                                if (enteredDate.isAfter(currentDatetime)) {
                                  return 'Date cannot be greater than today';
                                }
                              },
                              decoration: InputDecoration(
                                  prefixIcon: Icon(
                                    Icons.calendar_month_rounded,
                                    size: 19.0,
                                    color: Color.fromRGBO(62, 13, 59, 1),
                                  ),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5.0)),
                                  focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          width: 2,
                                          color:
                                              Color.fromRGBO(62, 13, 59, 1)))),
                            ),
                          ),
                        ],
                      ),
                      isLoading
                          ? Container(
                              margin: EdgeInsets.symmetric(vertical: 16),
                              child: Text('Image uploading'))
                          : Container(
                              child: finalImage == null
                                  ? Image.asset(
                                      'assets/images/white.jpg',
                                      width:
                                          MediaQuery.of(context).size.width * 1,
                                      height: 0,
                                    )
                                  : Container(
                                      margin:
                                          EdgeInsets.symmetric(vertical: 16),
                                      child: Image.network(
                                        finalImage,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.5,
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.2,
                                      ),
                                    )),
                      finalImage == null
                          ? isLoading
                              ? Container()
                              : Container(
                                  margin: EdgeInsets.symmetric(
                                      horizontal: 30, vertical: 100),
                                  child: FloatingActionButton.small(
                                    //if isLoading false && final image empty
                                    //if isLoading is true "Image uploading"
                                    //if isLoading is false && final image in not empty ==> show image
                                    onPressed: () {
                                      selectImage();
                                      setState(() {});
                                    },
                                    child: Icon(
                                      Icons.add,
                                    ),
                                  ),
                                )
                          : Container(),
                      Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 16, horizontal: 30),
                            child: isLoading
                                ? null
                                : ElevatedButton(
                                    style: TextButton.styleFrom(
                                      backgroundColor:
                                          Color.fromRGBO(186, 0, 0, 1),
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.zero),
                                      minimumSize: Size(350, 50),
                                    ),
                                    onPressed: () {
                                      if (!isLoading) {
                                        raiseBill();
                                      }
                                    },
                                    child: Text("RAISE BILL"),
                                  ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )),
          ),
        ),
      ),
    );
  }
}
