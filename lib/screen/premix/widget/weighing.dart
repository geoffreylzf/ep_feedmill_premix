import 'package:ep_feedmill/bloc/bloc_base.dart';
import 'package:ep_feedmill/bloc/bluetooth_bloc.dart';
import 'package:ep_feedmill/module/bluetooth_module.dart';
import 'package:ep_feedmill/res/string.dart';
import 'package:ep_feedmill/screen/premix/bloc/premix_bloc.dart';
import 'package:flutter/material.dart';

class Weighing extends StatefulWidget {
  @override
  _WeighingState createState() => _WeighingState();
}

class _WeighingState extends State<Weighing> {

  final weightController = TextEditingController();
  final weightFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    final bluetoothBloc = BlocProvider.of<BluetoothBloc>(context);
    final premixBloc = BlocProvider.of<PremixBloc>(context);

    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            StreamBuilder<bool>(
                stream: bluetoothBloc.isBluetoothEnabledStream,
                initialData: false,
                builder: (context, snapshot) {
                  return IconButton(
                    icon: Icon(Icons.bluetooth),
                    iconSize: 48,
                    onPressed: snapshot.data
                        ? () => showBluetoothDevices(context, bluetoothBloc)
                        : null,
                    color: Theme.of(context).primaryColor,
                    splashColor: Theme.of(context).accentColor,
                  );
                }),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  StreamBuilder<String>(
                      stream: bluetoothBloc.statusStream,
                      builder: (context, snapshot) {
                        return Text(
                          "Status : " + snapshot.data.toString(),
                          style: TextStyle(fontSize: 12),
                        );
                      }),
                  StreamBuilder<String>(
                      stream: bluetoothBloc.nameStream,
                      builder: (context, snapshot) {
                        return Text(
                            "Name : " +
                                ((snapshot.data != null) ? snapshot.data : ""),
                            style: TextStyle(fontSize: 12));
                      }),
                  StreamBuilder<String>(
                      stream: bluetoothBloc.addressStream,
                      builder: (context, snapshot) {
                        return Text(
                            "Address : " +
                                ((snapshot.data != null) ? snapshot.data : ""),
                            style: TextStyle(fontSize: 12));
                      }),
                ],
              ),
            ),
            StreamBuilder<bool>(
                stream: bluetoothBloc.isBluetoothEnabledStream,
                initialData: false,
                builder: (context, snapshot) {
                  return IconButton(
                    icon: Icon(Icons.refresh),
                    iconSize: 48,
                    onPressed: snapshot.data
                        ? () => bluetoothBloc.connectDevice()
                        : null,
                    color: Theme.of(context).primaryColor,
                    splashColor: Theme.of(context).accentColor,
                  );
                }),
          ],
        ),
        Row(
          children: <Widget>[
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: StreamBuilder<String>(
                    stream: bluetoothBloc.weighingResultStream,
                    builder: (context, snapshot) {
                      String weight = "";
                      if (snapshot.hasData) {
                        weight = snapshot.data;
                      }
                      return RaisedButton.icon(
                        onPressed: () {
                          weightController.text =
                              bluetoothBloc.getWeighingResult();
                          premixBloc.setIsWeighingByBt(true);
                        },
                        icon: Icon(Icons.arrow_downward),
                        label: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("$weight KG",
                              style: TextStyle(fontSize: 24)),
                        ),
                      );
                    }),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: <Widget>[
              Expanded(
                child: StreamBuilder<bool>(
                    stream: premixBloc.isWeighingByBtStream,
                    builder: (context, snapshot) {
                      bool isBt = false;
                      if (snapshot.hasData) {
                        isBt = snapshot.data;
                      }
                      return TextFormField(
                        enabled: !isBt,
                        controller: weightController,
                        focusNode: weightFocusNode,
                        keyboardType:
                            TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: Strings.weightKg),
                      );
                    }),
              ),
              IconButton(
                icon: Icon(Icons.cancel),
                onPressed: () {
                  weightController.text = "";
                  premixBloc.setIsWeighingByBt(false);
                },
              )
            ],
          ),
        ),
        Row(
          children: <Widget>[
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: RaisedButton.icon(
                    onPressed: () {
                      premixBloc.insertTempPremixDetail(double.tryParse(weightController.text));
                    },
                    icon: Icon(Icons.save),
                    label: Text(Strings.save.toUpperCase())),
              ),
            ),
          ],
        )
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
