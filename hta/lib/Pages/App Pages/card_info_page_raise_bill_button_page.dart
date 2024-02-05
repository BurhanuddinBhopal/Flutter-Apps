// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, prefer_typing_uninitialized_variables
// how to add null check on image length while image is null dart?

import 'dart:convert';

import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hta/language/language_constant.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'home_page_card_info_page.dart';

class RaiseBillPage extends StatefulWidget {
  final customerData;
  final pendingAmount;
  final Function(List<String>) onUpdateImageUrls;

  const RaiseBillPage(
      {required this.customerData,
      required this.pendingAmount,
      required this.onUpdateImageUrls});

  @override
  State<RaiseBillPage> createState() => _RaiseBillPageState();
}

class _RaiseBillPageState extends State<RaiseBillPage> {
  var customerData;
  DateTime datetime = DateTime.now();
  final dateController = TextEditingController(
    text: DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z").format(DateTime.now()),
  );
  final dateControllerForDisplay = TextEditingController();

  DateTime currentDatetime = DateTime.now();
  final amount = TextEditingController();
  final description = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  var finalImage;
  var finalPendingAmount;
  var imageUrl;
  List<String> uploadedImageUrls = [];

  bool isLoading = false;
  bool isButtonDisabled = false;
  List<FocusNode> _focusNodes = [
    FocusNode(),
    FocusNode(),
    FocusNode(),
  ];
  File? pickedImageCamera;
  File? pickedImageGallery;
  String? selectedImagePath;

  XFile? cameraImage;
  List<XFile>? galleryImages;
  List<String> allSelectedImages = [];

  pickMultipleImagesCamera() async {
    XFile? pickedImage = await ImagePicker()
        .pickImage(imageQuality: 50, source: ImageSource.camera);

    if (pickedImage != null) {
      imageUrl = await upload(File(pickedImage.path));
      if (!allSelectedImages.contains(imageUrl)) {
        setState(() {
          allSelectedImages.add(imageUrl);
        });
      }
    }
  }

  pickMultipleImagesGallery() async {
    List<XFile>? pickedImages = await ImagePicker().pickMultiImage(
      imageQuality: 50,
    );

    if (pickedImages != null && pickedImages.isNotEmpty) {
      for (XFile image in pickedImages) {
        imageUrl = await upload(File(image.path));
        if (!allSelectedImages.contains(imageUrl)) {
          setState(() {
            allSelectedImages.add(imageUrl);
          });
        }
      }
    }
  }

  selectImage() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.2,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  Text(
                    translation(context).selectImageFrom,
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        GestureDetector(
                          onTap: () async {
                            pickMultipleImagesGallery();
                            Navigator.pop(context); // Close the dialog
                            setState(() {});
                          },
                          child: Card(
                            elevation: 5,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  Image.asset(
                                    'assets/images/gallery.png',
                                    height: MediaQuery.of(context).size.height *
                                        0.06,
                                    width: MediaQuery.of(context).size.width *
                                        0.15,
                                  ),
                                  Text(translation(context).gallery),
                                ],
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () async {
                            pickMultipleImagesCamera();
                            Navigator.pop(context); // Close the dialog
                            setState(() {});
                          },
                          child: Card(
                            elevation: 5,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  Image.asset(
                                    'assets/images/camera.png',
                                    height: MediaQuery.of(context).size.height *
                                        0.06,
                                    width: MediaQuery.of(context).size.width *
                                        0.15,
                                  ),
                                  Text(translation(context).camera),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
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
      finalImage = [imageUrl];
      isLoading = false;
    });
    return imageUrl;
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

    dateControllerForDisplay.text =
        DateFormat("yyyy-MM-dd").format(DateTime.now());

    super.initState();
  }

