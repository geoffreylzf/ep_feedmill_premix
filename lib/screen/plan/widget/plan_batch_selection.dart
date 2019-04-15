import 'package:ep_feedmill/animation/slide_right_route.dart';
import 'package:ep_feedmill/bloc/bloc_base.dart';
import 'package:ep_feedmill/db/dao/mrf_premix_plan_doc_dao.dart';
import 'package:ep_feedmill/res/string.dart';
import 'package:ep_feedmill/screen/plan/bloc/plan_bloc.dart';
import 'package:ep_feedmill/screen/premix/premix_screen.dart';
import 'package:ep_feedmill/widget/simple_alert_dialog.dart';
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
                return BatchCard(
                  mrfPremixPlanDocId: snapshot.data.id,
                  batchNo: index + 1,
                );
              },
            ),
          );
        });
  }
}

class BatchCard extends StatefulWidget {
  final int mrfPremixPlanDocId, batchNo;

  BatchCard({
    @required this.mrfPremixPlanDocId,
    @required this.batchNo,
  });

  @override
  _BatchCardState createState() => _BatchCardState();
}

class _BatchCardState extends State<BatchCard> {
  @override
  Widget build(BuildContext context) {
    final planBloc = BlocProvider.of<PlanBloc>(context);
    return FutureBuilder<bool>(
      initialData: false,
      future: planBloc.getIsPremixDone(widget.batchNo),
      builder: (ctx, snapshot) {
        return Stack(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                color: Theme.of(context).primaryColorLight,
                child: InkWell(
                  splashColor: Theme.of(context).accentColor,
                  onTap: () async {
                    if (!snapshot.data) {
                      await Future.delayed(Duration(milliseconds: 100));
                      Navigator.push(
                        context,
                        SlideRightRoute(
                          widget: PremixScreen(
                            mrfPremixPlanDocId: widget.mrfPremixPlanDocId,
                            batchNo: widget.batchNo,
                          ),
                        ),
                      );
                    } else {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return SimpleAlertDialog(
                              title: Strings.error,
                              message: "Batch already done.",
                              btnText: Strings.close.toUpperCase(),
                            );
                          });
                    }
                  },
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          Strings.batch.toUpperCase(),
                          style: Theme.of(context).textTheme.headline,
                        ),
                        Text(
                          '${widget.batchNo}',
                          style: Theme.of(context).textTheme.display3,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            snapshot.data
                ? Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: new BoxDecoration(
                        color: Theme.of(context).accentColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.done_all,
                        color: Colors.white,
                      ),
                    ),
                  )
                : Container(),
          ],
        );
      },
    );
  }
}
