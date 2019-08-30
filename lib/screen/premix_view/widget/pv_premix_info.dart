import 'package:ep_feedmill/bloc/bloc_base.dart';
import 'package:ep_feedmill/db/dao/premix_dao.dart';
import 'package:ep_feedmill/screen/premix_view/premix_view_bloc.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class PremixInfo extends StatefulWidget {
  @override
  _PremixInfoState createState() => _PremixInfoState();
}

class _PremixInfoState extends State<PremixInfo> {
  @override
  Widget build(BuildContext context) {
    final pvBloc = BlocProvider.of<PremixViewBloc>(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: StreamBuilder<PremixWithInfo>(
          stream: pvBloc.premixStream,
          builder: (context, snapshot) {
            var docNo = "";
            var skuCode = "";
            var skuName = "";
            var timestamp = "";
            var isUpload = false;

            if (snapshot.hasData) {
              final premix = snapshot.data;
              docNo = premix.docNo;
              skuCode = premix.skuCode ?? "";
              skuName = premix.skuName ?? "";
              timestamp = premix.timestamp ;
              isUpload = premix.isUploaded();
            }

            return Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Icon(
                    FontAwesomeIcons.mortarPestle,
                    size: 48,
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        skuName,
                        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                      ),
                      Text(skuCode, style: TextStyle(fontSize: 12)),
                      Text(docNo, style: TextStyle(fontSize: 12)),
                      Row(
                        children: <Widget>[
                          Icon(Icons.access_time, size: 16),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(timestamp, style: TextStyle(fontSize: 12)),
                          )
                        ],
                      )
                    ],
                  ),
                ),
                isUpload
                    ? Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Icon(
                          Icons.cloud_upload,
                        ),
                      )
                    : Container(),
              ],
            );
          }),
    );
  }
}
