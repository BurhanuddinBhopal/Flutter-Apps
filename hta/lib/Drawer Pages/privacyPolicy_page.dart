import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hta/widgets/link_button.dart';

class PrivacyPolicy extends StatelessWidget {
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
          'Privacy Policy',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Material(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                Container(
                  margin: EdgeInsets.only(top: 40),
                  child: Image.asset("assets/images/TransperantLogo.png",
                      width: MediaQuery.of(context).size.width * 0.45),
                ),
                Container(
                  margin: EdgeInsets.only(top: 70, left: 28),
                  child: Row(
                    children: [
                      Icon(
                        Icons.cloud_upload_rounded,
                        color: Colors.black45,
                        size: 25,
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 12),
                        child: Text(
                          'Is my data stored online?',
                          style: TextStyle(fontSize: 20),
                        ),
                      )
                    ],
                  ),
                ),
                Row(
                  children: [
                    Container(
                      margin: EdgeInsets.only(left: 65, top: 15),
                      width: MediaQuery.of(context).size.width * 0.75,
                      child: Text(
                        'Yes, because incase your phone is lost or damaged, you can recover all your data on the new device instantly. Migration of data is very simple now.',
                        style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                            color: Colors.black45),
                      ),
                    ),
                  ],
                ),
                Container(
                  margin: EdgeInsets.only(left: 28, top: 10),
                  child: Text(
                    'Migration of data is very simple now.',
                    style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                        color: Colors.black45),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 40, left: 28),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.file_copy_rounded,
                        color: Colors.black45,
                        size: 25,
                      ),
                      Container(
                        padding: EdgeInsets.only(left: 12),
                        width: MediaQuery.of(context).size.width * 0.75,
                        child: Text(
                          'Does HTA share my data with anyone?',
                          style: TextStyle(fontSize: 20),
                        ),
                      )
                    ],
                  ),
                ),
                Row(
                  children: [
                    Container(
                      margin: EdgeInsets.only(left: 65, top: 15),
                      width: MediaQuery.of(context).size.width * 0.75,
                      child: Text(
                        'No, we do not share your data with anyone. We only use it to improve your experience of using HTA app.',
                        style: TextStyle(
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
              color: Color.fromARGB(222, 238, 234, 234),
              height: MediaQuery.of(context).size.height * 0.25,
              width: MediaQuery.of(context).size.width * 1,
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 40),
                    child: Text(
                      'HTA is fully committed to the security of your data!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontWeight: FontWeight.w500, color: Colors.black45),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 80),
                    child: Row(
                      children: [
                        RichText(
                          text: TextSpan(
                              text: 'Tap to know more about',
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black45),
                              children: <InlineSpan>[
                                WidgetSpan(
                                  child: Container(
                                    margin: EdgeInsets.only(left: 5),
                                    child: LinkButton(
                                        urlLabel: "Privacy Policy",
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
