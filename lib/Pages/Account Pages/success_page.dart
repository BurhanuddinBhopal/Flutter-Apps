import 'package:flutter/material.dart';
import 'package:hta/Pages/Account%20Pages/login_page.dart';
import 'package:url_launcher/url_launcher.dart';

class SuccessPage extends StatelessWidget {
  const SuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(20.0),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/success-green-check-mark-icon.webp',
              width: MediaQuery.of(context).size.width * 0.5,
            ),
            const SizedBox(height: 50.0),
            const Text(
              'Congratulations!',
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10.0),
            const Text(
              'Your account has been successfully created.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18.0),
            ),
            const SizedBox(height: 40.0),
            const Text(
              'Now please do Sign In from the button below',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            // SizedBox(height: 20.0),
            // Text(
            //   'For faster service, please contact us on Whatsapp',
            //   style: TextStyle(fontSize: 16.0),
            // ),
            const SizedBox(height: 40.0),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40.0),
                        ),
                        minimumSize: const Size(150, 37),
                      ),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoginPage()));
                      },
                      child: const Text('Sign In'),
                    ),
                  ),
                  // SizedBox(height: 20.0),
                  // ElevatedButton(
                  //     style: ElevatedButton.styleFrom(
                  //       backgroundColor: Color.fromRGBO(37, 211, 102, 1),
                  //       shape: RoundedRectangleBorder(
                  //         borderRadius: BorderRadius.circular(40.0),
                  //       ),
                  //     ),
                  //     onPressed: (() {
                  //       _launchWhatsApp();
                  //     }),
                  //     child: Container(
                  //       margin: EdgeInsets.symmetric(horizontal: 5),
                  //       child: Row(
                  //         mainAxisAlignment: MainAxisAlignment.spaceAround,
                  //         children: [
                  //           FaIcon(
                  //             FontAwesomeIcons.whatsapp,
                  //             size: 19,
                  //           ),
                  //           Container(
                  //               margin: EdgeInsets.symmetric(horizontal: 5),
                  //               child: Text(
                  //                   translation(context)!.contactUsWhatsapp)),
                  //         ],
                  //       ),
                  //     )),
                ],
              ),
            ),
            const SizedBox(height: 20.0),
          ],
        ),
      ),
    );
  }

  void _launchWhatsApp() async {
    String uri =
        'https://wa.me/number:7869820020:/?text=${Uri.parse('Hello, How much time will it take for you to review my account?')}';
    if (await launch(uri)) {
      await launch(uri);
    } else {
      throw 'Could not launch $uri';
    }
  }
}
