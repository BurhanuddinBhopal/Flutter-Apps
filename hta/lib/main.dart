// @dart=2.9
import 'package:flutter/material.dart';
import 'package:hta/card_info_page_raise_bill_button_page.dart';

import 'package:hta/home_page.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../utils/routes.dart';
import 'card_info_page_pay_bill_button_page.dart';
import 'home_page_detailed_card_info_page.dart';
import 'login_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  var mobileNumber = sharedPreferences.getString('mobileNumber');

  runApp(MaterialApp(home: mobileNumber == null ? LoginPage() : HomePage()));
}

class MyApp extends StatelessWidget {
  var _customerData;
  var transactionData1;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: Color.fromRGBO(62, 13, 59, 1),
        )),
        routes: {
          MyRoutes.homeRoute: (context) => HomePage(),
          MyRoutes.loginRoute: (context) => LoginPage(),
          // MyRoutes.detailedcardRoute: (context) => DetailedCardPage(),
          MyRoutes.detailedinfoRoute: (context) => DetailedInfoPage(
                customerOrganization: transactionData1,
                customerId: _customerData,
              ),
          MyRoutes.raisebillRoute: (context) => RaiseBillPage(
                customerId: _customerData,
              ),
          MyRoutes.paybillRoute: (context) => PayBillPage(
                customerId: _customerData,
              ),
        });
  }
}
