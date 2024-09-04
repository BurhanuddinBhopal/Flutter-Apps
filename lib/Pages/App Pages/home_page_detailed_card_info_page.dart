// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hta/google%20anaylitics/anaylitics_services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
import 'package:pinch_zoom/pinch_zoom.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:hta/Pages/App%20Pages/home_page_card_info_page.dart';
import 'package:hta/Pages/App%20Pages/image_page.dart';
import 'package:hta/language/language_constant.dart';

import '../../constant.dart';

class DetailedInfoPage extends StatefulWidget {
  final customerOrganization;
  final customerData;
  final double? pendingAmount;
  final List<String>? imageUrls;
  // final Function(List<String>)? onUpdateImageUrls;

  const DetailedInfoPage({
    required this.customerOrganization,
    required this.customerData,
    this.imageUrls,
    // this.onUpdateImageUrls,
    this.pendingAmount,
  });

  @override
  State<DetailedInfoPage> createState() => _DetailedInfoPageState();
}

class _DetailedInfoPageState extends State<DetailedInfoPage> {
  final AnalyticsService _analyticsService = AnalyticsService();
  var _customerData = {};
  var _customerOrganization = {};
  List<String>? image;

  var name;
  double? billAmount; // Use double for better control
  double? dueAmount;
  double? _pendingAmount;
  var mobileNumber;
  String? countryCode;

