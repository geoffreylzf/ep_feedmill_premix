// This sample shows adding an action to an [AppBar] that opens a shopping cart.

import 'package:ep_feedmill/model/user.dart';
import 'package:ep_feedmill/module/shared_preferences_module.dart';
import 'package:ep_feedmill/res/route.dart';
import 'package:ep_feedmill/res/string.dart';
import 'package:ep_feedmill/res/theme.dart';
import 'package:ep_feedmill/screen/home_screen.dart';
import 'package:ep_feedmill/screen/house_keeping_screen.dart';
import 'package:ep_feedmill/screen/login_screen.dart';
import 'package:ep_feedmill/screen/premix/premix.dart';
import 'package:flutter/material.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: appTheme(context),
      title: Strings.appName,
      home: FutureBuilder<User>(
        future: SharedPreferencesModule().getUser(),
        builder: (context, snapshot) {
          if (snapshot.data != null) {
            return HomeScreen();
          }
          return LoginScreen();
        },
      ),
      routes: {
        Routes.housekeeping: (context) => HousekeepingScreen(),
        Routes.premix: (context) => PremixScreen(),
        Routes.login: (context) => LoginScreen(),
        Routes.home: (context) => HomeScreen(),
      },
    );
  }
}
