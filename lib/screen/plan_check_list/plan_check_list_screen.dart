import 'dart:async';

import 'package:ep_feedmill/bloc/bloc_base.dart';
import 'package:ep_feedmill/mixin/simple_alert_dialog_mixin.dart';
import 'package:ep_feedmill/model/plan_check.dart';
import 'package:ep_feedmill/res/string.dart';
import 'package:ep_feedmill/screen/plan_check_list/plan_check_list_bloc.dart';
import 'package:flutter/material.dart';

class PlanCheckListScreen extends StatefulWidget {
  @override
  _PlanCheckListScreenState createState() => _PlanCheckListScreenState();
}

class _PlanCheckListScreenState extends State<PlanCheckListScreen> with SimpleAlertDialogMixin {
  PlanCheckListBloc pclListBloc;

  final _scanController = TextEditingController();
  Timer _debounce;

  @override
  void initState() {
    super.initState();
    pclListBloc = PlanCheckListBloc(mixin: this);
  }

  @override
  void dispose() {
    _scanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    _scanController.addListener(() {
      if (_debounce?.isActive ?? false) _debounce.cancel();
      _debounce = Timer(const Duration(milliseconds: 500), () async {
        String text = _scanController.text;
        if (text.isNotEmpty) {
          _scanController.text = "";
          await pclListBloc.filterPlanCheckList(int.tryParse(text));
        }
      });
    });

    return BlocProvider(
      bloc: pclListBloc,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text(Strings.planCheckList),
        ),
        body: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 8, top: 8, right: 8),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Icon(
                      Icons.settings_overscan,
                    ),
                  ),
                  Expanded(
                    child: TextFormField(
                      keyboardType: TextInputType.numberWithOptions(),
                      controller: _scanController,
                      autofocus: true,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.all(12.0),
                        border: OutlineInputBorder(),
                        labelText: Strings.barcode,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(child: PlanList()),
            BtnList(),
          ],
        ),
      ),
    );
  }
}

class PlanList extends StatefulWidget {
  @override
  _PlanListState createState() => _PlanListState();
}

class _PlanListState extends State<PlanList> {
  @override
  Widget build(BuildContext context) {
    final pclBloc = BlocProvider.of<PlanCheckListBloc>(context);
    return StreamBuilder<List<PlanCheck>>(
      stream: pclBloc.planCheckListStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.data == null) {
          return Center(child: CircularProgressIndicator());
        }
        final list = snapshot.data;
        if (list.length == 0) {
          return Center(child: Text('No data for plan check list'));
        }
        return ListView.builder(
          itemCount: list.length,
          itemBuilder: (ctx, position) {
            final planCheck = list[position];
            final detailList = planCheck.detailList;

            final detailRowList = detailList.map((d) {
              return Row(
                children: [
                  Expanded(child: Center(child: Text(d.groupNo.toString()))),
                  Expanded(child: Center(child: Text(d.totalBatch.toString()))),
                  Expanded(child: Center(child: Text(d.completeBatch.toString()))),
                  if (d.completeBatch != 0)
                    Expanded(
                      child: Center(
                        child: Checkbox(
                          value: d.isVerify == 1,
                          onChanged: (b) {
                            if (b) {
                              d.isVerify = 1;
                            } else {
                              d.isVerify = 0;
                            }
                            pclBloc.tickGroupVerify();
                          },
                        ),
                      ),
                    )
                  else
                    Expanded(child: Container(height: 32))
                ],
              );
            });

            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(border: Border.all(color: Colors.blueAccent)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            flex: 7,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(planCheck.recipeName,
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                                Text(planCheck.skuName,
                                    style: TextStyle(color: Colors.black87, fontSize: 14)),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(planCheck.docNo, style: TextStyle(fontSize: 12)),
                                Text(planCheck.docDate, style: TextStyle(fontSize: 16)),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    Container(
                      color: Colors.black,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            SimpleHeader('Group'),
                            SimpleHeader('Total Batch'),
                            SimpleHeader('Complete'),
                            SimpleHeader('Verify'),
                          ],
                        ),
                      ),
                    ),
                    ...detailRowList,
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class SimpleHeader extends StatelessWidget {
  final String text;

  SimpleHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: Center(
            child: Text(
      this.text,
      style: TextStyle(color: Colors.white),
    )));
  }
}

class BtnList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final pclBloc = BlocProvider.of<PlanCheckListBloc>(context);
    return Container(
      color: Colors.blue[100],
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        child: Row(
          children: [
            Expanded(
              child: StreamBuilder<bool>(
                  stream: pclBloc.isForCheckStream,
                  builder: (context, snapshot) {
                    return Column(
                      children: <Widget>[
                        RadioListTile<bool>(
                          dense: true,
                          value: true,
                          groupValue: snapshot.data,
                          title: Text("For Check"),
                          onChanged: (value) {
                            pclBloc.setForCheck(value);
                          },
                        ),
                        RadioListTile<bool>(
                          dense: true,
                          value: false,
                          groupValue: snapshot.data,
                          title: Text("For Uncheck"),
                          onChanged: (value) {
                            pclBloc.setForCheck(value);
                          },
                        )
                      ],
                    );
                  }),
            ),
            Container(
              width: 8,
            ),
            Expanded(
              child: RaisedButton.icon(
                  icon: Icon(Icons.refresh),
                  onPressed: () {
                    pclBloc.refreshPlanCheckList();
                  },
                  label: Text(Strings.refresh.toUpperCase())),
            ),
            Container(
              width: 8,
            ),
            Expanded(
              child: RaisedButton.icon(
                  icon: Icon(Icons.save),
                  onPressed: () {
                    pclBloc.savePlanCheckList();
                  },
                  label: Text(Strings.save.toUpperCase())),
            ),
          ],
        ),
      ),
    );
  }
}
