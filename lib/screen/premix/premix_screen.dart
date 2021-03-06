import 'package:ep_feedmill/bloc/bloc_base.dart';
import 'package:ep_feedmill/bloc/bluetooth_bloc.dart';
import 'package:ep_feedmill/db/dao/mrf_premix_plan_doc_dao.dart';
import 'package:ep_feedmill/res/string.dart';
import 'package:ep_feedmill/screen/premix/bloc/premix_bloc.dart';
import 'package:ep_feedmill/screen/premix/bloc/premix_scan_bloc.dart';
import 'package:ep_feedmill/screen/premix/bloc/premix_temp_bloc.dart';
import 'package:ep_feedmill/screen/premix/bloc/premix_weighing_bloc.dart';
import 'package:ep_feedmill/screen/premix/widget/premix_plan_detail_list.dart';
import 'package:ep_feedmill/screen/premix/widget/premix_save.dart';
import 'package:ep_feedmill/screen/premix/widget/premix_scan.dart';
import 'package:ep_feedmill/screen/premix/widget/premix_temp.dart';
import 'package:ep_feedmill/screen/premix/widget/premix_weighing.dart';
import 'package:ep_feedmill/widget/simple_alert_dialog.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class PremixScreen extends StatefulWidget {
  final int mrfPremixPlanDocId;
  final int batchNo;
  final String barcode;

  PremixScreen({
    this.mrfPremixPlanDocId,
    this.batchNo,
    this.barcode,
  });

  @override
  _PremixScreenState createState() => _PremixScreenState();
}

class _PremixScreenState extends State<PremixScreen>
    with SingleTickerProviderStateMixin
    implements BluetoothDelegate, PremixDelegate {
  PremixBloc premixBloc;
  PremixScanBloc scanBloc;
  PremixTempBloc tempBloc;
  PremixWeighingBloc weighingBloc;
  BluetoothBloc bluetoothBloc;

  TabController _tabController;

  @override
  void initState() {
    super.initState();
    bluetoothBloc = BluetoothBloc(BluetoothType.Weighing, this);
    scanBloc = PremixScanBloc(
      delegate: this,
      mrfPremixPlanDocId: widget.mrfPremixPlanDocId,
    );
    tempBloc = PremixTempBloc(mrfPremixPlanDocId: widget.mrfPremixPlanDocId);
    weighingBloc = PremixWeighingBloc(
      tempBloc: tempBloc,
      bluetoothBloc: bluetoothBloc,
      scanBloc: scanBloc,
    );
    premixBloc = PremixBloc(
      delegate: this,
      scanBloc: scanBloc,
      tempBloc: tempBloc,
      weighingBloc: weighingBloc,
      mrfPremixPlanDocId: widget.mrfPremixPlanDocId,
      batchNo: widget.batchNo,
      barcode: widget.barcode,
    );
    _tabController = TabController(vsync: this, length: 3);
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
          return SimpleAlertDialog(
            title: Strings.error,
            message: message,
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProviderTree(
      blocProviders: [
        BlocProvider<BluetoothBloc>(bloc: bluetoothBloc),
        BlocProvider<PremixBloc>(bloc: premixBloc),
        BlocProvider<PremixScanBloc>(bloc: scanBloc),
        BlocProvider<PremixTempBloc>(bloc: tempBloc),
        BlocProvider<PremixWeighingBloc>(bloc: weighingBloc),
      ],
      child: WillPopScope(
        onWillPop: () => _onBackPressed(context),
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            title: StreamBuilder<MrfPremixPlanDocWithInfo>(
                stream: premixBloc.planDocStream,
                builder: (context, snapshot) {
                  var recipeName = "";
                  if (snapshot.hasData) {
                    recipeName = snapshot.data.recipeName;
                  }
                  return Row(
                    children: <Widget>[
                      Text(recipeName),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Chip(
                          backgroundColor: Theme.of(context).primaryColorLight,
                          label: Text(
                            "${Strings.batch} ${premixBloc.batchNo}",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                      )
                    ],
                  );
                }),
            bottom: TabBar(
              controller: _tabController,
              tabs: [
                Tab(icon: Icon(Icons.view_list)),
                Tab(icon: Icon(FontAwesomeIcons.weight)),
                Tab(icon: Icon(Icons.save)),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: <Widget>[
              PlanDetailListTab(),
              WeighingTab(),
              SaveTab(),
            ],
          ),
        ),
      ),
    );
  }
}

abstract class PremixDelegate {
  void onTabChange(int i);

  void onPremixError(String message);
}

class PlanDetailListTab extends StatefulWidget {
  @override
  _PlanDetailListTabState createState() => _PlanDetailListTabState();
}

class _PlanDetailListTabState extends State<PlanDetailListTab> {
  @override
  Widget build(BuildContext context) {
    return PlanDetailList();
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

class SaveTab extends StatefulWidget {
  @override
  _SaveTabState createState() => _SaveTabState();
}

class _SaveTabState extends State<SaveTab> {
  @override
  Widget build(BuildContext context) {
    return Save();
  }
}

Future<bool> _onBackPressed(BuildContext context) {
  return showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Back to batch selection?'),
              content: Text('Unsaved premix will be discard...'),
              actions: <Widget>[
                FlatButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: new Text(Strings.cancel.toUpperCase()),
                ),
                FlatButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(Strings.back.toUpperCase()),
                ),
              ],
            );
          }) ??
      false;
}
