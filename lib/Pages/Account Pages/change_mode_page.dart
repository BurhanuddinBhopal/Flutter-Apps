import 'package:flutter/material.dart';
import 'package:hta/Pages/App%20Pages/bottom_navigation_page.dart';
import 'package:hta/language/language_constant.dart';
import 'package:hta/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChangeModePage extends StatefulWidget {
  const ChangeModePage({Key? key}) : super(key: key);

  @override
  _ModePageState createState() => _ModePageState();
}

class _ModePageState extends State<ChangeModePage> {
  String? selectedMode;

  @override
  void initState() {
    super.initState();
    _loadSelectedMode();
  }

  // Load the selected mode from SharedPreferences
  Future<void> _loadSelectedMode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedMode =
          prefs.getString('selectedMode') ?? 'Sales'; // Default to 'Sales'
    });
  }

  // Save the selected mode to SharedPreferences
  Future<void> _changeMode(String mode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedMode', mode);

    setState(() {
      selectedMode = mode;
    });

    // Navigate to BottomNavigationPage after selecting mode
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const BottomNavigationPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            color: const Color.fromRGBO(62, 13, 59, 1),
            height: MediaQuery.of(context).size.height * 0.255,
            padding: const EdgeInsets.only(top: 80, left: 25, right: 25),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Change Mode',
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                ListTile(
                  title: Row(
                    children: [
                      Container(
                        width: 24.0,
                        height: 24.0,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: selectedMode == 'Sales'
                              ? Colors.blue
                              : Colors.transparent,
                          border: Border.all(
                            color: selectedMode == 'Sales'
                                ? Colors.blue
                                : Colors.black,
                            width: 2.0,
                          ),
                        ),
                        child: Center(
                          child: selectedMode == 'Sales'
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
                        'Sales',
                        style: TextStyle(
                          fontSize: 18.0,
                          color: selectedMode == 'Sales'
                              ? Colors.blue
                              : Colors.black,
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    _changeMode('Sales');
                  },
                ),
                ListTile(
                  title: Row(
                    children: [
                      Container(
                        width: 24.0,
                        height: 24.0,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: selectedMode == 'Purchase'
                              ? Colors.blue
                              : Colors.transparent,
                          border: Border.all(
                            color: selectedMode == 'Purchase'
                                ? Colors.blue
                                : Colors.black,
                            width: 2.0,
                          ),
                        ),
                        child: Center(
                          child: selectedMode == 'Purchase'
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
                        'Purchase',
                        style: TextStyle(
                          fontSize: 18.0,
                          color: selectedMode == 'Purchase'
                              ? Colors.blue
                              : Colors.black,
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    _changeMode('Purchase');
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
