import 'package:ep_feedmill/bloc/bloc_base.dart';
import 'package:ep_feedmill/bloc/bluetooth_bloc.dart';
import 'package:ep_feedmill/mixin/simple_alert_dialog_mixin.dart';
import 'package:ep_feedmill/module/bluetooth_module.dart';
import 'package:ep_feedmill/res/string.dart';
import 'package:ep_feedmill/screen/premix/bloc/premix_bloc.dart';
import 'package:ep_feedmill/screen/premix/bloc/premix_scan_bloc.dart';
import 'package:ep_feedmill/screen/premix/bloc/premix_weighing_bloc.dart';
import 'package:ep_feedmill/widget/simple_confirm_dialog.dart';
import 'package:flutter/material.dart';

class Weighing extends StatefulWidget {
  @override
  _WeighingState createState() => _WeighingState();
}

class _WeighingState extends State<Weighing> {
  TextEditingController weightController;
  TextEditingController otpController;

  @override
  void initState() {
    super.initState();
    weightController = TextEditingController();
    otpController = TextEditingController();
  }

  @override
  void dispose() {
    weightController.dispose();
    otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bluetoothBloc = BlocProvider.of<BluetoothBloc>(context);
    final weighingBloc = BlocProvider.of<PremixWeighingBloc>(context);
    final scanBloc = BlocProvider.of<PremixScanBloc>(context);
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
                    stream: weighingBloc.isWeighingEditable,
                    builder: (context, snapshot) {
                      bool isEditable = false;
                      if (snapshot.hasData) {
                        isEditable = snapshot.data;
                      }
                      return TextFormField(
                        enabled: isEditable,
                        controller: weightController,
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                            border: OutlineInputBorder(), labelText: Strings.weightKg),
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
                    .insertTempPremixDetail(double.tryParse(weightController.text))
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
        ),
        StreamBuilder<SelectedItemPacking>(
            stream: scanBloc.selectedItemPackingStream,
            builder: (context, snapshot) {
              var isPremix = 0;
              if (snapshot.data != null) {
                if (!snapshot.data.isError) {
                  isPremix = snapshot.data.isPremix;
                }
              }
              if (isPremix == 0) {
                return Container(height: 55);
              }
              return SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                  child: RaisedButton.icon(
                    onPressed: () {
                      premixBloc.autoInsertTempPremixDetailWithWeight().then((success) {
                        if (success) {
                          weightController.text = "";
                          weighingBloc.setIsWeighingByBt(false);
                        }
                      });
                    },
                    icon: Icon(Icons.leak_remove),
                    label: Text(
                      Strings.autoAdd.toUpperCase(),
                    ),
                  ),
                ),
              );
            }),
        SizedBox(height: 185),
        StreamBuilder<bool>(
            stream: weighingBloc.isAllowManualStream,
            initialData: false,
            builder: (context, snapshot) {
              final isAllow = snapshot.data;
              if (isAllow) {
                return Container(height: 55);
              }
              return SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                  child: RaisedButton.icon(
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text("Enter Password for Manual Weight"),
                              content: TextField(
                                autofocus: true,
                                controller: otpController,
                                keyboardType: TextInputType.numberWithOptions(),
                                decoration: InputDecoration(labelText: Strings.password),
                              ),
                              actions: <Widget>[
                                FlatButton(
                                  child: Text(Strings.cancel.toUpperCase()),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                                FlatButton(
                                  child: Text("Verify".toUpperCase()),
                                  onPressed: () async {
                                    final res = await weighingBloc
                                        .verifyPasswordForManual(otpController.text);
                                    if (res) {
                                      Navigator.of(context).pop();
                                    } else {
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return SimpleAlertDialog(
                                              title: Strings.error,
                                              message: "Failed",
                                            );
                                          });
                                    }
                                  },
                                ),
                              ],
                            );
                          });
                    },
                    icon: Icon(Icons.cast_connected),
                    label: Text(
                      Strings.manualWeigt.toUpperCase(),
                    ),
                  ),
                ),
              );
            }),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Row(
              children: <Widget>[
                StreamBuilder<bool>(
                    stream: weighingBloc.isTaringStream,
                    initialData: false,
                    builder: (context, snapshot) {
                      return Checkbox(
                        value: snapshot.data,
                        onChanged: (bool b) {
                          weighingBloc.setIsTaring(b);
                        },
                      );
                    }),
                Text(Strings.allowTare),
              ],
            ),
            Row(
              children: <Widget>[
                StreamBuilder<bool>(
                    stream: scanBloc.isAllowAddonStream,
                    initialData: false,
                    builder: (context, snapshot) {
                      return Checkbox(
                        value: snapshot.data,
                        onChanged: (bool b) {
                          if (b) {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return SimpleConfirmDialog(
                                  title: "Turn On Additional?",
                                  message: "Are you sure?",
                                  btnPositiveText: Strings.turnOn,
                                  vcb: () async {
                                    scanBloc.setIsAllowAddon(b);
                                  },
                                );
                              },
                            );
                          } else {
                            scanBloc.setIsAllowAddon(b);
                          }
                        },
                      );
                    }),
                Text(Strings.allowAddon),
              ],
            ),
          ],
        ),
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
                  onPressed:
                      snapshot.data ? () => showBluetoothDevices(context, bluetoothBloc) : null,
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
                        "${Strings.status} : ${snapshot.data.toString()}",
                        style: TextStyle(fontSize: 12),
                      );
                    }),
                StreamBuilder<String>(
                    stream: bluetoothBloc.nameStream,
                    builder: (context, snapshot) {
                      return Text("${Strings.name} : ${(snapshot.data ?? "")}",
                          style: TextStyle(fontSize: 12));
                    }),
                StreamBuilder<String>(
                    stream: bluetoothBloc.addressStream,
                    builder: (context, snapshot) {
                      return Text("${Strings.address} : ${(snapshot.data ?? "")}",
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
                  onPressed: snapshot.data ? () => bluetoothBloc.connectDevice() : null,
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
          bluetoothBloc.loadDevices();
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
                          child: Text('Empty', style: Theme.of(context).textTheme.display1));
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
                StreamBuilder<bool>(
                    initialData: true,
                    stream: weighingBloc.isTaringStream,
                    builder: (context, snapshot) {
                      if (snapshot.data) {
                        return LiveWeight(
                          weightDesc: Strings.tareWeight,
                          weightStream: weighingBloc.tareWeightStream,
                        );
                      }
                      return Container();
                    }),
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
