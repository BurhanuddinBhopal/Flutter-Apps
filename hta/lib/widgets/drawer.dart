// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors, duplicate_ignore, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:hta/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/routes.dart';

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
    print(finalName);
    print(lastName);
    print(finalNumber);
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Material(
        color: Color.fromARGB(221, 255, 255, 255),
        child: Form(
          child: ListView(
            children: [
              Container(
                margin: EdgeInsets.only(right: 250),
                child: IconButton(
                    onPressed: (() {
                      Navigator.pop(context);
                    }),
                    icon: Icon(Icons.arrow_back)),
              ),
              Row(
                children: [
                  Icon(
                    Icons.person_rounded,
                    size: 80,
                    color: Colors.black38,
                  ),
                  Column(
                    children: [
                      Row(
                        children: [
                          Text(finalName),
                          Text(finalLastname),
                        ],
                      ),
                      Text(finalNumber)
                    ],
                  )
                ],
              ),
              ListTile(
                leading: Icon(
                  Icons.settings,
                  size: 28,
                ),
                title: Text(
                  'Settings',
                  style: TextStyle(fontSize: 20),
                ),
                trailing: Icon(Icons.arrow_forward_ios),
              ),
              Divider(),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.555,
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 35),
                height: MediaQuery.of(context).size.height * 0.055,
                child: ElevatedButton(
                  onPressed: () async {
                    SharedPreferences sharedPreferences =
                        await SharedPreferences.getInstance();
                    sharedPreferences.remove('mobileNumber');
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => LoginPage()));
                  },
                  child: Text('LOG OUT'),
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.black26),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
