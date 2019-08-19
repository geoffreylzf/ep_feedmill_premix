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
  PlanCheckListBloc pclList;

  @override
  void initState() {
    super.initState();
    pclList = PlanCheckListBloc(mixin: this);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      bloc: pclList,
      child: Scaffold(
        appBar: AppBar(
          title: Text(Strings.planCheckList),
        ),
        body: Column(
          children: <Widget>[
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
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: <Widget>[
                      Expanded(
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
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: detailList.length + 1,
                  itemBuilder: (ctx, position) {
                    if (position == 0) {
                      return Container(
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
                      );
                    }
                    final detail = detailList[position - 1];
                    return Row(
                      children: [
                        Expanded(child: Center(child: Text(detail.groupNo.toString()))),
                        Expanded(child: Center(child: Text(detail.totalBatch.toString()))),
                        Expanded(child: Center(child: Text(detail.completeBatch.toString()))),
                        if (detail.completeBatch != 0)
                          Expanded(
                            child: Center(
                              child: Checkbox(
                                value: detail.isVerify == 1,
                                onChanged: (b) {
                                  if (b) {
                                    detail.isVerify = 1;
                                  } else {
                                    detail.isVerify = 0;
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
                  },
                ),
              ],
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
