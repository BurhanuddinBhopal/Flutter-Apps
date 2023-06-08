// @dart=2.9
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hta/Account%20Pages/forgot_password_page.dart';
import 'package:hta/Drawer%20Pages/aboutUs_page.dart';
import 'package:hta/Drawer%20Pages/accountSetting_page.dart';
import 'package:hta/Drawer%20Pages/contactUs_page.dart';
import 'package:hta/Drawer%20Pages/privacyPolicy_page.dart';
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

  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  runApp(MaterialApp(home: mobileNumber == null ? LoginPage() : HomePage()));
}

class MyApp extends StatelessWidget {
  var _customerData;
  var transactionData1;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData().copyWith(
            colorScheme: ThemeData().colorScheme.copyWith(
                  primary: Color.fromRGBO(62, 13, 59, 1),
                )),
        debugShowCheckedModeBanner: false,
        routes: {
          MyRoutes.homeRoute: (context) => HomePage(),
          MyRoutes.loginRoute: (context) => LoginPage(),
          // MyRoutes.detailedcardRoute: (context) => DetailedCardPage(),
          MyRoutes.detailedinfoRoute: (context) => DetailedInfoPage(
                customerOrganization: transactionData1,
                customerData: _customerData,
              ),
          MyRoutes.raisebillRoute: (context) => RaiseBillPage(
                customerData: _customerData,
              ),
          MyRoutes.paybillRoute: (context) => PayBillPage(
                customerData: _customerData,
              ),
          MyRoutes.accountSettingsRoute: (context) => AccountSettings(),
          MyRoutes.contactUsRoute: (context) => ContactUs(),
          MyRoutes.aboutUsRoute: (context) => AboutUs(),
          MyRoutes.privacyPolicyRoute: (context) => PrivacyPolicy(),
          MyRoutes.forgotPasswordRoute: (context) => ForgotPassword()
        });
  }
}
