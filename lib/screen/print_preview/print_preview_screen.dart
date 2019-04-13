import 'dart:ui';

import 'package:ep_feedmill/bloc/bloc_base.dart';
import 'package:ep_feedmill/bloc/bluetooth_bloc.dart';
import 'package:ep_feedmill/module/bluetooth_module.dart';
import 'package:ep_feedmill/res/string.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class PrintPreviewScreen extends StatefulWidget {
  final String qrText;
  final String printText;

  PrintPreviewScreen({this.qrText, this.printText});

  @override
  _PrintPreviewScreenState createState() => _PrintPreviewScreenState();
}

class _PrintPreviewScreenState extends State<PrintPreviewScreen>
    implements BluetoothDelegate {
  BluetoothBloc bluetoothBloc;

  @override
  void initState() {
    super.initState();
    bluetoothBloc = BluetoothBloc(BluetoothType.Printer, this);
  }

  @override
  void onBluetoothError(String message) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(Strings.error),
            content: Text(message),
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
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<BluetoothBloc>(
      bloc: bluetoothBloc,
      child: Scaffold(
          appBar: AppBar(
            title: Text(Strings.printPreview),
          ),
          body: PrintPreviewBody(widget.qrText, widget.printText)),
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
    final bluetoothBloc = BlocProvider.of<BluetoothBloc>(context);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              StreamBuilder<bool>(
                  stream: bluetoothBloc.isBluetoothEnabledStream,
                  initialData: false,
                  builder: (context, snapshot) {
                    return IconButton(
                      onPressed: snapshot.data
                          ? () => showBluetoothDevices(context, bluetoothBloc)
                          : null,
                      icon: Icon(Icons.bluetooth),
                      iconSize: 64,
                      color: Theme.of(context).primaryColor,
                      splashColor: Theme.of(context).accentColor,
                    );
                  }),
              StreamBuilder<bool>(
                  stream: bluetoothBloc.isBluetoothEnabledStream,
                  initialData: false,
                  builder: (context, snapshot) {
                    return IconButton(
                      onPressed: snapshot.data
                          ? () => bluetoothBloc.connectDevice()
                          : null,
                      icon: Icon(Icons.refresh),
                      iconSize: 64,
                      color: Theme.of(context).primaryColor,
                      splashColor: Theme.of(context).accentColor,
                    );
                  }),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    StreamBuilder<String>(
                        stream: bluetoothBloc.statusStream,
                        builder: (context, snapshot) {
                          return Text("Status : " + snapshot.data.toString());
                        }),
                    StreamBuilder<String>(
                        stream: bluetoothBloc.nameStream,
                        builder: (context, snapshot) {
                          return Text("Name : " +
                              ((snapshot.data != null) ? snapshot.data : ""));
                        }),
                    StreamBuilder<String>(
                        stream: bluetoothBloc.addressStream,
                        builder: (context, snapshot) {
                          return Text("Address : " +
                              ((snapshot.data != null) ? snapshot.data : ""));
                        }),
                  ],
                ),
              ),
              StreamBuilder<bool>(
                  stream: bluetoothBloc.isConnectedStream,
                  builder: (context, snapshot) {
                    var isConnected = false;
                    if (snapshot.data != null) {
                      isConnected = snapshot.data;
                    }
                    return IconButton(
                      onPressed: () {
                        bluetoothBloc.print(widget.qrText, widget.printText);
                      },
                      icon: Icon(Icons.print),
                      iconSize: 64,
                      color: isConnected
                          ? Theme.of(context).primaryColor
                          : Theme.of(context).errorColor,
                      splashColor: Theme.of(context).accentColor,
                    );
                  }),
            ],
          ),
        ),
        Expanded(
            child: SingleChildScrollView(
          padding: EdgeInsets.all(8),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
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
        ))
      ],
    );
  }

  void showBluetoothDevices(BuildContext context, BluetoothBloc bluetoothBloc) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text(Strings.bluetoothDevices),
            content: Container(
              height: 300.0,
              width: 300.0,
              child: StreamBuilder<List<BluetoothDevice>>(
                  stream: bluetoothBloc.devicesStream,
                  builder: (context, snapshot) {
                    if (snapshot.data == null || snapshot.data.isEmpty) {
                      return Center(
                          child: Text('Empty',
                              style: Theme.of(context).textTheme.display1));
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: snapshot.data.length,
                      itemBuilder: (BuildContext context, int index) {
                        final devices = snapshot.data;
                        return Container(
                          color: (index % 2 == 0)
                              ? Theme.of(context).highlightColor
                              : Theme.of(context).dialogBackgroundColor,
                          child: ListTile(
                            onTap: () {
                              bluetoothBloc.selectDevice(devices[index]);
                              Navigator.pop(context);
                            },
                            title: Row(
                              children: <Widget>[
                                Expanded(child: Text(devices[index].name)),
                                Expanded(child: Text(devices[index].address)),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }),
            ),
          );
        });
  }
}
