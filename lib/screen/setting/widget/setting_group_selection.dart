import 'package:ep_feedmill/module/shared_preferences_module.dart';
import 'package:ep_feedmill/store/store.dart';
import 'package:ep_feedmill/widget/card_label_small.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

class GroupSelection extends StatefulWidget {
  @override
  _GroupSelectionState createState() => _GroupSelectionState();
}

class _GroupSelectionState extends State<GroupSelection> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            CardLabelSmall("Group No"),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 4,
              children: List.generate(
                8,
                (index) {
                  return GroupNoCard(index + 1);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GroupNoCard extends StatefulWidget {
  final int index;

  GroupNoCard(this.index);

  @override
  _GroupNoCardState createState() => _GroupNoCardState();
}

class _GroupNoCardState extends State<GroupNoCard> {
  @override
  Widget build(BuildContext context) {
    return StoreConnector<int, int>(
      converter: (store) => store.state,
      builder: (ctx, groupNo) {
        return Card(
          color: widget.index != groupNo
              ? Theme.of(context).primaryColorDark
              : Theme.of(context).primaryColorLight,
          child: StoreConnector<int, Function(int)>(
            converter: (store) {
              return (groupNo) {
                store.dispatch(SelectGroupNo(groupNo));
              };
            },
            builder: (ctx, callback) {
              return InkWell(
                splashColor: Theme.of(context).accentColor,
                onTap: () async {
                  callback(widget.index);
                  await SharedPreferencesModule().saveGroupNo(widget.index);
                  await Future.delayed(Duration(milliseconds: 200));
                  Navigator.pop(ctx);
                },
                child: Center(
                  child: Text(
                    '${widget.index}',
                    style: Theme.of(context).textTheme.display3.apply(
                        color: widget.index != groupNo
                            ? Colors.white
                            : Colors.black),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
