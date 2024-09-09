import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hta/Pages/App%20Pages/home_page_card_info_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:hta/Pages/Account%20Pages/change_language_page.dart';
import 'package:hta/Pages/App%20Pages/card_info_page_raise_bill_button_page.dart';
import 'package:hta/Pages/App%20Pages/home_page.dart';
import 'package:hta/Pages/App%20Pages/report_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../models/Transaction_model.dart';
import '../../utils/routes.dart';
import 'Pages/Account Pages/forgot_password_page.dart';
import 'Pages/Account Pages/login_page.dart';
import 'Pages/App Pages/bottom_navigation_page.dart';
import 'Pages/App Pages/card_info_page_pay_bill_button_page.dart';
import 'Pages/App Pages/home_page_detailed_card_info_page.dart';
import 'Pages/App Pages/today_transaction_page.dart';
import 'Pages/Drawer Pages/aboutUs_page.dart';
import 'Pages/Drawer Pages/accountSetting_page.dart';
import 'Pages/Drawer Pages/contactUs_page.dart';
import 'Pages/Drawer Pages/privacyPolicy_page.dart';
import 'language/language_constant.dart';

class Person implements Comparable<Person> {
  final String name, surname, organisationName;

  const Person(this.name, this.surname, this.organisationName);

  @override
  int compareTo(Person other) => name.compareTo(other.name);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();

  String mode = prefs.getString('selectedMode') ?? 'Sales';

  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  runApp(MyApp(
    mode: mode,
    customerData: [],
  ));
}

class MyApp extends StatefulWidget {
  static void setMode(BuildContext context, String mode) {
    final _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    state?.setMode(mode);
  }

  final String mode;
  final String? mobileNumber;
  final List<Customer> customerData;

  const MyApp(
      {super.key,
      this.mobileNumber,
      required this.customerData,
      required this.mode});
  @override
  State<MyApp> createState() => _MyAppState();

  static void setLocale(BuildContext context, Locale newLocale) {
    _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    state?.setLocale(newLocale);
  }
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  String currentMode = 'Sales';

  void setMode(String mode) {
    setState(() {
      currentMode = mode;
    });
  }

  Locale? _locale;

  setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  _changeLanguage(String languageCode) async {
    await setLocale(Locale(languageCode)); // Update the locale directly

    // Show a snackbar to confirm the language change
    ScaffoldMessenger.of(context)
        .removeCurrentSnackBar(); // Remove existing snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Language changed to $languageCode'),
      ),
    );
  }

  var _customerData;
  var _pendingAmount;

  var transactionData1;

  // This widget is the root of your application.

  List<String> imageUrls = [];

  void updateImageUrls(List<String> newImageUrls) {
    // Update the state or perform other actions
    setState(() {
      imageUrls = newImageUrls;
    });
  }

  @override
  void didChangeDependencies() {
    getLocale().then((locale) => {setLocale(locale)});
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      // Use FutureBuilder to perform async operations before building the UI
      future: _getMobileNumber(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // If the Future is still running, return a loading indicator or placeholder
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          // Handle errors
          return Text('Error: ${snapshot.error}');
        } else {
          // If the Future is complete, build the UI based on the result
          final mobileNumber = snapshot.data;
          return MaterialApp(
              home: mobileNumber == null ? LoginPage() : BottomNavigationPage(),
              localizationsDelegates: [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [
                Locale('en', 'US'), // English
                Locale('hi', 'IN'), // Hindi
              ],
              locale: _locale,
              theme: ThemeData(
                useMaterial3: false,
              ).copyWith(
                  colorScheme: ThemeData().colorScheme.copyWith(
                        primary: const Color.fromRGBO(62, 13, 59, 1),
                      )),
              debugShowCheckedModeBanner: false,
              routes: {
                MyRoutes.homeRoute: (context) => HomePage(),
                MyRoutes.loginRoute: (context) => LoginPage(),
                MyRoutes.detailedcardRoute: (context) => DetailedCardPage(
                      customerData: _customerData,
                    ),
                MyRoutes.detailedinfoRoute: (context) => DetailedInfoPage(
                      customerOrganization: transactionData1,
                      customerData: _customerData,
                      imageUrls: imageUrls,
                      // onUpdateImageUrls: updateImageUrls,
                      pendingAmount: _pendingAmount,
                    ),
                MyRoutes.raisebillRoute: (context) => RaiseBillPage(
                      customerData: _customerData,
                      pendingAmount: _pendingAmount,
                      onUpdateImageUrls: updateImageUrls,
                    ),
                MyRoutes.paybillRoute: (context) => PayBillPage(
                      customerData: _customerData,
                      pendingAmount: _pendingAmount,
                      // onUpdateImageUrls: updateImageUrls,
                    ),
                MyRoutes.accountSettingsRoute: (context) => AccountSettings(),
                MyRoutes.contactUsRoute: (context) => ContactUs(),
                MyRoutes.aboutUsRoute: (context) => AboutUs(),
                MyRoutes.privacyPolicyRoute: (context) => PrivacyPolicy(),
                MyRoutes.forgotPasswordRoute: (context) => ForgotPassword(),
                MyRoutes.reportPageRoute: (context) => ReportPage(),
                MyRoutes.changeLanguageRoute: (context) => ChangeLanguage(),
                MyRoutes.todayPageRoute: (context) => TodayPage(),
                MyRoutes.bottomNavigationRoute: (context) =>
                    BottomNavigationPage(),
              });
        }
      },
    );
    // MaterialApp(
    //   home: mobileNumber == null ? LoginPage() : BottomNavigationPage(),
    //     theme: ThemeData().copyWith(
    //         colorScheme: ThemeData().colorScheme.copyWith(
    //               primary: Color.fromRGBO(62, 13, 59, 1),
    //             )),
    //     debugShowCheckedModeBanner: false,
    //     routes: {
    //       MyRoutes.homeRoute: (context) => HomePage(),
    //       MyRoutes.loginRoute: (context) => LoginPage(),
    //       // MyRoutes.detailedcardRoute: (context) => DetailedCardPage(),
    //       MyRoutes.detailedinfoRoute: (context) => DetailedInfoPage(
    //             customerOrganization: transactionData1,
    //             customerData: _customerData,
    //           ),
    //       MyRoutes.raisebillRoute: (context) => RaiseBillPage(
    //             customerData: _customerData,
    //             pendingAmount: _pendingAmount,
    //           ),
    //       MyRoutes.paybillRoute: (context) => PayBillPage(
    //             customerData: _customerData,
    //             pendingAmount: _pendingAmount,
    //           ),
    //       MyRoutes.accountSettingsRoute: (context) => AccountSettings(),
    //       MyRoutes.contactUsRoute: (context) => ContactUs(),
    //       MyRoutes.aboutUsRoute: (context) => AboutUs(),
    //       MyRoutes.privacyPolicyRoute: (context) => PrivacyPolicy(),
    //       MyRoutes.forgotPasswordRoute: (context) => ForgotPassword(),
    //       MyRoutes.reportPageRoute: (context) => ReportPage(),
    //       // MyRoutes.todayPageRoute: (context) => TodayPage(
    //       //       customerData: _customerData,
    //       //       // fullCustomerData: _customerData,
    //       //     ),
    //     });
  }

  Future<String?> _getMobileNumber() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString('mobileNumber');
  }
}
