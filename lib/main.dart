// This sample shows adding an action to an [AppBar] that opens a shopping cart.

import 'package:ep_feedmill/model/user.dart';
import 'package:ep_feedmill/module/shared_preferences_module.dart';
import 'package:ep_feedmill/res/route.dart';
import 'package:ep_feedmill/res/string.dart';
import 'package:ep_feedmill/res/theme.dart';
import 'package:ep_feedmill/screen/home/home_screen.dart';
import 'package:ep_feedmill/screen/housekeeping/housekeeping_screen.dart';
import 'package:ep_feedmill/screen/login/login_screen.dart';
import 'package:ep_feedmill/screen/premix_history/premix_history_screen.dart';
import 'package:ep_feedmill/screen/setting/setting_screen.dart';
import 'package:ep_feedmill/screen/upload/upload_screen.dart';
import 'package:ep_feedmill/store/store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  final store = Store<int>(
    groupNoReducer,
    initialState: 0,
  );

  @override
  Widget build(BuildContext context) {
    SharedPreferencesModule().getGroupNo().then((i) {
      if (i != null) {
        store.dispatch(SelectGroupNo(i));
      }
    });
    return StoreProvider<int>(
      store: store,
      child: MaterialApp(
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
          Routes.login: (context) => LoginScreen(),
          Routes.home: (context) => HomeScreen(),
          Routes.housekeeping: (context) => HousekeepingScreen(),
          Routes.setting: (context) => SettingScreen(),
          Routes.premixHistory: (context) => PremixHistoryScreen(),
          Routes.upload: (context) => UploadScreen(),
        },
      ),
    );
  }
}
