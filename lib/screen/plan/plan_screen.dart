import 'package:ep_feedmill/res/string.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class PlanScreen extends StatefulWidget {
  final int mrfPremixPlanDocId;

  PlanScreen(this.mrfPremixPlanDocId);

  @override
  _PlanScreenState createState() => _PlanScreenState();
}

class _PlanScreenState extends State<PlanScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Strings.premixPlanBatch),
      ),
      body: Column(
        children: <Widget>[
          PlanInfo(),
          Divider(),
          Expanded(child: BatchSelection()),
        ],
      ),
    );
  }
}

class PlanInfo extends StatefulWidget {
  @override
  _PlanInfoState createState() => _PlanInfoState();
}

class _PlanInfoState extends State<PlanInfo> {
  final remarkController = TextEditingController();

  @override
  void initState() {
    super.initState();
    remarkController.text = "This is remark";
  }

  @override
  Widget build(BuildContext context) {
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
                    "8-315B BFPSV1905-0111",
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 24,
                    ),
                  ),
                  Text(
                    "DOC NO (2019-04-11)",
                    style: TextStyle(fontSize: 12),
                  ),
                  Text(
                    "ITEM PACKING",
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
  }
}

class BatchSelection extends StatefulWidget {
  @override
  _BatchSelectionState createState() => _BatchSelectionState();
}

class _BatchSelectionState extends State<BatchSelection> {
  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      padding: const EdgeInsets.all(8.0),
      children: List.generate(
        10,
        (index) {
          return Card(
            color: Theme.of(context).primaryColorLight,
            child: InkWell(
              splashColor: Theme.of(context).accentColor,
              onTap: (){},
              child: Center(
                child: Text(
                  'Batch ${index + 1}',
                  style: Theme.of(context).textTheme.display1,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
