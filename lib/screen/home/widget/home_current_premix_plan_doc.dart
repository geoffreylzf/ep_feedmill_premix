import 'dart:async';

import 'package:ep_feedmill/animation/slide_right_route.dart';
import 'package:ep_feedmill/bloc/bloc_base.dart';
import 'package:ep_feedmill/db/dao/mrf_premix_plan_doc_dao.dart';
import 'package:ep_feedmill/res/string.dart';
import 'package:ep_feedmill/screen/home/home_bloc.dart';
import 'package:ep_feedmill/screen/plan/plan_screen.dart';
import 'package:ep_feedmill/widget/card_label_small.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CurrentPremixPlanDoc extends StatefulWidget {
  @override
  _CurrentPremixPlanDocState createState() => _CurrentPremixPlanDocState();
}

class _CurrentPremixPlanDocState extends State<CurrentPremixPlanDoc> {

  final _scanController = TextEditingController();
  Timer _debounce;

  @override
  void dispose() {
    _scanController.dispose();
    super.dispose();
  }

  @override
  Card build(BuildContext context) {
    final homeBloc = BlocProvider.of<HomeBloc>(context);

    _scanController.addListener(() {
      if (_debounce?.isActive ?? false) _debounce.cancel();
      _debounce = Timer(const Duration(milliseconds: 500), () async {
        String text = _scanController.text;
        if (text.isNotEmpty) {
          _scanController.text = "";
          int planId = await homeBloc.scan(int.tryParse(text));
          if(planId != null){
            Navigator.push(
              context,
              SlideRightRoute(
                widget: PlanScreen(
                  mrfPremixPlanDocId: planId,
                ),
              ),
            );
          }
        }
      });
    });

    return Card(
      color: Colors.white54,
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            CardLabelSmall("Current Premix Plan Document"),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
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
            Expanded(child: PremixPlanDocList()),
            Row(
              children: <Widget>[
                Expanded(
                  child: RaisedButton(
                    onPressed: () async {
                      homeBloc.retrieveCurrentMrfPremixPlan();
                    },
                    child: const Text("Retrieve Premix Plan"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class PremixPlanDocList extends StatefulWidget {
  @override
  _PremixPlanDocListState createState() => _PremixPlanDocListState();
}

class _PremixPlanDocListState extends State<PremixPlanDocList> {
  @override
  Widget build(BuildContext context) {
    final homeBloc = BlocProvider.of<HomeBloc>(context);
    homeBloc.loadMrfPremixPlanDoc();
    return StreamBuilder<List<MrfPremixPlanDocWithInfo>>(
      stream: homeBloc.mrfPremixPlanDocListStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.data == null) {
          return Center(child: CircularProgressIndicator());
        }
        final list = snapshot.data;
        return ListView.builder(
          itemCount: list.length,
          itemBuilder: (context, position) {
            final doc = list[position];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blueGrey.withOpacity(0.8),
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
                child: InkWell(
                  splashColor: Theme.of(context).accentColor,
                  onTap: () async {
                    await Future.delayed(Duration(milliseconds: 100));
                    Navigator.push(
                      context,
                      SlideRightRoute(
                        widget: PlanScreen(
                          mrfPremixPlanDocId: doc.id,
                        ),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                doc.recipeName,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "${doc.docNo} (${doc.docDate})",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                doc.skuName ?? "",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              )
                            ],
                          ),
                        ),
                        FutureBuilder<int>(
                          initialData: 0,
                          future: homeBloc.getBatchDoneCount(doc.id),
                          builder: (ctx, snapshot) {
                            return Container(
                              width: 64,
                              height: 32,
                              decoration: new BoxDecoration(
                                color: Theme.of(context).accentColor,
                                shape: BoxShape.rectangle,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8)),
                              ),
                              child: Center(
                                  child: Text(
                                "${snapshot.data.toString()} / ${doc.totalBatch.toString()}",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              )),
                            );
                          },
                        )
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
