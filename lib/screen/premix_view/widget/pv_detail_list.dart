import 'package:ep_feedmill/bloc/bloc_base.dart';
import 'package:ep_feedmill/db/dao/premix_detail_dao.dart';
import 'package:ep_feedmill/res/string.dart';
import 'package:ep_feedmill/screen/premix_view/premix_view_bloc.dart';
import 'package:ep_feedmill/widget/list_header.dart';
import 'package:flutter/material.dart';

class DetailList extends StatefulWidget {
  @override
  _DetailListState createState() => _DetailListState();
}

class _DetailListState extends State<DetailList> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        DetailHeader(),
        Divider(height: 0),
        Expanded(child: DetailData()),
        Divider(height: 0),
        DetailFooter(),
      ],
    );
  }
}

class DetailHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: <Widget>[
          Expanded(flex: 4, child: Container()),
          Expanded(child: ListHeader(Strings.grossWeightKg)),
          Expanded(child: ListHeader(Strings.tareWeightKg)),
          Expanded(child: ListHeader(Strings.netWeightKg)),
        ],
      ),
    );
  }
}

class DetailFooter extends StatefulWidget {
  @override
  _DetailFooterState createState() => _DetailFooterState();
}

class _DetailFooterState extends State<DetailFooter> {
  @override
  Widget build(BuildContext context) {
    final pvBloc = BlocProvider.of<PremixViewBloc>(context);
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColorDark,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: <Widget>[
            Expanded(
              flex: 5,
              child: Text(
                Strings.total,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            Expanded(
              child: StreamBuilder<double>(
                  stream: pvBloc.ttlNetWgtStream,
                  builder: (context, snapshot) {
                    var ttl = 0.0;
                    if (snapshot.hasData) {
                      ttl = snapshot.data;
                    }
                    return Text(
                      ttl.toStringAsFixed(2),
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    );
                  }),
            ),
          ],
        ),
      ),
    );
  }
}

class DetailData extends StatefulWidget {
  @override
  _DetailDataState createState() => _DetailDataState();
}

class _DetailDataState extends State<DetailData> {
  @override
  Widget build(BuildContext context) {
    final pvBloc = BlocProvider.of<PremixViewBloc>(context);
    return StreamBuilder<List<PremixDetailWithInfo>>(
        stream: pvBloc.premixDetailListStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          final list = snapshot.data;

          return ListView.separated(
            itemCount: list.length,
            separatorBuilder: (ctx, index) => Divider(height: 0),
            itemBuilder: (ctx, position) {
              final detail = list[position];
              return Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      flex: 4,
                      child: Row(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Icon(Icons.landscape),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(detail.skuName,
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                Text(
                                  detail.skuCode,
                                  style: TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Text(
                        detail.grossWeight.toStringAsFixed(2),
                        textAlign: TextAlign.right,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        detail.tareWeight.toStringAsFixed(2),
                        textAlign: TextAlign.right,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        detail.netWeight.toStringAsFixed(2),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        });
  }
}
