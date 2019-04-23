import 'package:ep_feedmill/animation/slide_right_route.dart';
import 'package:ep_feedmill/bloc/bloc_base.dart';
import 'package:ep_feedmill/db/dao/premix_dao.dart';
import 'package:ep_feedmill/res/string.dart';
import 'package:ep_feedmill/screen/premix_view/premix_view_bloc.dart';
import 'package:ep_feedmill/screen/premix_view/widget/pv_detail_list.dart';
import 'package:ep_feedmill/screen/premix_view/widget/pv_premix_info.dart';
import 'package:ep_feedmill/screen/print_preview/print_preview_screen.dart';
import 'package:ep_feedmill/util/print_util.dart';
import 'package:ep_feedmill/widget/simple_confirm_dialog.dart';
import 'package:flutter/material.dart';

class PremixViewScreen extends StatefulWidget {
  final int premixId;

  PremixViewScreen({@required this.premixId});

  @override
  _PremixViewScreenState createState() => _PremixViewScreenState();
}

class _PremixViewScreenState extends State<PremixViewScreen> {
  PremixViewBloc pvBloc;

  @override
  void initState() {
    super.initState();
    pvBloc = PremixViewBloc(premixId: widget.premixId);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PremixViewBloc>(
      bloc: pvBloc,
      child: Scaffold(
        appBar: AppBar(
          title: PvTitle(),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.print),
              onPressed: () async {
                final printText =
                    await PrintUtil().generatePremixReceipt(widget.premixId);
                final barcodeText =
                    (await PremixDao().getById(widget.premixId)).uuid;
                _goPrintPreview(context, printText, barcodeText);
              },
            ),
            PopupMenuButton(
              onSelected: (v) {
                _deletePremix();
              },
              itemBuilder: (ctx) {
                return [
                  PopupMenuItem(
                    value: 1,
                    child: Text(Strings.delete),
                  )
                ];
              },
            )
          ],
        ),
        body: Stack(
          children: <Widget>[
            PvDeleteIcon(),
            Column(
              children: <Widget>[
                PremixInfo(),
                Divider(height: 0),
                Expanded(child: DetailList()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  _goPrintPreview(BuildContext ctx, String printText, String qrText) {
    Navigator.of(ctx).push(
      SlideRightRoute(
        widget: PrintPreviewScreen(
          printText: printText,
          barcodeText: qrText,
        ),
      ),
    );
  }

  _deletePremix() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleConfirmDialog(
          title: "Delete?",
          message: "This will delete the entered premix.",
          btnPositiveText: Strings.delete,
          vcb: () {
            pvBloc.deletePremix();
          },
        );
      },
    );
  }
}

class PvDeleteIcon extends StatefulWidget {
  @override
  _PvDeleteIconState createState() => _PvDeleteIconState();
}

class _PvDeleteIconState extends State<PvDeleteIcon> {
  @override
  Widget build(BuildContext context) {
    final pvBloc = BlocProvider.of<PremixViewBloc>(context);
    return Positioned.fill(
      child: StreamBuilder<PremixWithInfo>(
          stream: pvBloc.premixStream,
          builder: (context, snapshot) {
            var opacity = 0.0;
            if (snapshot.hasData) {
              if (snapshot.data.isDelete == 1) {
                opacity = 0.1;
              }
            }
            return Opacity(
              opacity: opacity,
              child: Icon(
                Icons.delete_outline,
                color: Colors.red,
                size: 400,
              ),
            );
          }),
    );
  }
}

class PvTitle extends StatefulWidget {
  @override
  _PvTitleState createState() => _PvTitleState();
}

class _PvTitleState extends State<PvTitle> {
  @override
  Widget build(BuildContext context) {
    final pvBloc = BlocProvider.of<PremixViewBloc>(context);
    return StreamBuilder<PremixWithInfo>(
        stream: pvBloc.premixStream,
        builder: (context, snapshot) {
          var recipeName = "";
          var batchNo = 0;
          var groupNo = 0;
          if (snapshot.hasData) {
            final premix = snapshot.data;
            recipeName = premix.recipeName;
            batchNo = premix.batchNo;
            groupNo = premix.groupNo;
          }
          return Row(
            children: <Widget>[
              Text(recipeName),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Chip(
                  backgroundColor: Theme.of(context).primaryColorLight,
                  label: Text(
                    "${Strings.batch} $batchNo",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Chip(
                  backgroundColor: Theme.of(context).primaryColorDark,
                  label: Text(
                    "${Strings.group} $groupNo",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              )
            ],
          );
        });
  }
}
