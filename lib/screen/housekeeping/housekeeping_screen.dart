import 'package:ep_feedmill/module/api_module.dart';
import 'package:ep_feedmill/db/dao/item_packing_dao.dart';
import 'package:ep_feedmill/res/string.dart';
import 'package:flutter/material.dart';

class HousekeepingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Strings.houseKeeping),
      ),
      body: Center(
        child: RaisedButton(
          onPressed: () {
            _loadItemPacking();
          },
          child: Text('Go back!'),
        ),
      ),
    );
  }
}

_loadItemPacking() async {
  var response = await ApiModule().getItemPacking();
  await ItemPackingDao().deleteAll();
  for (var ip in response.result) {
    await ItemPackingDao().insert(ip);
  }
}

_login(BuildContext context) {
  ApiModule().login("1", "1", "1").then((onValue) {
    print(onValue.cod);
    print(onValue.result.success);
  }).catchError((e) {


    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(Strings.error),
            content: Text(e.toString()),
            actions: <Widget>[
              FlatButton(
                child: Text(Strings.close),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  });
}
