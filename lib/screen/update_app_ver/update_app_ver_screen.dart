import 'package:ep_feedmill/bloc/bloc_base.dart';
import 'package:ep_feedmill/bloc/local_bloc.dart';
import 'package:ep_feedmill/screen/update_app_ver/update_app_ver_bloc.dart';
import 'package:ep_feedmill/widget/local_check_box.dart';
import 'package:ep_feedmill/widget/simple_alert_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class UpdateAppVerScreen extends StatefulWidget {
  @override
  _UpdateAppVerScreenState createState() => _UpdateAppVerScreenState();
}

class _UpdateAppVerScreenState extends State<UpdateAppVerScreen> implements UpdateAppVerDelegate {
  UpdateAppVerBloc bloc;
  LocalBloc localBloc = LocalBloc();

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
  void initState() {
    super.initState();
    bloc = UpdateAppVerBloc(
      delegate: this,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProviderTree(
        blocProviders: [
          BlocProvider<UpdateAppVerBloc>(bloc: bloc),
          BlocProvider<LocalBloc>(bloc: localBloc),
        ],
        child: Scaffold(
          appBar: AppBar(title: Text('Update App Version')),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                StreamBuilder<int>(
                    stream: bloc.verCodeStream,
                    initialData: 0,
                    builder: (context, snapshot) {
                      return Text("Version Code : ${snapshot.data}");
                    }),
                StreamBuilder<String>(
                    stream: bloc.verNameStream,
                    initialData: "",
                    builder: (context, snapshot) {
                      return Text("Version Name : ${snapshot.data}");
                    }),
                RaisedButton.icon(
                  onPressed: () => bloc.updateApp(),
                  icon: Icon(Icons.update),
                  label: Text("UPDATE APP VERSION"),
                ),
                LocalCheckBox(
                  localBloc: localBloc,
                )
              ],
            ),
          ),
        ));
  }
}
