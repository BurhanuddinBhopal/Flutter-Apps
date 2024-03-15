// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hta/Pages/App%20Pages/home_page_card_info_page.dart';
import 'package:hta/Pages/App%20Pages/image_page.dart';
import 'package:hta/language/language_constant.dart';

import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
import 'package:pinch_zoom/pinch_zoom.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailedInfoPage extends StatefulWidget {
  final customerOrganization;
  final customerData;
  final List<String>? imageUrls;
  final Function(List<String>) onUpdateImageUrls;

  const DetailedInfoPage({
    required this.customerOrganization,
    required this.customerData,
    required this.imageUrls,
    required this.onUpdateImageUrls,
  });

  @override
  State<DetailedInfoPage> createState() => _DetailedInfoPageState();
}

class _DetailedInfoPageState extends State<DetailedInfoPage> {
  var _customerData = {};
  var _customerOrganization = {};
  List<String>? image;

  var name;
  var billAmount;
  var pendingAmount;
  var mobileNumber;

  bool isLoading = false;
  List<String> imageUrls = [];
  List<String> imageUrls1 = [];

  void updateImageUrls(List<String> newImageUrls) {
    widget.onUpdateImageUrls(newImageUrls);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Get the arguments from the route
    final args = ModalRoute.of(context)!.settings.arguments;

    if (args != null) {
      // Assuming the argument is a List<String>
      image = args as List<String>;
    }
  }

  @override
  void initState() {
    transactionData();
    setState(() {
      _customerOrganization = widget.customerOrganization;
      _customerData = widget.customerData;
      image = [_customerOrganization['picture']];
      print("image: $image");
      mobileNumber = _customerData['mobileNumber'];
      name = _customerData["organisationName"];
      billAmount = _customerOrganization["amount"];
      pendingAmount = _customerData["pendingAmount"];
      if (image is List<String>) {
        imageUrls.addAll(image as List<String>);
        if (imageUrls.isNotEmpty) {
          // Split the first element of imageUrls and add to imageUrls1
          imageUrls1.addAll(imageUrls[0].split(','));
        }
        print('imageUrls1: $imageUrls1');
      } else if (image is String) {
        // If 'image' is a single string, split it into multiple URLs
        imageUrls = (image as String).split(',');
      }
    });

    // TODO: implement initState
    super.initState();
  }

  Future<void> transactionData() async {
    setState(() {
      isLoading = true;
    });
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    var token = sharedPreferences.getString('token');
    final url = Uri.parse(
        'https://hta.hatimtechnologies.in/api/transactions/getAllTransaction');
    final body = {"customer": _customerData["_id"]};
    final header = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    // ignore: unused_local_variable
    final response = await http.post(
      url,
      headers: header,
      body: jsonEncode(body),
    );

    setState(() {
      isLoading = false;
    });
  }

