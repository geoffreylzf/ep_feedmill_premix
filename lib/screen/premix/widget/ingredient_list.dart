import 'package:ep_feedmill/bloc/bloc_base.dart';
import 'package:ep_feedmill/screen/premix/bloc/premix_bloc.dart';
import 'package:ep_feedmill/model/item_packing.dart';
import 'package:ep_feedmill/res/string.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class IngredientList extends StatefulWidget {
  @override
  _IngredientListState createState() => _IngredientListState();
}

class _IngredientListState extends State<IngredientList> {
  @override
  Widget build(BuildContext context) {
    final _premixBloc = BlocProvider.of<PremixBloc>(context);
    return StreamBuilder<List<ItemPacking>>(
        stream: _premixBloc.itemPackingListStream,
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
                      Text("1.25 Kg"),
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
                        )),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: RaisedButton.icon(
                            icon: Icon(FontAwesomeIcons.weight),
                            onPressed: () {
                              _premixBloc.manualSelectItemPacking(list[position].id);
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
