import 'package:ep_feedmill/bloc/bloc_base.dart';
import 'package:ep_feedmill/res/nav.dart';
import 'package:ep_feedmill/res/route.dart';
import 'package:ep_feedmill/res/string.dart';
import 'package:ep_feedmill/screen/home/bloc/home_bloc.dart';
import 'package:ep_feedmill/screen/home/widget/home_category_selection.dart';
import 'package:ep_feedmill/screen/home/widget/home_current_premix_plan_doc.dart';
import 'package:ep_feedmill/widget/card_label_small.dart';
import 'package:ep_feedmill/widget/simple_alert_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> implements HomeDelegate {
  HomeBloc homeBloc;

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
    homeBloc = HomeBloc(delegate: this);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      bloc: homeBloc,
      child: Scaffold(
        appBar: AppBar(title: Text(Strings.appName)),
        body: Stack(
          children: <Widget>[
            Center(
              child: Opacity(
                opacity: 0.20,
                child: StoreConnector<int, String>(
                  converter: (store) => store.state.toString(),
                  builder: (ctx, count) {
                    return Text(
                      count,
                      style: TextStyle(fontSize: 600),
                    );
                  },
                ),
              ),
            ),
            Dashboard(),
          ],
        ),
        drawer: NavDrawerStart(),
      ),
    );
  }
}

abstract class HomeDelegate {
  void onDialogMessage(String title, String message);
}

class Dashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          flex: 3,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 4, 8),
            child: Column(
              children: <Widget>[
                CategorySelection(),
                PremixCard(),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 5,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(4, 8, 8, 8),
            child: CurrentPremixPlanDoc(),
          ),
        ),
      ],
    );
  }
}

class PremixCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white70,
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            CardLabelSmall(Strings.premix),
            Row(
              children: <Widget>[
                Icon(
                  Icons.history,
                  size: 40,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(Strings.history),
                ),
              ],
            ),
            RaisedButton(
              onPressed: () {
                Navigator.pushNamed(context, Routes.premixHistory);
              },
              child: Text(Strings.premix.toUpperCase()),
            )
          ],
        ),
      ),
    );
  }
}