  bool isLoading = false;
  List<String> imageUrls = [];
  List<String> imageUrls1 = [];

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    transactionData();
    _getCountryCode();
    _analyticsService.trackPage('DetailedInfoPage');
    setState(() {
      _customerOrganization = widget.customerOrganization;
      _customerData = widget.customerData;

      // Ensure proper conversion and handling of amounts
      billAmount = getFormattedDueAmount(_customerOrganization["amount"]);
      dueAmount = getFormattedDueAmount(_customerOrganization["dueAmount"]);
      _pendingAmount = widget.pendingAmount ?? 0.0;
      mobileNumber = _customerData['mobileNumber'];
      name = _customerData["organisationName"];

      // Handle image URLs
      image = [_customerOrganization['picture']];
      if (image is List<String>) {
        imageUrls.addAll(image as List<String>);
        if (imageUrls.isNotEmpty) {
          imageUrls1.addAll(imageUrls[0].split(','));
        }
      } else if (image is String) {
        imageUrls = (image as String).split(',');
      }
    });
  }

  Future<void> _getCountryCode() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    setState(() {
      countryCode = sharedPreferences.getString('country') ?? 'IN';
    });
  }

  Future<void> transactionData() async {
    setState(() {
      isLoading = true;
    });

    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    var token = sharedPreferences.getString('token');
    final url = Uri.parse(
        '${AppConstants.backendUrl}/api/transactions/getAllTransaction');
    final body = {"customer": _customerData["_id"]};
    final header = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    try {
      final response =
          await http.post(url, headers: header, body: jsonEncode(body));

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        List<dynamic> transactions = responseData['allTransaction'];
        // Handle transactions if necessary
      } else {
        print("Failed to load data. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  double? getFormattedDueAmount(dynamic amount) {
    if (amount == null) {
      return null;
    }
    // Ensure type safety
    return (amount is int) ? amount.toDouble() : amount as double?;
  }

  String formatBillAmount(double? amount) {
    if (amount == null) return '';
    // Use toStringAsFixed to handle decimal points properly
    return amount % 1 == 0
        ? amount.toStringAsFixed(0)
        : amount.toStringAsFixed(2);
  }

  String formatDueAmount(double? amount) {
    if (amount == null) return '';
    double roundedAmount = double.parse(amount.toStringAsFixed(2));
    return roundedAmount % 1 == 0
        ? roundedAmount.toStringAsFixed(0)
        : roundedAmount.toStringAsFixed(2);
  }

  // String getCurrencySymbol() {
  //   if (countryCode == 'IN') {
  //     return '₹';
  //   } else if (countryCode == 'KW') {
  //     return 'KD';
  //   } else {
  //     return '';
  //   }
  // }

  void _launchSms() async {
    try {
      String imageText = imageUrls1.join(', ');
      // String currencySymbol = getCurrencySymbol();
      String uri =
          'sms:$mobileNumber?body=${Uri.encodeComponent("Hi $name, your bill has been raised for an amount of ${formatBillAmount(billAmount)} and your pending balance is ${formatBillAmount(_pendingAmount)}.\nImages: $imageText ")}';

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
      // String currencySymbol = getCurrencySymbol();
      String message =
          'Hi $name, your bill has been raised for an amount of ${formatBillAmount(billAmount)} and your pending balance is ${formatBillAmount(_pendingAmount)}.\nImages: $imageText';
      String uri =
          'https://wa.me/$mobileNumber?text=${Uri.encodeComponent(message)}';

      if (await launchUrl(Uri.parse(uri))) {
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
              Navigator.of(context).pop();
            },
            icon: Icon(Icons.arrow_back)),
        centerTitle: true,
        title: Text(
          '${_customerData["organisationName"]}',
          textAlign: TextAlign.center,
        ),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          WillPopScope(
            onWillPop: () async {
              Navigator.of(context).pop();
              return false;
            },
            child: Container(
              margin: EdgeInsets.only(left: 10, right: 10, top: 10),
              height: MediaQuery.of(context).size.height * 0.16,
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
                          Text(
                            translation(context)!.billAmount,
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            translation(context)!.remainingBalance,
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                countryCode == 'KW'
                                    ? Container(
                                        width: 20,
                                        margin: EdgeInsets.only(right: 5),
                                        child: Image.asset(
                                          'assets/images/kwd.png',
                                          color: Color.fromRGBO(62, 13, 59, 1),
                                        ),
                                      )
                                    : const Icon(
                                        Icons.currency_rupee_sharp,
                                        size: 18,
                                        color: Color.fromRGBO(62, 13, 59, 1),
                                      ),
                                Container(
                                  child: Text(
                                    formatBillAmount(getFormattedDueAmount(
                                        _customerOrganization["amount"])),
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                      color: Color.fromRGBO(62, 13, 59, 1),
                                    ),
                                  ),
                                )
                              ],
                            ),
                            Row(
                              children: [
                                dueAmount != null
                                    ? countryCode == 'KW'
                                        ? Container(
                                            width: 20,
                                            margin: EdgeInsets.only(right: 5),
                                            child: Image.asset(
                                              'assets/images/kwd.png',
                                              color:
                                                  Color.fromRGBO(62, 13, 59, 1),
                                            ),
                                          )
                                        : const Icon(
                                            Icons.currency_rupee_sharp,
                                            size: 18,
                                            color:
                                                Color.fromRGBO(62, 13, 59, 1),
                                          )
                                    : Container(),
                                Container(
                                  child: Text(
                                    formatDueAmount(dueAmount),
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                      color: Color.fromRGBO(62, 13, 59, 1),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
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
                            Row(
                              children: [
                                Text(
                                  translation(context)!.description,
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              _customerOrganization["message"],
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Color.fromRGBO(62, 13, 59, 1)),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
              height: MediaQuery.of(context).size.height * 0.5,
              width: MediaQuery.of(context).size.width * 0.8,
              child: imageUrls1.isEmpty
                  ? Center(
                      child: Text(
                        translation(context)!.noImageFound,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 30),
                      ),
                    )
                  : imageUrls1.length == 1
                      ? Center(
                          child: PinchZoom(
                            maxScale: 2.5,
                            child: CachedNetworkImage(
                              imageUrl: imageUrls1[0],
                              errorWidget: (context, url, error) {
                                return Center(
                                  child: Text(
                                    translation(context)!.noImageFound,
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
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ImagePage(imageUrl: imageUrls1[index]),
                                  ),
                                );
                              },
                              child: CachedNetworkImage(
                                imageUrl: imageUrls1[index],
                                errorWidget: (context, url, error) {
                                  return Center(
                                    child: Text(
                                      translation(context)!.unableToLoadImage,
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
              SizedBox(
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
                      Text(translation(context)!.sendMessage),
                    ],
                  ),
                ),
              ),
              SizedBox(
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
                        Text(translation(context)!.whatsapp),
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
