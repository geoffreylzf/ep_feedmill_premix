import 'package:ep_feedmill/bloc/bloc_base.dart';
import 'package:ep_feedmill/res/nav.dart';
import 'package:ep_feedmill/res/route.dart';
import 'package:ep_feedmill/res/string.dart';
import 'package:ep_feedmill/screen/home/bloc/home_bloc.dart';
import 'package:ep_feedmill/screen/home/widget/home_current_premix_plan_doc.dart';
import 'package:ep_feedmill/widget/card_label_small.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  HomeBloc homeBloc;

  @override
  void initState() {
    super.initState();
    homeBloc = HomeBloc();
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
                opacity: 0.05,
                child: Text(
                  "2",
                  style: TextStyle(fontSize: 600),
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
            child: CurrentPremixPlanDoc(),
          ),
        ),
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(4, 8, 8, 8),
            child: PremixCard(),
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            CardLabelSmall("Delivery Order"),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.assignment,
                    size: 40,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(Strings.document),
                  ),
                ],
              ),
            ),
            RaisedButton(
              onPressed: () {
                Navigator.pushNamed(context, Routes.premix);
              },
              child: Text(Strings.premix.toUpperCase()),
            )
          ],
        ),
      ),
    );
  }
}
