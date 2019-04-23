import 'package:ep_feedmill/bloc/bloc_base.dart';
import 'package:ep_feedmill/model/network_printer_device.dart';
import 'package:ep_feedmill/module/barcode_module.dart';
import 'package:ep_feedmill/module/shared_preferences_module.dart';
import 'package:ep_feedmill/res/string.dart';
import 'package:ep_feedmill/screen/print_preview/print_preview_screen.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class PrintPreviewBloc extends BlocBase {
  final _printerSubject = BehaviorSubject<NetworkPrinterDevice>();

  Stream<NetworkPrinterDevice> get printerStream => _printerSubject.stream;

  @override
  void dispose() {
    _printerSubject.close();
  }

  PrintPreviewDelegate _delegate;

  PrintPreviewBloc({@required PrintPreviewDelegate delegate}) {
    _delegate = delegate;
    _init();
  }

  _init() async {
    _printerSubject.add(await SharedPreferencesModule().getNetworkPrinter());
  }

  print(String codeText, String strText) async {
    final printer = _printerSubject.value;

    if (printer == null) {
      _delegate.onDialogMessage(Strings.error, "Printer setting not set.");
      return;
    }

    try {
      final byteData = await BarcodeModule().generateCode128Code(codeText);
      await printer.print(byteData, strText);
    } catch (e) {
      _delegate.onDialogMessage(Strings.error, e.toString());
      await printer.forceCloseSocket();
    }
  }
}
