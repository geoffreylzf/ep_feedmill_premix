import 'package:ep_feedmill/bloc/bloc_base.dart';
import 'package:ep_feedmill/model/network_printer_device.dart';
import 'package:ep_feedmill/module/shared_preferences_module.dart';
import 'package:ep_feedmill/res/string.dart';
import 'package:ep_feedmill/screen/setting/setting_screen.dart';
import 'package:flutter/material.dart';

class SettingBloc extends BlocBase {
  @override
  void dispose() {}

  SettingDelegate _delegate;

  SettingBloc({@required SettingDelegate delegate}) {
    _delegate = delegate;
  }

  Future<NetworkPrinterDevice> getNetworkPrinter() async {
    return await SharedPreferencesModule().getNetworkPrinter();
  }

  saveNetworkPrinter(String ip, int port) async {
    await SharedPreferencesModule()
        .saveNetworkPrinter(NetworkPrinterDevice(ip, port));
    _delegate.onDialogMessage(
        Strings.success, "Network printer setting saved.");
  }

  testPrint(String ip, int port) async {
    final printer = NetworkPrinterDevice(ip, port);

    try {
      await printer.testPrint();
    } catch (e) {
      _delegate.onDialogMessage(Strings.error, e.toString());
      await printer.forceCloseSocket();
    }
  }
}
