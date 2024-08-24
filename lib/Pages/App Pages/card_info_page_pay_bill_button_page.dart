// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, prefer_typing_uninitialized_variables
// how to add null check on image length while image is null dart?

import 'dart:convert';

import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hta/language/language_constant.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../constant.dart';
import 'home_page_card_info_page.dart';

class PayBillPage extends StatefulWidget {
  final customerData;
  final pendingAmount;
  final onUpdateImageUrls;

  const PayBillPage(
      {super.key,
      this.customerData,
      this.pendingAmount,
      this.onUpdateImageUrls});

  @override
  State<PayBillPage> createState() => _PayBillPageState();
}

class _PayBillPageState extends State<PayBillPage> {
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
  final List<FocusNode> _focusNodes = [
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
  String? countryCode;

  Future<void> _getCountryCode() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    setState(() {
      countryCode = sharedPreferences.getString('country') ?? 'IN';
    });
  }

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

    if (pickedImages.isNotEmpty) {
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

  void removeImage(int index) {
    setState(() {
      allSelectedImages.removeAt(index);
    });
  }

  selectImage() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.2,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  Text(
                    translation(context)!.selectImageFrom,
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
                                  Text(translation(context)!.gallery),
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
                                  Text(translation(context)!.camera),
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

    const uploadUrl = '${AppConstants.backendUrl}/api/upload-media';
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
    _getCountryCode();
    setState(() {
      customerData = widget.customerData;
      finalPendingAmount = widget.pendingAmount;
    });

    for (var node in _focusNodes) {
      node.addListener(() {
        setState(() {});
      });
    }

    dateControllerForDisplay.text =
        DateFormat("yyyy-MM-dd").format(DateTime.now());

    super.initState();
  }

  Future<void> payBill() async {
    if (_formKey.currentState!.validate()) {
      if (isButtonDisabled) {
        return;
      }

      setState(() {
        isButtonDisabled = true;
      });

      try {
        final SharedPreferences sharedPreferences =
            await SharedPreferences.getInstance();
        var token = sharedPreferences.getString('token');

        final url = Uri.parse(
            '${AppConstants.backendUrl}/api/transactions/addTransaction');

        // Parsing the amount as double
        final parsedAmount = double.tryParse(amount.text);

        // If parsing fails, throw an error
        if (parsedAmount == null) {
          throw FormatException('Invalid amount format');
        }

        // Format amount to 2 decimal places
        final formattedAmount = parsedAmount.toStringAsFixed(2);

        final body = {
          "orderId": "",
          "customer": customerData['_id'],
          "amount": formattedAmount,
          "createdAt": dateController.text,
          "paymentStatus": {"paid": "successfully"}.toString(),
          "message": description.text,
          "picture":
              allSelectedImages == null ? "" : allSelectedImages.join(","),
          "orderStatus": "PAYMENT-COLLECTED",
          "pendingAmount":
              ((finalPendingAmount) - parsedAmount).toStringAsFixed(2),
        };

        final header = {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        };

        final response =
            await http.post(url, body: jsonEncode(body), headers: header);

        var responseData = jsonDecode(response.body.toString());

        if (responseData['code'] == 1) {
          _showSuccesDialog();
        } else {
          _showErrorDialog(responseData);
        }
      } on SocketException catch (_) {
        // No Internet connection or failed to reach the server
        _showGenericErrorDialog(
            'No Internet connection. Please check your network and try again.');
      } on FormatException catch (e) {
        // Invalid amount format
        _showGenericErrorDialog(
            'Invalid amount format. Please enter a valid number.');
      } catch (e) {
        // Other unexpected errors
        _showGenericErrorDialog('Something went wrong. Please try again.');
      } finally {
        setState(() {
          isButtonDisabled = false;
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

  void _showSuccesDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text(translation(context)!.successMessageforTransaction),
        actions: <Widget>[
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromRGBO(62, 13, 59, 1),
              ),
              child: Text(
                translation(context)!.okay,
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
                translation(context)!.okay,
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
            FocusScope.of(context).unfocus();
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
                      color: Color.fromRGBO(52, 135, 89, 1),
                      height: 100,
                      padding: EdgeInsets.symmetric(horizontal: 35),
                      child: Padding(
                        padding: EdgeInsets.only(top: 40),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              translation(context)!.payBill,
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
                        translation(context)!.amount,
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
                            return translation(context)!
                                .validateMessageAmountNotEmpty;
                          }

                          final numericValue = double.tryParse(value);
                          if (numericValue == null) {
                            return 'Invalid amount format. Please enter a valid number.';
                          }

                          // Check if the number has more than two decimal places
                          final amountString = value.split('.');
                          if (amountString.length > 1 &&
                              amountString[1].length > 2) {
                            return 'Only up to 2 decimal places are allowed.';
                          }

                          if (numericValue <= 0) {
                            return translation(context)!
                                .validateMessageAmountLength;
                          }

                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: translation(context)!.hintTextAmount,
                          hintStyle: TextStyle(
                            color: _focusNodes[0].hasFocus
                                ? Color.fromRGBO(62, 13, 59, 1)
                                : Colors.grey,
                            fontSize: 14.0,
                          ),
                          prefixIcon: countryCode == 'KW'
                              ? Image.asset(
                                  'assets/images/kwd.png',
                                  width: 5,
                                  height: 5,
                                  color: _focusNodes[0].hasFocus
                                      ? Color.fromRGBO(62, 13, 59, 1)
                                      : Colors.grey,
                                )
                              : Icon(
                                  Icons.currency_rupee,
                                  size: 19.0,
                                  color: _focusNodes[0].hasFocus
                                      ? Color.fromRGBO(62, 13, 59, 1)
                                      : Colors.grey,
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
                    ),
                    SizedBox(height: 16),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        translation(context)!.description,
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
                            hintText: translation(context)!.hintTextDescription,
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
                        translation(context)!.date,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: TextFormField(
                        enabled: false,
                        focusNode: _focusNodes[2],
                        controller: dateControllerForDisplay,
                        style: TextStyle(
                          color: Color.fromRGBO(62, 13, 59, 1),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return translation(context)!
                                .validateMessageDateNotEmpty;
                          }
                          DateTime enteredDate = DateTime.parse(value);

                          if (enteredDate.isAfter(currentDatetime)) {
                            return translation(context)!
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
                              child: Text(translation(context)!.imageUploading),
                            ),
                          )
                        // : (allSelectedImages.isEmpty && cameraImage == null)
                        //     ? Image.asset(
                        //         'assets/images/white.jpg',
                        //         width: MediaQuery.of(context).size.width * 1,
                        //         height: 0,
                        //         fit: BoxFit.cover,
                        //       )
                        : Container(
                            alignment: Alignment.center,
                            child: GridView.builder(
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount:
                                    (allSelectedImages.length == 1 &&
                                            cameraImage == null)
                                        ? 1
                                        : 2,
                                crossAxisSpacing: 4.0,
                                mainAxisSpacing: 4.0,
                              ),
                              itemCount: allSelectedImages.length +
                                  (cameraImage != null ? 1 : 0),
                              itemBuilder: (BuildContext context, int index) {
                                if (index < allSelectedImages.length) {
                                  return buildImageWidget(
                                      allSelectedImages[index], index);
                                } else {
                                  return buildImageWidget(
                                      cameraImage!.path, index);
                                }
                              },
                            ),
                          )),
                // finalImage == null && cameraImage == null
                //     ? isLoading
                //         ? Container()
                //         :
                Container(
                  margin: (allSelectedImages.isEmpty && cameraImage == null)
                      ? EdgeInsets.symmetric(horizontal: 30, vertical: 60)
                      : EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                  child: allSelectedImages.isEmpty && cameraImage == null
                      ? FloatingActionButton.small(
                          onPressed: () {
                            selectImage();
                          },
                          child: Image.asset('assets/images/upload_image.png'),
                        )
                      : ElevatedButton(
                          onPressed: () {
                            selectImage();
                          },
                          child: Text('Upload More Images'),
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
                            backgroundColor: Color.fromRGBO(52, 135, 89, 1),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.zero),
                            minimumSize: Size(350, 50),
                          ),
                          onPressed: isButtonDisabled
                              ? null
                              : () {
                                  if (!isButtonDisabled) {
                                    payBill();
                                  }
                                },
                          child: Text(translation(context)!.paybillCapital),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildImageWidget(String imagePath, int index) {
    return Center(
      child: Container(
        margin: EdgeInsets.all(4.0),
        width: MediaQuery.of(context).size.width * 0.7,
        height: MediaQuery.of(context).size.height * 0.8,
        child: Stack(
          children: [
            ClipRRect(
              borderRadius:
                  BorderRadius.circular(8.0), // Optional: Add rounded corners
              child: Image.network(
                imagePath,
                fit: BoxFit.cover, // Maintain aspect ratio and fill container
                width: double.infinity,
                height: double.infinity,
              ),
            ),
            Positioned(
              top: EdgeInsets.symmetric(vertical: 12.0).top,
              right: EdgeInsets.symmetric(horizontal: 12.0).right,
              child: GestureDetector(
                onTap: () {
                  removeImage(index);
                },
                child: FaIcon(
                  FontAwesomeIcons.times,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
