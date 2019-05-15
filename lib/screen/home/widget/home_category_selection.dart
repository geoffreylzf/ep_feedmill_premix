import 'package:ep_feedmill/bloc/bloc_base.dart';
import 'package:ep_feedmill/res/string.dart';
import 'package:ep_feedmill/screen/home/home_bloc.dart';
import 'package:ep_feedmill/widget/card_label_small.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CategorySelection extends StatefulWidget {
  @override
  _CategorySelectionState createState() => _CategorySelectionState();
}

class _CategorySelectionState extends State<CategorySelection> {
  @override
  Widget build(BuildContext context) {
    final homeBloc = BlocProvider.of<HomeBloc>(context);
    return Card(
      color: Colors.white70,
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            CardLabelSmall(Strings.formulaCategory),
            CategoryRow(
              icon: FontAwesomeIcons.drumstickBite,
              desc: Strings.broiler,
              stream: homeBloc.broilerCheckedStream,
              callback: (b) {
                homeBloc.setBroilerChecked(b);
              },
            ),
            CategoryRow(
              icon: FontAwesomeIcons.egg,
              desc: Strings.breeder,
              stream: homeBloc.breederCheckedStream,
              callback: (b) {
                homeBloc.setBreederChecked(b);
              },
            ),
            CategoryRow(
              icon: FontAwesomeIcons.piggyBank,
              desc: Strings.swine,
              stream: homeBloc.swineCheckedStream,
              callback: (b) {
                homeBloc.setSwineChecked(b);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class CategoryRow extends StatefulWidget {
  final IconData icon;
  final String desc;
  final Stream<bool> stream;
  final Function(bool b) callback;

  CategoryRow({
    @required this.icon,
    @required this.desc,
    @required this.stream,
    @required this.callback,
  });

  @override
  _CategoryRowState createState() => _CategoryRowState();
}

class _CategoryRowState extends State<CategoryRow> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
        stream: widget.stream,
        initialData: false,
        builder: (context, snapshot) {
          return Row(
            children: <Widget>[
              Checkbox(
                value: snapshot.data,
                onChanged: (bool b) {
                  widget.callback(b);
                },
              ),
              Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Icon(widget.icon),
                  ),
                ],
              ),
              Text(widget.desc),
            ],
          );
        });
  }
}
