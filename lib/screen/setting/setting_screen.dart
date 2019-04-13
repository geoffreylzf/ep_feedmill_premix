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
            GroupCard(),
          ],
        ),
      ),
    );
  }
}

class GroupCard extends StatefulWidget {
  @override
  _GroupCardState createState() => _GroupCardState();
}

class _GroupCardState extends State<GroupCard> {
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
                    return Card(
                      color: Theme.of(context).primaryColorDark,
                      child: StoreConnector<int, Function(int)>(
                        converter: (store) {
                          return (groupNo) {
                            store.dispatch(SelectGroupNo(groupNo));
                          };
                        },
                        builder: (ctx, callback) {
                          return InkWell(
                            splashColor: Theme.of(context).primaryColorLight,
                            onTap: () {
                              callback(index + 1);
                              SharedPreferencesModule().saveGroupNo(index + 1);
                            },
                            child: Center(
                              child: Text(
                                '${index + 1}',
                                style: Theme.of(context)
                                    .textTheme
                                    .display3
                                    .apply(color: Colors.white),
                              ),
                            ),
                          );
                        },
                      ),
                    );
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
