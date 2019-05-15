import 'package:ep_feedmill/bloc/bloc_base.dart';
import 'package:ep_feedmill/model/table/log.dart';
import 'package:ep_feedmill/screen/upload/upload_bloc.dart';
import 'package:flutter/material.dart';

class UploadLog extends StatefulWidget {
  @override
  _UploadLogState createState() => _UploadLogState();
}

class _UploadLogState extends State<UploadLog> {
  @override
  Widget build(BuildContext context) {
    final uploadBloc = BlocProvider.of<UploadBloc>(context);
    return StreamBuilder<List<Log>>(
        stream: uploadBloc.uploadLogListStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          final list = snapshot.data;
          return ListView.separated(
            separatorBuilder: (ctx, index) => Divider(height: 0),
            itemCount: list.length,
            itemBuilder: (ctx, position) {
              final log = list[position];
              return ListTile(
                title: Text(log.remark),
                subtitle: Text(log.timestamp),
              );
            },
          );
        });
  }
}