  Future<void> raiseBill() async {
    if (_formKey.currentState!.validate()) {
      if (isButtonDisabled) {
        return;
      }

      setState(() {
        isButtonDisabled = true;
      });
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
        "paymentStatus": {"paid": "successfully"}.toString(),
        "message": description.text,
        "picture": allSelectedImages == null ? "" : allSelectedImages.join(","),
        "orderStatus": "BILL-RAISED",
        "pendingAmount":
            ((finalPendingAmount) - int.parse(amount.text)).toString(),
      };
      final header = {
        'Authorization': 'Bearer $token',
      };

      final response = await http.post(url, body: body, headers: header);

      var responseData = jsonDecode(response.body.toString());

      if (responseData['code'] == 1) {
        _showSuccesDialog();
      } else {
        _showErrorDialog(responseData);
      }
      setState(() {
        isButtonDisabled = false;
      });
    }
  }

  void _showSuccesDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(translation(context).successMessageforTransaction),
        actions: <Widget>[
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromRGBO(62, 13, 59, 1),
              ),
              child: Text(
                translation(context).okay,
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => DetailedCardPage(
                            customerData: customerData,
                            imageUrls: uploadedImageUrls,
                            onUpdateImageUrls: widget.onUpdateImageUrls)));
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
                translation(context).okay,
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
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      color: Color.fromRGBO(186, 0, 0, 1),
                      height: 100,
                      padding: EdgeInsets.symmetric(horizontal: 35),
                      child: Padding(
                        padding: EdgeInsets.only(top: 40),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              translation(context).raiseBill,
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
                    SizedBox(height: 16),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      child: Text(
                        translation(context).amount,
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
                            return translation(context)
                                .validateMessageAmountNotEmpty;
                          }
                          double numericValue = double.parse(value);
                          if (numericValue <= 0) {
                            return translation(context)
                                .validateMessageAmountLength;
                          }

                          return null;
                        },
                        decoration: InputDecoration(
                            hintText: translation(context).hintTextAmount,
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
                                    color: Color.fromRGBO(62, 13, 59, 1)))),
                      ),
                    ),
                    SizedBox(height: 16),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        translation(context).description,
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
                            hintText: translation(context).hintTextDescription,
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
                                    color: Color.fromRGBO(62, 13, 59, 1)))),
                      ),
                    ),
                    SizedBox(height: 16),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        translation(context).date,
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
                        controller: dateControllerForDisplay,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return translation(context)
                                .validateMessageDateNotEmpty;
                          }
                          DateTime enteredDate = DateTime.parse(value);

                          if (enteredDate.isAfter(currentDatetime)) {
                            return translation(context)
                                .validateMessageDateLength;
                          }
                          return null;
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
                                    color: Color.fromRGBO(62, 13, 59, 1)))),
                      ),
                    ),
                  ],
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                  height: (allSelectedImages.isEmpty && cameraImage == null)
                      ? MediaQuery.of(context).size.height * 0.05
                      : MediaQuery.of(context).size.height * 0.25,
                  child: isLoading
                      ? Container(
                          margin: EdgeInsets.symmetric(vertical: 10),
                          child: Center(
                            child: Text(translation(context).imageUploading),
                          ),
                        )
                      : (allSelectedImages.isEmpty && cameraImage == null)
                          ? Image.asset(
                              'assets/images/white.jpg',
                              width: MediaQuery.of(context).size.width * 1,
                              height: 0,
                              fit: BoxFit.cover,
                            )
                          : GridView.builder(
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount:
                                    (allSelectedImages.length == 1) ? 1 : 2,
                                crossAxisSpacing: 8.0,
                                mainAxisSpacing: 8.0,
                              ),
                              itemCount: allSelectedImages.length +
                                  (cameraImage != null ? 1 : 0),
                              itemBuilder: (BuildContext context, int index) {
                                if (index < allSelectedImages.length) {
                                  return Container(
                                    margin: EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    child: Image.network(
                                        allSelectedImages[index],
                                        fit: BoxFit.cover
                                        // height: (allSelectedImages.length == 1)
                                        //     ? MediaQuery.of(context).size.height *
                                        //         0.05
                                        //     : null,
                                        ),
                                  );
                                } else {
                                  return Container(
                                    margin: EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    child: Image.file(
                                      File(cameraImage!.path),
                                      fit: BoxFit.cover,
                                      // height:
                                      //     MediaQuery.of(context).size.height *
                                      //         0.05,
                                    ),
                                  );
                                }
                              },
                            ),
                ),
                // finalImage == null && cameraImage == null
                //     ? isLoading
                //         ? Container()
                //         :
                Container(
                  margin: (allSelectedImages.isEmpty && cameraImage == null)
                      ? EdgeInsets.symmetric(horizontal: 30, vertical: 60)
                      : EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                  child: FloatingActionButton.small(
                    onPressed: () {
                      selectImage();
                    },
                    child: Icon(
                      Icons.add,
                    ),
                  ),
                ),
                // : Container(),
                Padding(
                  padding: (allSelectedImages.isEmpty && cameraImage == null)
                      ? EdgeInsets.symmetric(vertical: 16, horizontal: 30)
                      : EdgeInsets.symmetric(vertical: 5, horizontal: 30),
                  child: isLoading
                      ? null
                      : ElevatedButton(
                          style: TextButton.styleFrom(
                            backgroundColor: Color.fromRGBO(186, 0, 0, 1),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.zero),
                            minimumSize: Size(350, 50),
                          ),
                          onPressed: isButtonDisabled
                              ? null
                              : () {
                                  if (!isButtonDisabled) {
                                    raiseBill();
                                  }
                                },
                          child: Text(translation(context).raiseBillCapital),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
