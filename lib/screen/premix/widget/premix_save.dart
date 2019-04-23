import 'package:ep_feedmill/animation/slide_right_route.dart';
import 'package:ep_feedmill/bloc/bloc_base.dart';
import 'package:ep_feedmill/db/dao/premix_dao.dart';
import 'package:ep_feedmill/res/string.dart';
import 'package:ep_feedmill/screen/premix/bloc/premix_bloc.dart';
import 'package:ep_feedmill/screen/print_preview/print_preview_screen.dart';
import 'package:ep_feedmill/util/print_util.dart';
import 'package:ep_feedmill/widget/simple_confirm_dialog.dart';
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
        onPressed: () {
          premixBloc.validate().then((r) {
            if (r) {
              _confirmSave(context, premixBloc);
            }
          });
        },
        label: Text(
          Strings.save.toUpperCase(),
        ),
      ),
    );
  }

  _confirmSave(BuildContext mainContext, PremixBloc premixBloc) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleConfirmDialog(
          title: "Save?",
          message: "Edit is not allow after save.",
          btnPositiveText: Strings.save,
          vcb: () async {
            final premixId = await premixBloc.savePremix();
            final printText = await PrintUtil().generatePremixReceipt(premixId);
            final barcodeText = (await PremixDao().getById(premixId)).uuid;
            _goPrintPreview(mainContext, printText, barcodeText);
          },
        );
      },
    );
  }

  _goPrintPreview(
      BuildContext ctx, String printText, String barcodeText) async {
    Navigator.of(ctx).pushReplacement(
      SlideRightRoute(
        widget: PrintPreviewScreen(
          printText: printText,
          barcodeText: barcodeText,
        ),
      ),
    );
  }
}
