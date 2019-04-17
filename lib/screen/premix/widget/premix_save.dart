import 'package:ep_feedmill/animation/slide_right_route.dart';
import 'package:ep_feedmill/bloc/bloc_base.dart';
import 'package:ep_feedmill/res/string.dart';
import 'package:ep_feedmill/screen/premix/bloc/premix_bloc.dart';
import 'package:ep_feedmill/screen/print_preview/print_preview_screen.dart';
import 'package:ep_feedmill/util/print_util.dart';
import 'package:flutter/material.dart';

class Save extends StatefulWidget {
  @override
  _SaveState createState() => _SaveState();
}

class _SaveState extends State<Save> {
  @override
  Widget build(BuildContext context) {
    final premixBloc = BlocProvider.of<PremixBloc>(context);
    return Center(
      child: RaisedButton.icon(
        icon: Icon(Icons.save),
        onPressed: () async {
          final premixId = await premixBloc.savePremix();
          final printText = await PrintUtil().generatePremixReceipt(premixId);
          goPrintPreview(context, printText);
        },
        label: Text(
          Strings.save.toUpperCase(),
        ),
      ),
    );
  }

  goPrintPreview(BuildContext ctx, String printText) async {
    Navigator.of(ctx).pushReplacement(
      SlideRightRoute(
        widget: PrintPreviewScreen(
          printText: printText,
          qrText: "TUTUTUTUT",
        ),
      ),
    );
  }
}
