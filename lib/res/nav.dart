import 'package:ep_feedmill/model/user.dart';
import 'package:ep_feedmill/module/shared_preferences_module.dart';
import 'package:ep_feedmill/res/route.dart';
import 'package:ep_feedmill/res/string.dart';
import 'package:flutter/material.dart';

class NavDrawerStart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            child: FutureBuilder<User>(
                future: SharedPreferencesModule().getUser(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(snapshot.data.username),
                        Text(snapshot.data.password),
                      ],
                    );
                  }
                  return Container();
                }),
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
          ),
          ListTile(
            leading: Icon(Icons.view_quilt),
            title: Text(Strings.houseKeeping),
            onTap: () {
              Navigator.pushNamed(context, Routes.housekeeping);
            },
          ),
          ListTile(
            leading: Icon(Icons.cloud_upload),
            title: Text(Strings.upload),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text(Strings.logout),
            onTap: () async {
              await SharedPreferencesModule().clearUser();
              Navigator.pushReplacementNamed(context, Routes.login);
            },
          ),
        ],
      ),
    );
  }
}
