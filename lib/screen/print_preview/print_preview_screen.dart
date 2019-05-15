import 'dart:ui';

import 'package:ep_feedmill/bloc/bloc_base.dart';
import 'package:ep_feedmill/model/network_printer_device.dart';
import 'package:ep_feedmill/res/string.dart';
import 'package:ep_feedmill/screen/print_preview/print_preview_bloc.dart';
import 'package:ep_feedmill/widget/simple_alert_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class PrintPreviewScreen extends StatefulWidget {
  final String barcodeText;
  final String printText;

  PrintPreviewScreen({this.barcodeText, this.printText});

  @override
  _PrintPreviewScreenState createState() => _PrintPreviewScreenState();
}

class _PrintPreviewScreenState extends State<PrintPreviewScreen>
    implements PrintPreviewDelegate {
  PrintPreviewBloc printPreviewBloc;

  @override
  void initState() {
    super.initState();
    printPreviewBloc = PrintPreviewBloc(delegate: this);
  }

  @override
  void onDialogMessage(String title, String message) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleAlertDialog(
            title: title,
            message: message,
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PrintPreviewBloc>(
      bloc: printPreviewBloc,
      child: Scaffold(
          appBar: AppBar(
            title: Text(Strings.printPreview),
          ),
          body: PrintPreviewBody(widget.barcodeText, widget.printText)),
    );
  }
}

class PrintPreviewBody extends StatefulWidget {
  final String qrText;
  final String printText;

  PrintPreviewBody(this.qrText, this.printText);

  @override
  _PrintPreviewBodyState createState() => _PrintPreviewBodyState();
}

class _PrintPreviewBodyState extends State<PrintPreviewBody> {
  @override
  Widget build(BuildContext context) {
    final printPreviewBloc = BlocProvider.of<PrintPreviewBloc>(context);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 128),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: StreamBuilder<NetworkPrinterDevice>(
                    stream: printPreviewBloc.printerStream,
                    builder: (context, snapshot) {
                      var ip = "", port = "";
                      if (snapshot.hasData) {
                        if (snapshot != null) {
                          ip = snapshot.data.ip;
                          port = snapshot.data.port.toString();
                        }
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            Strings.ipAddress,
                            style: TextStyle(fontSize: 10, color: Colors.grey),
                          ),
                          Text(ip),
                          Text(
                            Strings.port,
                            style: TextStyle(fontSize: 10, color: Colors.grey),
                          ),
                          Text(port),
                        ],
                      );
                    }),
              ),
              IconButton(
                onPressed: () {
                  printPreviewBloc.print(widget.qrText, widget.printText);
                },
                icon: Icon(Icons.print),
                iconSize: 64,
                color: Theme.of(context).primaryColor,
                splashColor: Theme.of(context).accentColor,
              )
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(8),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: <Widget>[
                    Text(
                      widget.printText,
                      style: TextStyle(fontFamily: 'MonoSpace'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        )
      ],
    );
  }
}

abstract class PrintPreviewDelegate {
  void onDialogMessage(String title, String message);
}
