import 'package:ep_feedmill/bloc/bloc_base.dart';
import 'package:ep_feedmill/bloc/bluetooth_bloc.dart';
import 'package:ep_feedmill/module/bluetooth_module.dart';
import 'package:ep_feedmill/res/string.dart';
import 'package:ep_feedmill/screen/premix/bloc/premix_bloc.dart';
import 'package:ep_feedmill/screen/premix/bloc/premix_weighing_bloc.dart';
import 'package:flutter/material.dart';

class Weighing extends StatefulWidget {
  @override
  _WeighingState createState() => _WeighingState();
}

class _WeighingState extends State<Weighing> {
  TextEditingController weightController;

  @override
  void initState() {
    super.initState();
    weightController = TextEditingController();
  }

  @override
  void dispose() {
    weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bluetoothBloc = BlocProvider.of<BluetoothBloc>(context);
    final weighingBloc = BlocProvider.of<PremixWeighingBloc>(context);
    final premixBloc = BlocProvider.of<PremixBloc>(context);

    return ListView(
      children: <Widget>[
        BluetoothPanel(),
        WeighingDisplay(),
        SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
            child: RaisedButton.icon(
              onPressed: () {
                var weight = double.tryParse(bluetoothBloc.getWeighingResult());
                if (weight != null) {
                  weightController.text = weight.toStringAsFixed(2);
                  weighingBloc.setIsWeighingByBt(true);
                }
              },
              icon: Icon(Icons.arrow_downward),
              label: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("GET ${Strings.grossWeight.toUpperCase()}"),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: <Widget>[
              Expanded(
                child: StreamBuilder<bool>(
                    stream: weighingBloc.isWeighingByBtStream,
                    builder: (context, snapshot) {
                      bool isBt = false;
                      if (snapshot.hasData) {
                        isBt = snapshot.data;
                      }
                      return TextFormField(
                        enabled: !isBt,
                        controller: weightController,
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
                  weighingBloc.setIsWeighingByBt(false);
                },
              )
            ],
          ),
        ),
        SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
            child: RaisedButton.icon(
              onPressed: () {
                premixBloc
                    .insertTempPremixDetail(
                        double.tryParse(weightController.text))
                    .then((success) {
                  if (success) {
                    weightController.text = "";
                    weighingBloc.setIsWeighingByBt(false);
                  }
                });
              },
              icon: Icon(Icons.add),
              label: Text(
                Strings.add.toUpperCase(),
              ),
            ),
          ),
        )
      ],
    );
  }
}

class BluetoothPanel extends StatefulWidget {
  @override
  _BluetoothPanelState createState() => _BluetoothPanelState();
}

class _BluetoothPanelState extends State<BluetoothPanel> {
  @override
  Widget build(BuildContext context) {
    final bluetoothBloc = BlocProvider.of<BluetoothBloc>(context);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
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

class WeighingDisplay extends StatefulWidget {
  @override
  _WeighingDisplayState createState() => _WeighingDisplayState();
}

class _WeighingDisplayState extends State<WeighingDisplay> {
  @override
  Widget build(BuildContext context) {
    final weighingBloc = BlocProvider.of<PremixWeighingBloc>(context);
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Column(
              children: <Widget>[
                LiveWeight(
                  weightDesc: Strings.grossWeight,
                  weightStream: weighingBloc.grossWeightStream,
                ),
                LiveWeight(
                  weightDesc: Strings.tareWeight,
                  weightStream: weighingBloc.tareWeightStream,
                ),
                LiveWeight(
                  weightDesc: Strings.netWeight,
                  weightStream: weighingBloc.netWeightStream,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LiveWeight extends StatefulWidget {
  final String weightDesc;
  final Stream<double> weightStream;

  LiveWeight({@required this.weightDesc, @required this.weightStream});

  @override
  _LiveWeightState createState() => _LiveWeightState();
}

class _LiveWeightState extends State<LiveWeight> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          widget.weightDesc,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        StreamBuilder<double>(
            stream: widget.weightStream,
            builder: (context, snapshot) {
              var weight = 0.00;
              if (snapshot.hasData) {
                weight = snapshot.data;
              }
              return Text(
                "${weight.toStringAsFixed(2)} Kg",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'MonoSpace',
                ),
              );
            }),
      ],
    );
  }
}
