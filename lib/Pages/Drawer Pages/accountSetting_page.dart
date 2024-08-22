import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hta/Pages/Account%20Pages/change_language_page.dart';
import 'package:hta/language/language.dart';

import '../../language/language_constant.dart';
import '../Account Pages/forgot_password_page.dart';

class AccountSettings extends StatefulWidget {
  const AccountSettings({super.key});

  @override
  State<AccountSettings> createState() => _AccountSettingsState();
}

class _AccountSettingsState extends State<AccountSettings> {
  Language? selectedLanguage;
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
          translation(context)!.settings,
          style: const TextStyle(color: Colors.black),
        ),
      ),
      body: Container(
        margin: const EdgeInsets.symmetric(vertical: 50),
        child: Column(
          children: [
            TextButton(
              style: ButtonStyle(
                overlayColor: WidgetStateProperty.all(Colors.transparent),
              ),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ForgotPassword()));
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    margin: const EdgeInsets.only(left: 25),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.key,
                          size: 30,
                          color: Colors.black,
                        ),
                        Container(
                          margin: const EdgeInsets.only(left: 18),
                          child: Text(
                            translation(context)!.changePassword,
                            style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w400,
                                color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(right: 25),
                    child: Row(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(right: 5),
                          child: const Icon(
                            Icons.arrow_forward_ios,
                            size: 25,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            const Divider(
              thickness: 1,
              indent: 30,
            ),
            TextButton(
              style: ButtonStyle(
                overlayColor: WidgetStateProperty.all(Colors.transparent),
              ),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ChangeLanguage()));
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    margin: const EdgeInsets.only(left: 25),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.language,
                          size: 30,
                          color: Colors.black,
                        ),
                        Container(
                          margin: const EdgeInsets.only(left: 18),
                          child: Text(
                            translation(context)!.changeLanguage,
                            style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w400,
                                color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(right: 25),
                    child: Row(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(right: 5),
                          child: const Icon(
                            Icons.arrow_forward_ios,
                            size: 25,
                            color: Colors.black,
                          ),
                        ),
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
