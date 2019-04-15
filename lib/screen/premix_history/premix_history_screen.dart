import 'package:ep_feedmill/bloc/bloc_base.dart';
import 'package:ep_feedmill/res/string.dart';
import 'package:ep_feedmill/screen/premix_history/bloc/premix_history_bloc.dart';
import 'package:flutter/material.dart';

class PremixHistoryScreen extends StatefulWidget {
  @override
  _PremixHistoryScreenState createState() => _PremixHistoryScreenState();
}

class _PremixHistoryScreenState extends State<PremixHistoryScreen> {
  PremixHistoryBloc phBloc;

  @override
  void initState() {
    super.initState();
    phBloc = PremixHistoryBloc();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      bloc: phBloc,
      child: Scaffold(
        appBar: AppBar(
          title: Text(Strings.premixHistory),
        ),
      ),
    );
  }
}
