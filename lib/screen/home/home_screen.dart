import 'package:ep_feedmill/bloc/bloc_base.dart';
import 'package:ep_feedmill/bloc/local_bloc.dart';
import 'package:ep_feedmill/main.dart';
import 'package:ep_feedmill/res/nav.dart';
import 'package:ep_feedmill/res/route.dart';
import 'package:ep_feedmill/res/string.dart';
import 'package:ep_feedmill/screen/home/home_bloc.dart';
import 'package:ep_feedmill/screen/home/widget/home_category_selection.dart';
import 'package:ep_feedmill/screen/home/widget/home_current_premix_plan_doc.dart';
import 'package:ep_feedmill/widget/card_label_small.dart';
import 'package:ep_feedmill/widget/local_check_box.dart';
import 'package:ep_feedmill/widget/simple_alert_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:package_info/package_info.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with RouteAware implements HomeDelegate {
  HomeBloc homeBloc;
  LocalBloc localBloc = LocalBloc();

  @override
  void onDialogMessage(String title, String message) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleAlertDialog(
            title: title,
            message: message,
          );
        });
  }

  @override
  void initState() {
    super.initState();
    homeBloc = HomeBloc(delegate: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context));
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    //refresh this page widget because no database listener
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return BlocProviderTree(
      blocProviders: [
        BlocProvider<HomeBloc>(bloc: homeBloc),
        BlocProvider<LocalBloc>(bloc: localBloc),
      ],
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(title: Text(Strings.appName)),
        body: Stack(
          children: <Widget>[
            Center(
              child: Opacity(
                opacity: 0.0,
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
    final localBloc = BlocProvider.of<LocalBloc>(context);
    localBloc.loadLocalChecked();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          flex: 3,
          child: Container(
            padding: EdgeInsets.fromLTRB(8, 8, 4, 8),
            child: Column(
              children: <Widget>[
                CategorySelection(),
                PremixCard(),
                UploadCard(),
                Expanded(
                  child: StoreConnector<int, String>(
                    converter: (store) => store.state.toString(),
                    builder: (ctx, count) {
                      return Center(
                        child: Text(
                          count,
                          style: TextStyle(fontSize: 160, fontWeight: FontWeight.bold),
                        ),
                      );
                    },
                  ),
                ),
                GroupBtn(),
                LocalCheckBox(localBloc: localBloc),
                VersionText(),
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

class UploadCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final homeBloc = BlocProvider.of<HomeBloc>(context);
    homeBloc.loadNoUploadCount();
    return Card(
      color: Colors.white70,
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            CardLabelSmall(Strings.pendingUpload),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  Icons.cloud_upload,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: StreamBuilder<int>(
                      stream: homeBloc.noUploadCountStream,
                      initialData: 0,
                      builder: (context, snapshot) {
                        return Text(
                          snapshot.data.toString(),
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: snapshot.data > 0
                                ? Theme.of(context).accentColor
                                : Theme.of(context).iconTheme.color,
                          ),
                        );
                      }),
                ),
              ],
            ),
            RaisedButton(
              onPressed: () {
                Navigator.pushNamed(context, Routes.upload);
              },
              child: Text(Strings.upload.toUpperCase()),
            )
          ],
        ),
      ),
    );
  }
}

class VersionText extends StatefulWidget {
  @override
  _VersionTextState createState() => _VersionTextState();
}

class GroupBtn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SizedBox(
        width: double.infinity,
        child: RaisedButton.icon(
            label: Text(Strings.group.toUpperCase()),
            icon: Icon(Icons.group_work),
            onPressed: () {
              Navigator.pushNamed(context, Routes.setting);
            }),
      ),
    );
  }
}

class _VersionTextState extends State<VersionText> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: FutureBuilder<PackageInfo>(
        future: PackageInfo.fromPlatform(),
        builder: (ctx, snapshot) {
          var version = "";
          if (snapshot.hasData) {
            version = "Version " + snapshot.data.version;
          }
          return Center(child: Text(version));
        },
      ),
    );
  }
}
