import 'package:ep_feedmill/bloc/bloc_base.dart';
import 'package:ep_feedmill/res/string.dart';
import 'package:ep_feedmill/screen/setting/setting_bloc.dart';
import 'package:ep_feedmill/widget/card_label_small.dart';
import 'package:flutter/material.dart';

class SettingNetworkPrinter extends StatefulWidget {
  @override
  _SettingNetworkPrinterState createState() => _SettingNetworkPrinterState();
}

class _SettingNetworkPrinterState extends State<SettingNetworkPrinter> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              CardLabelSmall(Strings.networkPrinter),
              NetworkSettingForm(),
            ],
          ),
        ),
      ),
    );
  }
}

class NetworkSettingForm extends StatefulWidget {
  @override
  _NetworkSettingFormState createState() => _NetworkSettingFormState();
}

class _NetworkSettingFormState extends State<NetworkSettingForm> {
  final _formKey = GlobalKey<FormState>();
  final _ipController = TextEditingController();
  final _portController = TextEditingController();
  SettingBloc _settingBloc;

  @override
  void initState() {
    super.initState();
    _settingBloc = BlocProvider.of<SettingBloc>(context);
    _settingBloc.getNetworkPrinter().then((device) {
      _ipController.text = device?.ip ?? "";
      _portController.text = device?.port?.toString() ?? "";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                flex: 4,
                child: TextFormField(
                  controller: _ipController,
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: Strings.printerIpAddressExample,
                  ),
                  validator: (value) {
                    if (value.isEmpty) {
                      return Strings.msgPleaseEnterIp;
                    }
                    return null;
                  },
                ),
              ),
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: TextFormField(
                    keyboardType: TextInputType.number,
                    controller: _portController,
                    decoration: InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: Strings.port,
                    ),
                    validator: (value) {
                      if (value.isEmpty) {
                        return Strings.msgPleaseEnterPort;
                      }
                      return null;
                    },
                  ),
                ),
              )
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0, right: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                RaisedButton.icon(
                  icon: Icon(Icons.print),
                  label: Text(Strings.testPrint.toUpperCase()),
                  onPressed: () {
                    _settingBloc.testPrint(_ipController.text, int.tryParse(_portController.text));
                  },
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: RaisedButton.icon(
                    icon: Icon(Icons.save),
                    label: Text(Strings.save.toUpperCase()),
                    onPressed: () {
                      if (_formKey.currentState.validate()) {
                        _settingBloc.saveNetworkPrinter(
                            _ipController.text, int.tryParse(_portController.text));
                      }
                    },
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
