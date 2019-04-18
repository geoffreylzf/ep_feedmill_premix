import 'package:ep_feedmill/bloc/bloc_base.dart';
import 'package:ep_feedmill/bloc/bluetooth_bloc.dart';
import 'package:ep_feedmill/screen/premix/bloc/premix_temp_bloc.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class PremixWeighingBloc extends BlocBase {
  final _isWeighingByBtSubject = BehaviorSubject<bool>.seeded(false);
  final _isTaringSubject = BehaviorSubject<bool>.seeded(true);

  final _grossWeightSubject = BehaviorSubject<double>();
  final _tareWeightSubject = BehaviorSubject<double>();

  Stream<bool> get isWeighingByBtStream => _isWeighingByBtSubject.stream;

  Stream<bool> get isTaringStream => _isTaringSubject.stream;

  Stream<double> get grossWeightStream => _grossWeightSubject.stream;

  Stream<double> get tareWeightStream => _tareWeightSubject.stream;

  Stream<double> get netWeightStream =>
      Observable.combineLatest2(grossWeightStream, tareWeightStream,
          (double g, double t) {
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
  }

  BluetoothBloc _bluetoothBloc;
  PremixTempBloc _tempBloc;

  PremixWeighingBloc({
    @required BluetoothBloc bluetoothBloc,
    @required PremixTempBloc tempBloc,
  }) {
    _bluetoothBloc = bluetoothBloc;
    _tempBloc = tempBloc;

    _bluetoothBloc.weighingResultStream.listen((data) {
      final weight = double.tryParse(data);
      _grossWeightSubject.add(weight);
    });

    _tempBloc.totalWeightStream.listen((weight) {
      _tareWeightSubject.add(weight);
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
