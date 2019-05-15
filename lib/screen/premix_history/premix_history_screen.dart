import 'package:ep_feedmill/animation/slide_right_route.dart';
import 'package:ep_feedmill/bloc/bloc_base.dart';
import 'package:ep_feedmill/model/table/premix.dart';
import 'package:ep_feedmill/res/string.dart';
import 'package:ep_feedmill/screen/premix_history/premix_history_bloc.dart';
import 'package:ep_feedmill/screen/premix_view/premix_view_screen.dart';
import 'package:flutter/material.dart';

class PremixHistoryScreen extends StatefulWidget {
  @override
  _PremixHistoryScreenState createState() => _PremixHistoryScreenState();
}

class _PremixHistoryScreenState extends State<PremixHistoryScreen> {
  PremixHistoryBloc phBloc;

  @override
  void initState() {
    super.initState();
    phBloc = PremixHistoryBloc();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      bloc: phBloc,
      child: Scaffold(
        appBar: AppBar(
          title: Text(Strings.premixHistory),
        ),
        body: HistoryList(),
      ),
    );
  }
}

class HistoryList extends StatefulWidget {
  @override
  _HistoryListState createState() => _HistoryListState();
}

class _HistoryListState extends State<HistoryList> {
  @override
  Widget build(BuildContext context) {
    final phBloc = BlocProvider.of<PremixHistoryBloc>(context);
    phBloc.loadPremixList();
    return StreamBuilder<List<Premix>>(
        stream: phBloc.premixListStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          final list = snapshot.data;
          return ListView.separated(
            shrinkWrap: true,
            separatorBuilder: (ctx, index) => Divider(height: 0),
            itemCount: list.length,
            itemBuilder: (ctx, position) {
              final premix = list[position];
              return ListTile(
                trailing: Column(
                  children: <Widget>[
                    Text(Strings.batch + " : " + premix.batchNo.toString()),
                    Text(Strings.group + " : " + premix.groupNo.toString()),
                  ],
                ),
                title: Row(
                  children: <Widget>[
                    Text(premix.recipeName),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child:
                          premix.isDeleted() ? Icon(Icons.delete) : Container(),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: premix.isUploaded()
                          ? Icon(Icons.cloud_upload)
                          : Container(),
                    ),
                  ],
                ),
                subtitle: Row(
                  children: <Widget>[
                    Text(premix.docNo),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Icon(Icons.access_time, size: 16),
                    ),
                    Text(premix.timestamp),
                  ],
                ),
                onTap: () async {
                  await Future.delayed(Duration(milliseconds: 100));
                  Navigator.push(
                    context,
                    SlideRightRoute(
                      widget: PremixViewScreen(
                        premixId: premix.id,
                      ),
                    ),
                  );
                },
              );
            },
          );
        });
  }
}
