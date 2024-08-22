import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../language/language_constant.dart';

class ContactUs extends StatelessWidget {
  const ContactUs({super.key});

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
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
            )),
        backgroundColor: const Color.fromARGB(221, 238, 234, 234),
        centerTitle: true,
        title: Text(
          translation(context)!.contactUs,
          style: const TextStyle(color: Colors.black),
        ),
      ),
      body: SizedBox(
        width: MediaQuery.of(context).size.width * 1,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 40),
              child: Image.asset("assets/images/TransperantLogo.png",
                  width: MediaQuery.of(context).size.width * 0.45),
            ),
            Container(
              margin: const EdgeInsets.only(top: 70, bottom: 20),
              // width: MediaQuery.of(context).size.width * 0.95,
              child: Text(
                translation(context)!.contactUsPara,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                ),
              ),
            ),
            Text(
              translation(context)!.contactUsWorkingTime,
              style: const TextStyle(fontSize: 16),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 40, bottom: 10),
                  width: MediaQuery.of(context).size.width * 0.5,
                  height: MediaQuery.of(context).size.height * 0.05,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(37, 211, 102, 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40.0),
                        ),
                      ),
                      onPressed: (() {
                        launchWhatsapp();
                      }),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            const FaIcon(
                              FontAwesomeIcons.whatsapp,
                              size: 19,
                            ),
                            Text(translation(context)!.contactUsWhatsapp),
                          ],
                        ),
                      )),
                ),
                Container(
                    margin: const EdgeInsets.only(bottom: 10, top: 10),
                    child: Text(translation(context)!.or)),
                Container(
                  // width: MediaQuery.of(context).size.width * 1,
                  margin: const EdgeInsets.symmetric(horizontal: 0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        translation(context)!.emailUs,
                        style: const TextStyle(fontSize: 14),
                      ),
                      GestureDetector(
                        onTap: (() {
                          _sendingMails();
                        }),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 5),
                          child: const Text(
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
