import 'package:ep_feedmill/bloc/bloc_base.dart';
import 'package:ep_feedmill/res/string.dart';
import 'package:ep_feedmill/screen/upload/upload_bloc.dart';
import 'package:ep_feedmill/screen/upload/widget/upload_status.dart';
import 'package:ep_feedmill/widget/simple_alert_dialog.dart';
import 'package:flutter/material.dart';

class UploadScreen extends StatefulWidget {
  @override
  _UploadScreenState createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> implements UploadDelegate {

  UploadBloc uploadBloc;

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
    uploadBloc = UploadBloc(delegate: this);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      bloc: uploadBloc,
      child: Scaffold(
        appBar: AppBar(
          title: Text(Strings.upload),
        ),
        body: Row(
          children: <Widget>[
            Expanded(child: Container()),
            VerticalDivider(width: 0),
            Expanded(child: UploadStatus()),
          ],
        ),
      ),
    );
  }
}

abstract class UploadDelegate {
  void onDialogMessage(String title, String message);
}
