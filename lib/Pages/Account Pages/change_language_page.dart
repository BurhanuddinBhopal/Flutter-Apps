import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hta/language/language_constant.dart';

import '../../language/language.dart';
import '../../main.dart';

class ChangeLanguage extends StatefulWidget {
  const ChangeLanguage({super.key});

  @override
  State<ChangeLanguage> createState() => _ChangeLanguageState();
}

class _ChangeLanguageState extends State<ChangeLanguage> {
  List<Language> languages = Language.languageList();
  String selectedLanguageCode = '';

  @override
  void initState() {
    super.initState();
    _loadCurrentLanguage();
  }

  _loadCurrentLanguage() async {
    Locale currentLocale = await getLocale();
    setState(() {
      selectedLanguageCode = currentLocale.languageCode;
    });
  }

  // void _showPopupDialog() {
  //   showDialog(
  //     context: context,
  //     builder: (ctx) => AlertDialog(
  //       title: Text(
  //         translation(context).successMessageforLanguage,
  //         textAlign: TextAlign.center,
  //       ),
  //       actions: <Widget>[
  //         Container(
  //           // margin: EdgeInsets.symmetric(horizontal: 120),
  //           child: ElevatedButton(
  //             style: ElevatedButton.styleFrom(
  //                 backgroundColor: Color.fromRGBO(62, 13, 59, 1)),
  //             child: Text(
  //               translation(context).okay,
  //               style: TextStyle(
  //                   fontWeight: FontWeight.bold,
  //                   fontSize: 15,
  //                   color: Colors.white),
  //             ),
  //             onPressed: () {
  //               Navigator.push(
  //                   context,
  //                   PageTransition(
  //                     type: PageTransitionType.fade,
  //                     child: BottomNavigationPage(),
  //                   ));
  //             },
  //           ),
  //         )
  //       ],
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return Scaffold(
        body: Container(
            child: Column(children: [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            color: const Color.fromRGBO(62, 13, 59, 1),
            height: MediaQuery.of(context).size.height * 0.255,
            child: Container(
              margin: const EdgeInsets.only(top: 80),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      translation(context)!.changeLanguage,
                      style: const TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.w400,
                          color: Colors.white),
                    ),
                    IconButton(
                        onPressed: (() {
                          Navigator.of(context).pop();
                        }),
                        icon: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 30,
                        )),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      Column(
        children: [
          ListView.builder(
            shrinkWrap: true,
            itemCount: languages.length,
            itemBuilder: (context, index) {
              Language language = languages[index];
              return ListTile(
                title: Row(
                  children: [
                    Container(
                      width: 24.0,
                      height: 24.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: selectedLanguageCode == language.languageCode
                            ? Colors.blue
                            : Colors.transparent,
                        border: Border.all(
                          color: selectedLanguageCode == language.languageCode
                              ? Colors.blue
                              : Colors.black,
                          width: 2.0,
                        ),
                      ),
                      child: Center(
                        child: selectedLanguageCode == language.languageCode
                            ? const Icon(
                                Icons.check,
                                size: 16.0,
                                color: Colors.white,
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(width: 12.0),
                    Text(
                      language.name,
                      style: TextStyle(
                        fontSize: 18.0,
                        color: selectedLanguageCode == language.languageCode
                            ? Colors.blue
                            : Colors.black,
                      ),
                    ),
                  ],
                ),
                onTap: () {
                  _changeLanguage(language.languageCode);
                },
              );
            },
          ),
        ],
      ),
      // SizedBox(
      //   height: MediaQuery.of(context).size.height * 0.4,
      // ),
      // Column(
      //   children: [
      //     Padding(
      //       padding: EdgeInsets.symmetric(horizontal: 30),
      //       child: ElevatedButton(
      //         style: TextButton.styleFrom(
      //           backgroundColor: Color.fromRGBO(62, 13, 59, 1),
      //           shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      //           minimumSize: Size(350, 50),
      //         ),
      //         onPressed: () {
      //           _showPopupDialog();
      //         },
      //         child: Text(translation(context).changeLanguageCapital),
      //       ),
      //     ),
      //   ],
      // ),
    ])));
  }

  Locale _locale(String languageCode) {
    switch (languageCode) {
      case ENGLISH:
        return const Locale(ENGLISH, '');
      case HINDI:
        return const Locale(HINDI, "");
      default:
        return const Locale(ENGLISH, '');
    }
  }

  _changeLanguage(String languageCode) async {
    await setLocale(languageCode);
    setState(() {
      selectedLanguageCode = languageCode;
    });

    MyApp.setLocale(context, _locale(languageCode));

    // Show a snackbar to confirm the language change
    ScaffoldMessenger.of(context)
        .removeCurrentSnackBar(); // Remove existing snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Language changed to $languageCode'),
      ),
    );
  }
}
