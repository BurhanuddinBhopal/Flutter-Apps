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

class AppDrawer extends StatefulWidget {
  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  var name;

  @override
  void initState() {
    getDrawerData();
    super.initState();
  }

  String finalNumber = "";
  String finalName = '';
  String finalLastname = '';

  Future getDrawerData() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    var mobileNumber = sharedPreferences.getString('mobileNumber');

    var name = sharedPreferences.getString('name');
    var lastName = sharedPreferences.getString('lastName');

    setState(() {
      finalNumber = mobileNumber!;
      finalName = name!;
      finalLastname = lastName!;
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
                              translation(context).welcometoHTA,
                              // 'Welcome to HTA',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w500),
                            ),
                            SizedBox(height: 10),
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
                              MaterialStateProperty.all(Colors.transparent),
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
                                      translation(context).accountSettings,
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
                              MaterialStateProperty.all(Colors.transparent),
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
                                      translation(context).contactUs,
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
                  Container(
                    child: TextButton(
                        style: ButtonStyle(
                          overlayColor:
                              MaterialStateProperty.all(Colors.transparent),
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
                                    Icons.info,
                                    size: 25,
                                    color: Colors.black45,
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(left: 18),
                                    child: Text(
                                      translation(context).aboutUs,
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
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.01,
                  ),
                  Container(
                    child: TextButton(
                        style: ButtonStyle(
                          overlayColor:
                              MaterialStateProperty.all(Colors.transparent),
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
                                    Icons.lock,
                                    size: 26,
                                    color: Colors.black45,
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(left: 18),
                                    child: Text(
                                      translation(context).privacyPolicy,
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
                ],
              ),
              Column(
                children: [
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 45, vertical: 60),
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
                      child: Text(
                        translation(context).logOut,
                        // 'LOG OUT'
                      ),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black26),
                    ),
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
