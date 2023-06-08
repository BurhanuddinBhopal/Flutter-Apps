// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailedInfoPage extends StatefulWidget {
  final customerOrganization;
  final customerData;

  const DetailedInfoPage(
      {required this.customerOrganization, required this.customerData});

  @override
  State<DetailedInfoPage> createState() => _DetailedInfoPageState();
}

class _DetailedInfoPageState extends State<DetailedInfoPage> {
  var _customerData = {};
  var _customerOrganization = {};
  var image;
  var name;
  var billAmount;
  var pendingAmount;
  var mobileNumber;

  bool isLoading = false;

  @override
  void initState() {
    transactionData();
    setState(() {
      _customerOrganization = widget.customerOrganization;
      _customerData = widget.customerData;
      image = _customerOrganization['picture'];
      mobileNumber = _customerData['mobileNumber'];
      name = _customerData["organisationName"];
      billAmount = _customerOrganization["amount"];
      pendingAmount = _customerData["pendingAmount"];
    });

    print(image);

    print(_customerOrganization);
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
    String uri =
        'sms:$mobileNumber?body=${Uri.encodeComponent("Hi $name your bill has been raised for amount $billAmount and your pending balance is $pendingAmount $image")}';
    try {
      if (await launchUrl(Uri.parse(uri))) {
        await launchUrl(Uri.parse(uri));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Some error occurred. Please try again!'),
        ),
      );
    }
  }

  void launchWhatsapp() async {
    String uri =
        'https://wa.me/number:$mobileNumber:/?text=${Uri.parse('Hi $name your bill has been raised for amount $billAmount and your pending balance is $pendingAmount ')}';
    if (await launch(uri)) {
      await launch(uri);
    } else {
      throw 'Could not launch $uri';
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return Scaffold(
      appBar: AppBar(
          backgroundColor: const Color.fromRGBO(62, 13, 59, 1),
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
          Container(
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
                          Text('Bill amount'),
                          Text('Description'),
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
                                      DateTime.parse(
                                          _customerOrganization["createdAt"])),
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
          Container(
              height: MediaQuery.of(context).size.height * 0.63,
              width: MediaQuery.of(context).size.width * 1,
              child: image.isEmpty
                  ? Container(
                      margin: EdgeInsets.only(top: 90),
                      child: Text(
                        'No Image Found',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 30),
                      ),
                    )
                  : CachedNetworkImage(
                      imageUrl: _customerOrganization["picture"],
                      errorWidget: (context, url, error) => Center(
                          child: Text('Unable to load image!!',
                              style: TextStyle(fontSize: 24))),
                      placeholder: (context, url) => Container(
                        child: Container(
                          margin: EdgeInsets.only(top: 90),
                          child: Text(
                            'Please wait for a while',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 30),
                          ),
                        ),
                      ),
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
                      Text('Send Message'),
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
                          child: Icon(Icons.whatsapp),
                        ),
                        Text('Whatsapp'),
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
