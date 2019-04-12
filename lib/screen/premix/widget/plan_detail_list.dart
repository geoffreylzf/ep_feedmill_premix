import 'package:ep_feedmill/bloc/bloc_base.dart';
import 'package:ep_feedmill/db/dao/mrf_premix_plan_detail_dao.dart';
import 'package:ep_feedmill/res/string.dart';
import 'package:ep_feedmill/screen/premix/bloc/premix_bloc.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class PlanDetailList extends StatefulWidget {
  @override
  _PlanDetailListState createState() => _PlanDetailListState();
}

class _PlanDetailListState extends State<PlanDetailList> {
  @override
  Widget build(BuildContext context) {
    final _premixBloc = BlocProvider.of<PremixBloc>(context);
    return StreamBuilder<List<MrfPremixPlanDetailWithInfo>>(
        stream: _premixBloc.planDetailWithInfoListStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          var list = snapshot.data;
          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (context, position) => ExpansionTile(
                  key: PageStorageKey(list[position].id.toString()),
                  leading: Icon(Icons.landscape),
                  title: Row(
                    children: <Widget>[
                      Expanded(child: Text(list[position].skuName)),
                      Text("${list[position].formulaWeight.toStringAsFixed(2)} Kg"),
                    ],
                  ),
                  children: [
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 16.0),
                            child: Column(
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
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: RaisedButton.icon(
                            icon: Icon(FontAwesomeIcons.weight),
                            onPressed: () {
                              _premixBloc
                                  .manualSelectItemPacking(list[position].itemPackingId);
                            },
                            label: Text("Enter Weight"),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
          );
        });
  }
}
