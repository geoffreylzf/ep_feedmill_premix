import 'dart:async';

import 'package:ep_feedmill/bloc/bloc_base.dart';
import 'package:ep_feedmill/res/string.dart';
import 'package:ep_feedmill/screen/premix/bloc/premix_bloc.dart';
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
  final _controller = new TextEditingController();
  Timer _debounce;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final premixBloc = BlocProvider.of<PremixBloc>(context);
    _controller.addListener(() {
      if (_debounce?.isActive ?? false) _debounce.cancel();
      _debounce = Timer(const Duration(milliseconds: 500), () {
        String text = _controller.text;
        if (text.isNotEmpty) {
          premixBloc.scan(int.tryParse(text));
          _controller.text = "";
        }
      });
    });
    return Padding(
      padding: const EdgeInsets.all(8),
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
              controller: _controller,
              decoration: InputDecoration(
                  border: OutlineInputBorder(), labelText: Strings.ingredient),
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
    final premixBloc = BlocProvider.of<PremixBloc>(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: StreamBuilder<SelectedItemPacking>(
          stream: premixBloc.selectedItemPackingStream,
          builder: (context, snapshot) {
            var isEntered = false;
            var firstLine = "Please press above and scan";
            var secondLine = "";

            if (snapshot.connectionState != ConnectionState.waiting) {
              if (snapshot.data != null) {
                isEntered = true;
                firstLine = snapshot.data.skuName;
                secondLine = snapshot.data.skuCode +
                    " (${snapshot.data.weight.toString()} kg)";
              }
            }

            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  isEntered ? Icons.landscape : Icons.arrow_upward,
                  size: 48,
                ),
                Column(
                  children: <Widget>[
                    Text(firstLine,
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold)),
                    Text(secondLine,
                        style:
                            TextStyle(fontSize: 16, color: Colors.grey[700])),
                  ],
                ),
                IconButton(
                  iconSize: 48,
                  icon: Icon(
                    isEntered ? Icons.cancel : Icons.arrow_upward,
                  ),
                  onPressed: () {
                    premixBloc.clearSelectedItemPacking();
                  },
                ),
              ],
            );
          }),
    );
  }
}
