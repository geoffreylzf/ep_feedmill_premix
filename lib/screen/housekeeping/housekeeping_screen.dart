import 'package:ep_feedmill/bloc/bloc_base.dart';
import 'package:ep_feedmill/bloc/local_bloc.dart';
import 'package:ep_feedmill/res/string.dart';
import 'package:ep_feedmill/screen/housekeeping/housekeeping_bloc.dart';
import 'package:ep_feedmill/widget/local_check_box.dart';
import 'package:ep_feedmill/widget/simple_alert_dialog.dart';
import 'package:ep_feedmill/widget/simple_loading_dialog.dart';
import 'package:flutter/material.dart';

class HousekeepingScreen extends StatefulWidget {
  @override
  _HousekeepingScreenState createState() => _HousekeepingScreenState();
}

class _HousekeepingScreenState extends State<HousekeepingScreen>
    implements HousekeepingDelegate {
  HousekeepingBloc hkBloc;
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
    hkBloc = HousekeepingBloc(delegate: this);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProviderTree(
      blocProviders: [
        BlocProvider<HousekeepingBloc>(bloc: hkBloc),
        BlocProvider<LocalBloc>(bloc: localBloc),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: Text(Strings.houseKeeping),
        ),
        body: Stack(
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                HousekeepingList(),
                ActionPanel(),
              ],
            ),
            SimpleLoadingDialog(hkBloc.isLoadingStream),
          ],
        ),
      ),
    );
  }
}

abstract class HousekeepingDelegate {
  void onDialogMessage(String title, String message);
}

class HousekeepingList extends StatefulWidget {
  @override
  _HousekeepingListState createState() => _HousekeepingListState();
}

class _HousekeepingListState extends State<HousekeepingList> {
  @override
  Widget build(BuildContext context) {
    final hkBloc = BlocProvider.of<HousekeepingBloc>(context);
    return Column(
      children: <Widget>[
        HkRow("Item Packing", hkBloc.ipCountStream),
        HkRow("Mrf Formula Category", hkBloc.fcCountStream),
      ],
    );
  }
}

class HkRow extends StatefulWidget {
  final String desc;
  final Stream<int> stream;

  HkRow(this.desc, this.stream);

  @override
  _HkRowState createState() => _HkRowState();
}

class _HkRowState extends State<HkRow> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 36),
      child: Container(
        padding: const EdgeInsets.all(16),
        color: Theme.of(context).primaryColorLight,
        child: StreamBuilder<int>(
          initialData: 0,
          stream: widget.stream,
          builder: (context, snapshot) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(widget.desc),
                Text(
                  snapshot.data.toString(),
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class ActionPanel extends StatefulWidget {
  @override
  _ActionPanelState createState() => _ActionPanelState();
}

class _ActionPanelState extends State<ActionPanel> {
  @override
  Widget build(BuildContext context) {
    final hkBloc = BlocProvider.of<HousekeepingBloc>(context);
    final localBloc = BlocProvider.of<LocalBloc>(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        LocalCheckBox(
          localBloc: localBloc,
        ),
        RaisedButton.icon(
          onPressed: () {
            hkBloc.retrieveAll();
          },
          icon: Icon(Icons.cloud_download),
          label: Text(Strings.retrieveHousekeeping.toUpperCase()),
        ),
      ],
    );
  }
}
