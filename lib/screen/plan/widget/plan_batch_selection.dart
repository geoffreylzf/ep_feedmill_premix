import 'package:ep_feedmill/animation/slide_right_route.dart';
import 'package:ep_feedmill/bloc/bloc_base.dart';
import 'package:ep_feedmill/db/dao/mrf_premix_plan_doc_dao.dart';
import 'package:ep_feedmill/screen/plan/bloc/plan_bloc.dart';
import 'package:ep_feedmill/screen/premix/premix_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class BatchSelection extends StatefulWidget {
  @override
  _BatchSelectionState createState() => _BatchSelectionState();
}

class _BatchSelectionState extends State<BatchSelection> {
  @override
  Widget build(BuildContext context) {
    final planBloc = BlocProvider.of<PlanBloc>(context);
    return StreamBuilder<MrfPremixPlanDocWithInfo>(
        stream: planBloc.planDocStream,
        builder: (context, snapshot) {
          var batchCount = 0;

          if (snapshot.hasData) {
            batchCount = snapshot.data.totalBatch;
          }

          return GridView.count(
            crossAxisCount: 3,
            padding: const EdgeInsets.all(8.0),
            children: List.generate(
              batchCount,
              (index) {
                return Card(
                  color: Theme.of(context).primaryColorLight,
                  child: InkWell(
                    splashColor: Theme.of(context).accentColor,
                    onTap: () async {
                      await Future.delayed(Duration(milliseconds: 100));
                      Navigator.push(
                        context,
                        SlideRightRoute(
                          widget: PremixScreen(
                            mrfPremixPlanDocId: snapshot.data.id,
                            batchNo: index + 1,
                          ),
                        ),
                      );
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          "Batch",
                          style: Theme.of(context).textTheme.headline,
                        ),
                        Text(
                          '${index + 1}',
                          style: Theme.of(context).textTheme.display3,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        });
  }
}
