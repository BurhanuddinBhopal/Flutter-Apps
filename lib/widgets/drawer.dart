// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors, duplicate_ignore, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';

import 'package:hta/language/language_constant.dart';

import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Pages/Account Pages/login_page.dart';
import '../Pages/Drawer Pages/aboutUs_page.dart';
import '../Pages/Drawer Pages/accountSetting_page.dart';
import '../Pages/Drawer Pages/contactUs_page.dart';
import '../Pages/Drawer Pages/privacyPolicy_page.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppDrawer extends StatefulWidget {
  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  var name;

  @override
  void initState() {
    getDrawerData();
    fetchVersion();
    super.initState();
  }

  String finalNumber = "";
  String finalName = '';
  String finalLastname = '';
  String finalOrganisationName = '';
  String? country;
  String version = "";

  Future<void> fetchVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        version = packageInfo.version;
      });
    } catch (e) {
      print('Failed to get app version: $e');
    }
  }

  Future getDrawerData() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    var mobileNumber = sharedPreferences.getString('mobileNumber');

    var name = sharedPreferences.getString('name');
    var lastName = sharedPreferences.getString('lastName');
    var storedCountry = sharedPreferences.getString('country');

    setState(() {
      finalNumber = mobileNumber!;
      finalName = name!;
      finalLastname = lastName!;
      country = storedCountry;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Material(
        color: Color.fromARGB(221, 255, 255, 255),
        child: Form(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Container(
                    margin: EdgeInsets.only(right: 250, top: 40),
                    child: IconButton(
                        onPressed: (() {
                          Navigator.pop(context);
                        }),
                        icon: Icon(Icons.arrow_back)),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.02,
                  ),
                  Row(
                    children: [
                      Container(
                        margin: EdgeInsets.only(left: 12),
                        child: Image.asset('assets/profile_img/profile_pic.jpg',
                            width: MediaQuery.of(context).size.width * 0.15),
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              translation(context)!.welcometoHTA,
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w500),
                            ),
                            SizedBox(height: 10),
                            Row(
                              children: [
                                Text(
                                  finalName,
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black45),
                                ),
                                Text(
                                  finalLastname,
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black45),
                                ),
                              ],
                            ),
                            Text(
                              finalNumber,
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black45),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.04,
                  ),
                  Divider(
                    thickness: 1,
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.01,
                  ),
                  // Container(
                  //   child: TextButton(
                  //       style: ButtonStyle(
                  //         overlayColor:
                  //             MaterialStateProperty.all(Colors.transparent),
                  //       ),
                  //       onPressed: (() {
                  //         Navigator.push(
                  //             context,
                  //             MaterialPageRoute(
                  //                 builder: (context) => ReportPage()));
                  //       }),
                  //       child: Container(
                  //         margin: EdgeInsets.only(left: 5),
                  //         child: Row(
                  //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //           children: [
                  //             Row(
                  //               // mainAxisAlignment: MainAxisAlignment.start,
                  //               children: [
                  //                 Icon(
                  //                   Icons.report,
                  //                   size: 28,
                  //                   color: Colors.black45,
                  //                 ),
                  //                 Container(
                  //                   margin: EdgeInsets.only(left: 18),
                  //                   child: Text(
                  //                     'Report',
                  //                     style: TextStyle(
                  //                         fontSize: 20,
                  //                         fontWeight: FontWeight.w400,
                  //                         color: Colors.black54),
                  //                   ),
                  //                 ),
                  //               ],
                  //             ),
                  //             Row(
                  //               children: [
                  //                 Container(
                  //                   margin: EdgeInsets.only(right: 5),
                  //                   child: Icon(
                  //                     Icons.arrow_forward_ios,
                  //                     size: 25,
                  //                     color: Colors.black45,
                  //                   ),
                  //                 ),
                  //               ],
                  //             ),
                  //           ],
                  //         ),
                  //       )),
                  // ),
                  // SizedBox(
                  //   height: MediaQuery.of(context).size.height * 0.02,
                  // ),
                  // Divider(
                  //   thickness: 1,
                  //   indent: 60,
                  // ),
                  // SizedBox(
                  //   height: MediaQuery.of(context).size.height * 0.01,
                  // ),

                  Container(
                    child: TextButton(
                        style: ButtonStyle(
                          overlayColor:
                              WidgetStateProperty.all(Colors.transparent),
                        ),
                        onPressed: (() {
                          Navigator.push(
                            context,
                            PageTransition(
                                type: PageTransitionType.fade,
                                child: AboutUs()),
                          );
                        }),
                        child: Container(
                          margin: EdgeInsets.only(left: 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                // mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.person_pin_sharp,
                                    size: 25,
                                    color: Colors.black45,
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(left: 18),
                                    child: Text(
                                      translation(context)!.userMode,
                                      // 'About Us',
                                      style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black54),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Container(
                                    margin: EdgeInsets.only(right: 5),
                                    child: Icon(
                                      Icons.arrow_forward_ios,
                                      size: 23,
                                      color: Colors.black45,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.01,
                  ),
                  Divider(
                    thickness: 1,
                    indent: 60,
                  ),
                  Container(
                    child: TextButton(
                        style: ButtonStyle(
                          overlayColor:
                              WidgetStateProperty.all(Colors.transparent),
                        ),
                        onPressed: (() {
                          Navigator.push(
                            context,
                            PageTransition(
                                type: PageTransitionType.fade,
                                child: PrivacyPolicy()),
                          );
                        }),
                        child: Container(
                          margin: EdgeInsets.only(left: 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                // mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.app_settings_alt,
                                    size: 26,
                                    color: Colors.black45,
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(left: 18),
                                    child: Text(
                                      translation(context)!.applicationMode,
                                      // 'Privacy Policy',
                                      style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black54),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Container(
                                    margin: EdgeInsets.only(right: 5),
                                    child: Icon(
                                      Icons.arrow_forward_ios,
                                      size: 23,
                                      color: Colors.black45,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.01,
                  ),
                  Divider(
                    thickness: 1,
                    indent: 60,
                  ),
                  Container(
                    child: TextButton(
                        style: ButtonStyle(
                          overlayColor:
                              WidgetStateProperty.all(Colors.transparent),
                        ),
                        onPressed: (() {
                          Navigator.push(
                            context,
                            PageTransition(
                                type: PageTransitionType.fade,
                                child: AccountSettings()),
                          );
                        }),
                        child: Container(
                          margin: EdgeInsets.only(left: 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                // mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.settings,
                                    size: 25,
                                    color: Colors.black45,
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(left: 18),
                                    child: Text(
                                      translation(context)!.accountSettings,
                                      // 'Account Settings',
                                      style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black54),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Container(
                                    margin: EdgeInsets.only(right: 5),
                                    child: Icon(
                                      Icons.arrow_forward_ios,
                                      size: 23,
                                      color: Colors.black45,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.01,
                  ),
                  Divider(
                    thickness: 1,
                    indent: 60,
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.01,
                  ),
                  Container(
                    child: TextButton(
                        style: ButtonStyle(
                          overlayColor:
                              WidgetStateProperty.all(Colors.transparent),
                        ),
                        onPressed: (() {
                          Navigator.push(
                            context,
                            PageTransition(
                                type: PageTransitionType.fade,
                                child: ContactUs()),
                          );
                        }),
                        child: Container(
                          margin: EdgeInsets.only(left: 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                // mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.message_outlined,
                                    size: 25,
                                    color: Colors.black45,
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(left: 18),
                                    child: Text(
                                      translation(context)!.contactUs,
                                      // 'Contact Us',
                                      style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black54),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Container(
                                    margin: EdgeInsets.only(right: 5),
                                    child: Icon(
                                      Icons.arrow_forward_ios,
                                      size: 23,
                                      color: Colors.black45,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.01,
                  ),
                  Divider(
                    indent: 60,
                    thickness: 1,
                  ),

                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.01,
                  ),
                ],
              ),
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 30),
                        child: Image.asset(
                          (country == 'IN' || country == 'KW')
                              ? (country == 'IN'
                                  ? 'assets/images/Flag_of_India.png'
                                  : 'assets/images/Flag_of_Kuwait.png')
                              : 'assets/images/Flag_of_India.png', // Default to India
                          width: MediaQuery.of(context).size.width * 0.2,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 45, vertical: 10),
                    height: MediaQuery.of(context).size.height * 0.055,
                    width: MediaQuery.of(context).size.width * 0.55,
                    child: ElevatedButton(
                      onPressed: () async {
                        SharedPreferences sharedPreferences =
                            await SharedPreferences.getInstance();
                        sharedPreferences.remove('mobileNumber');

                        Navigator.push(
                          context,
                          PageTransition(
                              type: PageTransitionType.fade,
                              child: LoginPage()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black26),
                      child: Text(
                        translation(context)!.logOut,
                        // 'LOG OUT'
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                          style: ButtonStyle(
                            overlayColor:
                                WidgetStateProperty.all(Colors.transparent),
                          ),
                          onPressed: (() {
                            Navigator.push(
                              context,
                              PageTransition(
                                  type: PageTransitionType.fade,
                                  child: AboutUs()),
                            );
                          }),
                          child: Container(
                            margin: EdgeInsets.only(left: 5),
                            child: Text(
                              translation(context)!.aboutUs,
                              // 'About Us',
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black54),
                            ),
                          )),
                      TextButton(
                          style: ButtonStyle(
                            overlayColor:
                                WidgetStateProperty.all(Colors.transparent),
                          ),
                          onPressed: (() {
                            Navigator.push(
                              context,
                              PageTransition(
                                  type: PageTransitionType.fade,
                                  child: PrivacyPolicy()),
                            );
                          }),
                          child: Container(
                            margin: EdgeInsets.only(left: 5),
                            child: Text(
                              translation(context)!.privacyPolicy,
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black54),
                            ),
                          )),
                      Container(
                        margin: EdgeInsets.only(),
                        child: Text(
                          'version $version',
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w400,
                              color: Colors.black54),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
