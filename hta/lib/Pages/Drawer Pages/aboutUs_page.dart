import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../language/language_constant.dart';

class AboutUs extends StatelessWidget {
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
          translation(context).aboutUs,
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Material(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.only(top: 40),
                child: Image.asset("assets/images/TransperantLogo.png",
                    width: MediaQuery.of(context).size.width * 0.45),
              ),
              Container(
                margin: EdgeInsets.only(top: 40, bottom: 20),
                child: Text(
                  translation(context).aboutUsPara1,
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                      color: Colors.black45),
                ),
              ),
              Text(
                translation(context).aboutUsPara2,
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                    color: Colors.black45),
              ),
              Container(
                  margin: EdgeInsets.only(top: 20),
                  child: Text(
                    translation(context).aboutUsPara3,
                    style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                        color: Colors.black45),
                  ))
            ],
          ),
        ),
      ),
    );
  }
}
