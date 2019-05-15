import 'package:ep_feedmill/bloc/bloc_base.dart';
import 'package:ep_feedmill/bloc/local_bloc.dart';
import 'package:ep_feedmill/res/string.dart';
import 'package:ep_feedmill/screen/upload/upload_bloc.dart';
import 'package:ep_feedmill/widget/local_check_box.dart';
import 'package:flutter/material.dart';

class UploadStatus extends StatefulWidget {
  @override
  _UploadStatusState createState() => _UploadStatusState();
}

class _UploadStatusState extends State<UploadStatus> {
  @override
  Widget build(BuildContext context) {
    final uploadBloc = BlocProvider.of<UploadBloc>(context);
    final localBloc = BlocProvider.of<LocalBloc>(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Expanded(
          flex: 2,
          child: Container(),
        ),
        Text(Strings.msgPendingNotYetUploadData),
        StreamBuilder<int>(
            stream: uploadBloc.noUploadCountStream,
            initialData: 0,
            builder: (context, snapshot) {
              return Text(
                snapshot.data.toString(),
                style: TextStyle(fontSize: 200),
              );
            }),
        RaisedButton.icon(
            onPressed: () {
              uploadBloc.upload();
            },
            icon: Icon(Icons.cloud_upload),
            label: Text(Strings.upload.toUpperCase())),
        Expanded(
          flex: 3,
          child: LocalCheckBox(
            localBloc: localBloc,
          ),
        ),
      ],
    );
  }
}
