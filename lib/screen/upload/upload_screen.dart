import 'package:ep_feedmill/bloc/bloc_base.dart';
import 'package:ep_feedmill/bloc/local_bloc.dart';
import 'package:ep_feedmill/res/string.dart';
import 'package:ep_feedmill/screen/upload/upload_bloc.dart';
import 'package:ep_feedmill/screen/upload/widget/upload_log.dart';
import 'package:ep_feedmill/screen/upload/widget/upload_status.dart';
import 'package:ep_feedmill/widget/simple_alert_dialog.dart';
import 'package:ep_feedmill/widget/simple_loading_dialog.dart';
import 'package:flutter/material.dart';

class UploadScreen extends StatefulWidget {
  @override
  _UploadScreenState createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> implements UploadDelegate {
  UploadBloc uploadBloc;
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
    uploadBloc = UploadBloc(delegate: this);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProviderTree(
      blocProviders: [
        BlocProvider<UploadBloc>(bloc: uploadBloc),
        BlocProvider<LocalBloc>(bloc: localBloc),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: Text(Strings.upload),
        ),
        body: Stack(
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(child: UploadLog()),
                VerticalDivider(width: 0),
                Expanded(child: UploadStatus()),
              ],
            ),
            SimpleLoadingDialog(uploadBloc.isLoadingStream),
          ],
        ),
      ),
    );
  }
}

abstract class UploadDelegate {
  void onDialogMessage(String title, String message);
}
