import 'package:ep_feedmill/module/shared_preferences_module.dart';
import 'package:ep_feedmill/res/string.dart';
import 'package:ep_feedmill/store/store.dart';
import 'package:ep_feedmill/widget/card_label_small.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

class SettingScreen extends StatefulWidget {
  @override
  _SettingScreenState createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Strings.setting),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            CardGroup(),
          ],
        ),
      ),
    );
  }
}

class CardGroup extends StatefulWidget {
  @override
  _CardGroupState createState() => _CardGroupState();
}

class _CardGroupState extends State<CardGroup> {
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
            Flexible(
              child: GridView.count(
                shrinkWrap: true,
                crossAxisCount: 4,
                children: List.generate(
                  8,
                  (index) {
                    return GroupNoCard(index + 1);
                  },
                ),
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
                onTap: () {
                  callback(widget.index);
                  SharedPreferencesModule().saveGroupNo(widget.index);
                },
                child: Center(
                  child: Text(
                    '${widget.index}',
                    style: Theme.of(context)
                        .textTheme
                        .display3
                        .apply(color: widget.index != groupNo ? Colors.white : Colors.black),
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
