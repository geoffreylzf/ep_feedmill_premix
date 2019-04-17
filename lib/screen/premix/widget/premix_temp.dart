import 'package:ep_feedmill/bloc/bloc_base.dart';
import 'package:ep_feedmill/db/dao/temp_premix_detail_dao.dart';
import 'package:ep_feedmill/res/string.dart';
import 'package:ep_feedmill/screen/premix/bloc/premix_bloc.dart';
import 'package:ep_feedmill/screen/premix/bloc/premix_temp_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class PremixTemp extends StatefulWidget {
  @override
  _PremixTempState createState() => _PremixTempState();
}

class _PremixTempState extends State<PremixTemp> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(child: TempPremixDetailList()),
        Row(
          children: <Widget>[
            Expanded(child: TotalWeight()),
          ],
        ),
      ],
    );
  }
}

class TempPremixDetailList extends StatefulWidget {
  @override
  _TempPremixDetailListState createState() => _TempPremixDetailListState();
}

class _TempPremixDetailListState extends State<TempPremixDetailList> {
  @override
  Widget build(BuildContext context) {
    final premixBloc = BlocProvider.of<PremixBloc>(context);
    final tempBloc = BlocProvider.of<PremixTempBloc>(context);
    return StreamBuilder<List<TempPremixDetailWithInfo>>(
      stream: tempBloc.tempPremixDetailListStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        var list = snapshot.data;
        return ListView.builder(
          itemCount: list.length,
          itemBuilder: (context, position) => Dismissible(
                key: PageStorageKey(list[position].id.toString()),
                onDismissed: (direction) {
                  premixBloc.deleteTempPremixDetail(list[position].id);
                },
                confirmDismiss: (direction) async {
                  return position == 0;
                },
                background: Container(
                  color: Colors.red,
                  child: Icon(Icons.clear),
                ),
                child: ExpansionTile(
                  key: PageStorageKey(list[position].id.toString()),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Text("${list.length - position}"),
                      ),
                      Flexible(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            list[position].skuName,
                            overflow: TextOverflow.clip,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      Text(
                        "${list[position].netWeight.toStringAsFixed(2)} Kg",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    ],
                  ),
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(Strings.skuCode,
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey)),
                              Text(
                                list[position].skuCode,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                              SmallText(
                                  "G.W. : ${list[position].grossWeight.toStringAsFixed(2)}"),
                              SmallText(
                                  "T.W. : ${list[position].tareWeight.toStringAsFixed(2)}"),
                              SmallText(
                                  "N.W. : ${list[position].netWeight.toStringAsFixed(2)}"),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
        );
      },
    );
  }
}

class SmallText extends StatelessWidget {
  final String text;

  SmallText(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class TotalWeight extends StatefulWidget {
  @override
  _TotalWeightState createState() => _TotalWeightState();
}

class _TotalWeightState extends State<TotalWeight> {
  @override
  Widget build(BuildContext context) {
    final tempBloc = BlocProvider.of<PremixTempBloc>(context);
    return Container(
      color: Colors.blueGrey[900],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              "Total Weight",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            StreamBuilder<double>(
                stream: tempBloc.totalWeightStream,
                builder: (context, snapshot) {
                  var totalWeight = 0.0;
                  if (snapshot.hasData) {
                    totalWeight = snapshot.data;
                  }
                  return Text(
                    "${totalWeight.toStringAsFixed(2)} Kg",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }),
          ],
        ),
      ),
    );
  }
}
