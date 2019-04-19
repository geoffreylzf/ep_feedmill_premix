import 'package:ep_feedmill/bloc/bloc_base.dart';
import 'package:ep_feedmill/db/dao/mrf_premix_plan_doc_dao.dart';
import 'package:ep_feedmill/res/string.dart';
import 'package:ep_feedmill/screen/plan/bloc/plan_bloc.dart';
import 'package:ep_feedmill/screen/plan/widget/plan_batch_selection.dart';
import 'package:ep_feedmill/widget/simple_alert_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class PlanScreen extends StatefulWidget {
  final int mrfPremixPlanDocId;

  PlanScreen({@required this.mrfPremixPlanDocId});

  @override
  _PlanScreenState createState() => _PlanScreenState();
}

class _PlanScreenState extends State<PlanScreen> implements PlanDelegate {
  PlanBloc planBloc;

  @override
  void onDialogMessage(String title, String message) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleAlertDialog(
            title: title,
            message: message,
            btnText: Strings.close.toUpperCase(),
          );
        });
  }

  @override
  void initState() {
    super.initState();
    planBloc = PlanBloc(
      delegate: this,
      mrfPremixPlanDocId: widget.mrfPremixPlanDocId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PlanBloc>(
      bloc: planBloc,
      child: Scaffold(
        appBar: AppBar(
          title: Text(Strings.premixPlanBatch),
        ),
        body: Column(
          children: <Widget>[
            PlanInfo(),
            Divider(),
            Expanded(
              child: BatchSelection(),
            ),
          ],
        ),
      ),
    );
  }
}

abstract class PlanDelegate {
  void onDialogMessage(String title, String message);
}

class PlanInfo extends StatefulWidget {
  @override
  _PlanInfoState createState() => _PlanInfoState();
}

class _PlanInfoState extends State<PlanInfo> {
  final remarkController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final planBloc = BlocProvider.of<PlanBloc>(context);
    return StreamBuilder<MrfPremixPlanDocWithInfo>(
        stream: planBloc.planDocStream,
        builder: (context, snapshot) {
          var recipeName = "";
          var docNo = "";
          var skuCodeName = "";
          remarkController.text = " ";

          if (snapshot.hasData) {
            final doc = snapshot.data;
            recipeName = doc.recipeName;
            docNo = "${doc.docNo} (${doc.docDate})";
            skuCodeName = "${doc.skuCode} / ${doc.skuName}";
            remarkController.text = doc.remarks;
          }
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Icon(
                        Icons.assignment,
                        size: 48,
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          recipeName,
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 24,
                          ),
                        ),
                        Text(
                          docNo,
                          style: TextStyle(fontSize: 12),
                        ),
                        Text(
                          skuCodeName,
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ],
                ),
                TextField(
                  controller: remarkController,
                  enabled: false,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(12.0),
                    border: OutlineInputBorder(),
                    labelText: Strings.remarks,
                  ),
                ),
              ],
            ),
          );
        });
  }
}
