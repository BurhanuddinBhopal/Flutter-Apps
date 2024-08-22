import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hta/widgets/link_button.dart';

import '../../language/language_constant.dart';

class PrivacyPolicy extends StatelessWidget {
  const PrivacyPolicy({super.key});

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
          translation(context)!.privacyPolicy,
          style: const TextStyle(color: Colors.black),
        ),
      ),
      body: Material(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 40),
                  child: Image.asset("assets/images/TransperantLogo.png",
                      width: MediaQuery.of(context).size.width * 0.45),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 70, left: 28),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.cloud_upload_rounded,
                        color: Colors.black45,
                        size: 25,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 12),
                        child: Text(
                          translation(context)!.privacyPolicyHeader1,
                          style: const TextStyle(fontSize: 20),
                        ),
                      )
                    ],
                  ),
                ),
                Row(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(left: 65, top: 15),
                      width: MediaQuery.of(context).size.width * 0.75,
                      child: Text(
                        translation(context)!.privacyPolicyPara1,
                        style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                            color: Colors.black45),
                      ),
                    ),
                  ],
                ),
                Container(
                  margin: const EdgeInsets.only(top: 40, left: 28),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.file_copy_rounded,
                        color: Colors.black45,
                        size: 25,
                      ),
                      Container(
                        padding: const EdgeInsets.only(left: 12),
                        width: MediaQuery.of(context).size.width * 0.75,
                        child: Text(
                          translation(context)!.privacyPolicyHeader2,
                          style: const TextStyle(fontSize: 20),
                        ),
                      )
                    ],
                  ),
                ),
                Row(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(left: 65, top: 15),
                      width: MediaQuery.of(context).size.width * 0.75,
                      child: Text(
                        translation(context)!.privacyPolicyPara2,
                        style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                            color: Colors.black45),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Container(
              color: const Color.fromARGB(222, 238, 234, 234),
              height: MediaQuery.of(context).size.height * 0.25,
              width: MediaQuery.of(context).size.width * 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 40),
                    child: Text(
                      translation(context)!.privacyPolicyFooter1,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontWeight: FontWeight.w500, color: Colors.black45),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        RichText(
                          text: TextSpan(
                              text: translation(context)!.privacyPolicyFooter2,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black45),
                              children: <InlineSpan>[
                                WidgetSpan(
                                  child: Container(
                                    margin: const EdgeInsets.only(left: 5),
                                    child: LinkButton(
                                        urlLabel:
                                            translation(context)!.privacyPolicy,
                                        url:
                                            'https://sites.google.com/view/htafinance/home'),
                                  ),
                                ),
                              ]),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
