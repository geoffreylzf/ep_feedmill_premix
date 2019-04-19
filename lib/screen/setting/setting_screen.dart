import 'package:ep_feedmill/bloc/bloc_base.dart';
import 'package:ep_feedmill/res/string.dart';
import 'package:ep_feedmill/screen/setting/setting_bloc.dart';
import 'package:ep_feedmill/screen/setting/widget/network_printer_setting.dart';
import 'package:ep_feedmill/screen/setting/widget/setting_group_selection.dart';
import 'package:ep_feedmill/widget/simple_alert_dialog.dart';
import 'package:flutter/material.dart';

class SettingScreen extends StatefulWidget {
  @override
  _SettingScreenState createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> implements SettingDelegate {

  SettingBloc settingBloc;


  @override
  void onDialogMessage(String title, String message) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleAlertDialog(
            title: title,
            message: message,
            btnText: Strings.close.toUpperCase(),
          );
        });
  }

  @override
  void initState() {
    super.initState();
    settingBloc = SettingBloc(delegate: this);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      bloc: settingBloc,
      child: Scaffold(
        appBar: AppBar(
          title: Text(Strings.setting),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView(
            children: <Widget>[
              GroupSelection(),
              NetworkPrinterSetting(),
            ],
          ),
        ),
      ),
    );
  }
}

abstract class SettingDelegate {
  void onDialogMessage(String title, String message);
}