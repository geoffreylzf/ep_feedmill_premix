import 'package:ep_feedmill/animation/slide_right_route.dart';
import 'package:ep_feedmill/bloc/bloc_base.dart';
import 'package:ep_feedmill/model/table/mrf_premix_plan_doc.dart';
import 'package:ep_feedmill/screen/home/bloc/home_bloc.dart';
import 'package:ep_feedmill/screen/plan/plan_screen.dart';
import 'package:ep_feedmill/widget/card_label_small.dart';
import 'package:flutter/material.dart';

class CurrentPremixPlanDoc extends StatefulWidget {
  @override
  _CurrentPremixPlanDocState createState() => _CurrentPremixPlanDocState();
}

class _CurrentPremixPlanDocState extends State<CurrentPremixPlanDoc> {
  @override
  Card build(BuildContext context) {
    final homeBloc = BlocProvider.of<HomeBloc>(context);
    return Card(
      color: Colors.white70,
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            CardLabelSmall("Current Premix Plan Document"),
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
    return StreamBuilder<List<MrfPremixPlanDoc>>(
      stream: homeBloc.mrfPremixPlanDocListStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        final list = snapshot.data;
        return ListView.builder(
          itemCount: list.length,
          itemBuilder: (context, position) {
            final doc = list[position];
            return Column(
              children: <Widget>[
                position == 0 ? Divider(height: 0) : Container(),
                InkWell(
                  child: ListTile(
                    dense: true,
                    isThreeLine: false,
                    title: Text(doc.recipeName),
                    subtitle: Text(doc.docNo),
                    trailing: Icon(Icons.keyboard_arrow_right),
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
                  ),
                ),
                Divider(height: 0),
              ],
            );
          },
        );
      },
    );
  }
}