  void _launchSms() async {
    try {
      String imageText = imageUrls1.join(', ');
      String uri =
          'sms:$mobileNumber?body=${Uri.encodeComponent("Hi $name your bill has been raised for amount $billAmount and your pending balance is $pendingAmount. Images: $imageText ")}';

      if (await launchUrl(Uri.parse(uri))) {
        // Handle success
      } else {
        throw 'Failed to launch SMS';
      }
    } catch (e) {
      print('Error launching SMS: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Some error occurred. Please try again!'),
        ),
      );
    }
  }

  void launchWhatsapp() async {
    try {
      String imageText = imageUrls1.join(', ');
      String uri =
          'https://wa.me/number:$mobileNumber:/?text=${Uri.parse('Hi $name your bill has been raised for amount $billAmount and your pending balance is $pendingAmount.')}';

      if (await launch(uri)) {
        // Handle success
      } else {
        throw 'Failed to launch WhatsApp';
      }
    } catch (e) {
      print('Error launching WhatsApp: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Some error occurred. Please try again!'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
          backgroundColor: const Color.fromRGBO(62, 13, 59, 1),
          leading: IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  PageTransition(
                      type: PageTransitionType.fade,
                      child: (DetailedCardPage(
                          customerData: _customerData,
                          onUpdateImageUrls: updateImageUrls))),
                );
              },
              icon: Icon(Icons.arrow_back)),
          title: Text('${_customerData["organisationName"]}'),
          actions: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.notifications_none),
            ),
          ]),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          WillPopScope(
            onWillPop: () async {
              Navigator.push(
                context,
                PageTransition(
                    type: PageTransitionType.fade,
                    child: (DetailedCardPage(
                        customerData: _customerData,
                        onUpdateImageUrls: updateImageUrls))),
              );
              return false;
            },
            child: Container(
              margin: EdgeInsets.only(left: 10, right: 10, top: 10),
              height: MediaQuery.of(context).size.height * 0.133,
              child: Card(
                  elevation: 0,
                  color: Color.fromARGB(228, 244, 242, 242),
                  child: Container(
                    margin: EdgeInsets.all(10),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(translation(context).billAmount),
                            Text(translation(context).description),
                          ],
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.currency_rupee,
                                    size: 18,
                                    color: Color.fromRGBO(62, 13, 59, 1),
                                  ),
                                  Text('${_customerOrganization["amount"]}',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                        color: Color.fromRGBO(62, 13, 59, 1),
                                      ))
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    _customerOrganization["message"],
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500),
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 10),
                          child: Row(
                            children: [
                              Container(
                                child: Icon(
                                  color: Color.fromRGBO(62, 13, 59, 1),
                                  Icons.calendar_month_outlined,
                                  size: 18,
                                ),
                              ),
                              Container(
                                  margin: EdgeInsets.only(left: 8),
                                  child: Text(
                                    DateFormat('dd-MM-yyyy').format(
                                        DateTime.parse(_customerOrganization[
                                            "createdAt"])),
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: Color.fromRGBO(62, 13, 59, 1),
                                    ),
                                  ))
                            ],
                          ),
                        ),
                      ],
                    ),
                  )),
            ),
          ),
          Container(
              height: MediaQuery.of(context).size.height * 0.5,
              width: MediaQuery.of(context).size.width * 0.8,
              child: imageUrls1.isEmpty
                  ? Center(
                      child: Text(
                        translation(context).noImageFound,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 30),
                      ),
                    )
                  : imageUrls1.length == 1
                      ? Center(
                          child: PinchZoom(
                            resetDuration: Duration(milliseconds: 100),
                            maxScale: 2.5,
                            child: CachedNetworkImage(
                              imageUrl: imageUrls1[0],
                              errorWidget: (context, url, error) {
                                return Center(
                                  child: Text(
                                    translation(context).noImageFound,
                                    style: TextStyle(fontSize: 30),
                                  ),
                                );
                              },
                              placeholder: (context, url) =>
                                  Center(child: CircularProgressIndicator()),
                              fit: BoxFit.cover,
                            ),
                          ),
                        )
                      : GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 8.0,
                            mainAxisSpacing: 8.0,
                          ),
                          itemCount: imageUrls1.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                if (imageUrls1[index] != null) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ImagePage(
                                          imageUrl: imageUrls1[index]),
                                    ),
                                  );
                                } else {
                                  print("Image URL at index $index is null!");
                                }
                              },
                              child: CachedNetworkImage(
                                imageUrl: imageUrls1[index],
                                errorWidget: (context, url, error) {
                                  return Center(
                                    child: Text(
                                      translation(context).unableToLoadImage,
                                      style: TextStyle(fontSize: 24),
                                    ),
                                  );
                                },
                                placeholder: (context, url) => Center(
                                  child: CircularProgressIndicator(),
                                ),
                                fit: BoxFit.cover,
                              ),
                            );
                          },
                        )),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                height: MediaQuery.of(context).size.height * 0.08,
                width: MediaQuery.of(context).size.width * 0.5,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromRGBO(62, 13, 59, 1),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      )),
                  onPressed: () {
                    _launchSms();
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 5),
                        child: Icon(Icons.message),
                      ),
                      Text(translation(context).sendMessage),
                    ],
                  ),
                ),
              ),
              Container(
                  height: MediaQuery.of(context).size.height * 0.08,
                  width: MediaQuery.of(context).size.width * 0.5,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromRGBO(37, 211, 102, 1),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        )),
                    onPressed: () {
                      launchWhatsapp();
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 5),
                          child: FaIcon(FontAwesomeIcons.whatsapp),
                        ),
                        Text(translation(context).whatsapp),
                      ],
                    ),
                  ))
            ],
          ),
        ],
      ),
    );
  }
}
