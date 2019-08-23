import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:ep_feedmill/bloc/bloc_base.dart';
import 'package:ep_feedmill/bloc/bluetooth_bloc.dart';
import 'package:ep_feedmill/screen/premix/bloc/premix_scan_bloc.dart';
import 'package:ep_feedmill/screen/premix/bloc/premix_temp_bloc.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class PremixWeighingBloc extends BlocBase {
  final _isWeighingByBtSubject = BehaviorSubject<bool>.seeded(false);
  final _isTaringSubject = BehaviorSubject<bool>.seeded(false);

  final _grossWeightSubject = BehaviorSubject<double>();
  final _tareWeightSubject = BehaviorSubject<double>();

  Stream<bool> get isWeighingByBtStream => _isWeighingByBtSubject.stream;

  Stream<bool> get isTaringStream => _isTaringSubject.stream;

  Stream<double> get grossWeightStream => _grossWeightSubject.stream;

  Stream<double> get tareWeightStream => _tareWeightSubject.stream;

  Stream<double> get netWeightStream =>
      Observable.combineLatest2(grossWeightStream, tareWeightStream, (double g, double t) {
        var netWeight = g;
        if (getIsTaring()) {
          netWeight = g - t;
        }
        return netWeight;
      });

  @override
  void dispose() {
    _isWeighingByBtSubject.close();
    _isTaringSubject.close();

    _grossWeightSubject.close();
    _tareWeightSubject.close();

    advancedPlayer = null;
  }

  BluetoothBloc _bluetoothBloc;
  PremixTempBloc _tempBloc;
  PremixScanBloc _scanBloc;

  AudioPlayer advancedPlayer;

  PremixWeighingBloc({
    @required BluetoothBloc bluetoothBloc,
    @required PremixTempBloc tempBloc,
    @required PremixScanBloc scanBloc,
  }) {
    _bluetoothBloc = bluetoothBloc;
    _tempBloc = tempBloc;
    _scanBloc = scanBloc;

    _bluetoothBloc.weighingResultStream.listen((data) {
      final weight = double.tryParse(data);
      if(!_grossWeightSubject.isClosed){
        _grossWeightSubject?.add(weight);
      }
    });

    _tempBloc.totalWeightStream.listen((weight) {
      _tareWeightSubject.add(weight);
    });

    Observable(netWeightStream).throttle(Duration(seconds: 1)).listen((n) async {
      if (n != null) {
        final scan = _scanBloc.getSelectedItemPacking();
        if (scan != null && !scan.isError) {
          final weight = scan.weight;
          if (weight >= 0.2 && n < weight && n >= weight - 0.1) {
            advancedPlayer = await AudioCache().play("audios/not-bad.mp3");
          } else if (n == weight) {
            advancedPlayer = await AudioCache().play("audios/definite.mp3");
          } else if (n > weight) {
            advancedPlayer = await AudioCache().play("audios/hold-on.mp3");
          }
        }
      }
    });
  }

  setIsWeighingByBt(bool b) {
    _isWeighingByBtSubject.add(b);
  }

  bool getIsWeighingByBt() {
    return _isWeighingByBtSubject.value;
  }

  setIsTaring(bool b) {
    _isTaringSubject.add(b);
  }

  bool getIsTaring() {
    return _isTaringSubject.value;
  }
}
