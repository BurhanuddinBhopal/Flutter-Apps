import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:hta/Pages/App%20Pages/card_info_page_raise_bill_button_page.dart';
import 'package:hta/Pages/App%20Pages/home_page.dart';
import 'package:hta/Pages/App%20Pages/report_page.dart';
import 'package:hta/Pages/App%20Pages/today_transaction_page.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../../models/Transaction_model.dart';
import '../../utils/routes.dart';
import '../../widgets/provider.dart';

import 'Pages/Account Pages/forgot_password_page.dart';
import 'Pages/App Pages/bottom_navigation_page.dart';
import 'Pages/App Pages/card_info_page_pay_bill_button_page.dart';
import 'Pages/App Pages/home_page_detailed_card_info_page.dart';
import 'Pages/App Pages/login_page.dart';
import 'Pages/Drawer Pages/aboutUs_page.dart';
import 'Pages/Drawer Pages/accountSetting_page.dart';
import 'Pages/Drawer Pages/contactUs_page.dart';
import 'Pages/Drawer Pages/privacyPolicy_page.dart';

import 'package:provider/provider.dart';

class Person implements Comparable<Person> {
  final String name, surname, organisationName;

  const Person(this.name, this.surname, this.organisationName);

  @override
  int compareTo(Person other) => name.compareTo(other.name);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  var mobileNumber = sharedPreferences.getString('mobileNumber');

  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  runApp(ChangeNotifierProvider(
    create: (context) => CustomerDataProvider(),
    child: MaterialApp(
        home: mobileNumber == null ? LoginPage() : BottomNavigationPage()),
  ));
}

class MyApp extends StatefulWidget {
  final String? mobileNumber;
  final List<Customer> customerData;

  const MyApp({this.mobileNumber, required this.customerData});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  var _customerData;
  var _pendingAmount;

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
                pendingAmount: _pendingAmount,
              ),
          MyRoutes.paybillRoute: (context) => PayBillPage(
                customerData: _customerData,
                pendingAmount: _pendingAmount,
              ),
          MyRoutes.accountSettingsRoute: (context) => AccountSettings(),
          MyRoutes.contactUsRoute: (context) => ContactUs(),
          MyRoutes.aboutUsRoute: (context) => AboutUs(),
          MyRoutes.privacyPolicyRoute: (context) => PrivacyPolicy(),
          MyRoutes.forgotPasswordRoute: (context) => ForgotPassword(),
          MyRoutes.reportPageRoute: (context) => ReportPage(),
          MyRoutes.todayPageRoute: (context) => TodayPage(
                customerData: _customerData,
                // fullCustomerData: _customerData,
              ),
        });
  }
}
