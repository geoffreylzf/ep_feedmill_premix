import 'package:ep_feedmill/bloc/bloc_base.dart';
import 'package:ep_feedmill/bloc/bluetooth_bloc.dart';
import 'package:ep_feedmill/res/string.dart';
import 'package:ep_feedmill/screen/premix/bloc/premix_bloc.dart';
import 'package:ep_feedmill/screen/premix/widget/ingredient_list.dart';
import 'package:ep_feedmill/screen/premix/widget/scan.dart';
import 'package:ep_feedmill/screen/premix/widget/premix_temp.dart';
import 'package:ep_feedmill/screen/premix/widget/weighing.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class PremixScreen extends StatefulWidget {
  @override
  _PremixScreenState createState() => _PremixScreenState();
}

class _PremixScreenState extends State<PremixScreen>
    with SingleTickerProviderStateMixin
    implements BluetoothDelegate, PremixDelegate {
  PremixBloc premixBloc;
  BluetoothBloc bluetoothBloc;

  TabController _tabController;

  @override
  void initState() {
    super.initState();
    bluetoothBloc = BluetoothBloc(BluetoothType.Weighing, this);
    premixBloc = PremixBloc(this);
    _tabController = TabController(vsync: this, length: 2);
  }

  @override
  void onTabChange(int i) {
    _tabController.index = 1;
  }

  @override
  void onBluetoothError(String message) {
    showError(message);
  }

  @override
  void onPremixError(String message) {
    showError(message);
  }

  void showError(message) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(Strings.error),
            content: Text(message),
            actions: <Widget>[
              FlatButton(
                child: Text(Strings.close),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProviderTree(
      blocProviders: [
        BlocProvider<PremixBloc>(bloc: premixBloc),
        BlocProvider<BluetoothBloc>(bloc: bluetoothBloc),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: Text(Strings.premix),
          bottom: TabBar(
            controller: _tabController,
            tabs: [
              Tab(icon: Icon(Icons.view_list)),
              Tab(icon: Icon(FontAwesomeIcons.weight)),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: <Widget>[
            IngredientListTab(),
            WeighingTab(),
          ],
        ),
      ),
    );
  }
}

class IngredientListTab extends StatefulWidget {
  @override
  _IngredientListTabState createState() => _IngredientListTabState();
}

class _IngredientListTabState extends State<IngredientListTab> {
  @override
  Widget build(BuildContext context) {
    return IngredientList();
  }
}

class WeighingTab extends StatefulWidget {
  @override
  _WeighingTabState createState() => _WeighingTabState();
}

class _WeighingTabState extends State<WeighingTab> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Scan(),
        Divider(
          height: 0,
        ),
        Expanded(
          child: Row(
            children: <Widget>[
              Expanded(
                child: PremixTemp(),
              ),
              VerticalDivider(
                width: 0,
              ),
              Expanded(
                child: Weighing(),
              ),
            ],
          ),
        )
      ],
    );
  }
}
