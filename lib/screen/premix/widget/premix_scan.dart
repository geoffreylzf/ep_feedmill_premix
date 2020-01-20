import 'dart:async';

import 'package:ep_feedmill/bloc/bloc_base.dart';
import 'package:ep_feedmill/res/string.dart';
import 'package:ep_feedmill/screen/premix/bloc/premix_scan_bloc.dart';
import 'package:flutter/material.dart';

class Scan extends StatefulWidget {
  @override
  _ScanState createState() => _ScanState();
}

class _ScanState extends State<Scan> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        CodeInput(),
        SelectedIngredient(),
      ],
    );
  }
}

class CodeInput extends StatefulWidget {
  @override
  _CodeInputState createState() => _CodeInputState();
}

class _CodeInputState extends State<CodeInput> {
  final _scanController = TextEditingController();
  final _scanFocusNode = FocusNode();
  Timer _debounce;

  @override
  void dispose() {
    _scanController.dispose();
    _scanFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scanBloc = BlocProvider.of<PremixScanBloc>(context);
    _scanController.addListener(() {
      if (_debounce?.isActive ?? false) _debounce.cancel();
      _debounce = Timer(const Duration(milliseconds: 500), () {
        String text = _scanController.text;
        if (text.isNotEmpty) {
          scanBloc.scan(int.tryParse(text));
          _scanController.text = "";
        }
      });
    });

    scanBloc.scanFocusStream.listen((_) {
      try {
        FocusScope.of(context).requestFocus(_scanFocusNode);
      } catch (e) {
        print(e);
        //catch "Looking up a deactivated widget's ancestor is unsafe"
      }
    });

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              Icons.settings_overscan,
              size: 48,
            ),
          ),
          Expanded(
            child: TextFormField(
              keyboardType: TextInputType.numberWithOptions(),
              controller: _scanController,
              autofocus: true,
              focusNode: _scanFocusNode,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.all(12.0),
                border: OutlineInputBorder(),
                labelText: Strings.barcode,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SelectedIngredient extends StatefulWidget {
  @override
  _SelectedIngredientState createState() => _SelectedIngredientState();
}

class _SelectedIngredientState extends State<SelectedIngredient> {
  @override
  Widget build(BuildContext context) {
    final scanBloc = BlocProvider.of<PremixScanBloc>(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: StreamBuilder<SelectedItemPacking>(
          stream: scanBloc.selectedItemPackingStream,
          builder: (context, snapshot) {
            var leftIcon = Icons.arrow_upward;
            var rightIcon = Icons.arrow_upward;
            var iconColor = IconTheme.of(context).color;
            var firstLine = "Please press above and scan";
            var secondLine = "";
            var weight = "";

            if (snapshot.connectionState != ConnectionState.waiting) {
              if (snapshot.data != null) {
                if (snapshot.data.isError) {
                  leftIcon = Icons.error;
                  rightIcon = Icons.error;
                  iconColor = Theme.of(context).errorColor;
                  firstLine = snapshot.data.errorMessage;
                  secondLine = "";
                  weight = "";
                } else {
                  leftIcon = Icons.landscape;
                  rightIcon = Icons.cancel;
                  iconColor = Theme.of(context).primaryColor;
                  firstLine = snapshot.data.skuName;
                  secondLine = snapshot.data.skuCode;
                  weight = " (${snapshot.data.weight.toString()} kg)";
                }
              }
            }

            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(
                    leftIcon,
                    color: iconColor,
                    size: 48,
                  ),
                ),
                Column(
                  children: <Widget>[
                    Text(firstLine, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    RichText(
                      text: TextSpan(
                          text: secondLine,
                          style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                          children: [
                            TextSpan(
                                text: weight,
                                style: TextStyle(fontSize: 36, fontWeight: FontWeight.w800)),
                          ]),
                    ),
                  ],
                ),
                IconButton(
                  iconSize: 48,
                  icon: Icon(
                    rightIcon,
                    color: iconColor,
                  ),
                  onPressed: () {
                    scanBloc.clearSelectedItemPacking();
                  },
                ),
              ],
            );
          }),
    );
  }
}
