import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../language/language_constant.dart';

class ContactUs extends StatelessWidget {
  void launchWhatsapp() async {
    String uri = 'https://wa.me/number:7869820020:/?text=${Uri.parse('Hello')}';
    if (await launch(uri)) {
      await launch(uri);
    } else {
      throw 'Could not launch $uri';
    }
  }

  _sendingMails() async {
    const url = 'mailto:hatimtechnologies@gmail.com';
    if (await launch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
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
        leading: IconButton(
            onPressed: (() {
              Navigator.pop(context);
            }),
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
            )),
        backgroundColor: Color.fromARGB(221, 238, 234, 234),
        centerTitle: true,
        title: Text(
          translation(context)!.contactUs,
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width * 1,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              margin: EdgeInsets.only(top: 40),
              child: Image.asset("assets/images/TransperantLogo.png",
                  width: MediaQuery.of(context).size.width * 0.45),
            ),
            Container(
              margin: EdgeInsets.only(top: 70, bottom: 20),
              // width: MediaQuery.of(context).size.width * 0.95,
              child: Text(
                translation(context)!.contactUsPara,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                ),
              ),
            ),
            Text(
              translation(context)!.contactUsWorkingTime,
              style: TextStyle(fontSize: 16),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  margin: EdgeInsets.only(top: 40, bottom: 10),
                  width: MediaQuery.of(context).size.width * 0.5,
                  height: MediaQuery.of(context).size.height * 0.05,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromRGBO(37, 211, 102, 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40.0),
                        ),
                      ),
                      onPressed: (() {
                        launchWhatsapp();
                      }),
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            FaIcon(
                              FontAwesomeIcons.whatsapp,
                              size: 19,
                            ),
                            Text(translation(context)!.contactUsWhatsapp),
                          ],
                        ),
                      )),
                ),
                Container(
                    margin: EdgeInsets.only(bottom: 10, top: 10),
                    child: Text(translation(context)!.or)),
                Container(
                  // width: MediaQuery.of(context).size.width * 1,
                  margin: EdgeInsets.symmetric(horizontal: 0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        translation(context)!.emailUs,
                        style: TextStyle(fontSize: 14),
                      ),
                      GestureDetector(
                        onTap: (() {
                          _sendingMails();
                        }),
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 5),
                          child: Text(
                            'hatimtechnologies.in',
                            style: TextStyle(
                                color: Color.fromRGBO(62, 13, 59, 1),
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
