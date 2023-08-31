import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
          'About Us',
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
                  'HTA is an online ledger accounting app/ Udhar khata app which simplifies credit account management for shop owners and their customers.',
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                      color: Colors.black45),
                ),
              ),
              Text(
                'Merchants can use HTA application to record credits and payments with their customers. Also, there is no fear of losing records as all data is crypted and backed up online against your phone number based account and can be recoverd by a simple OTP authentication on a new device later on.',
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                    color: Colors.black45),
              ),
              Container(
                  margin: EdgeInsets.only(top: 20),
                  child: Text(
                    'Customers get transaction updates via SMS. They can view their balance and transaction history at a unique link in the SMS. The lender can also send pending dues reminders to the other party.',
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
