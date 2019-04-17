import 'package:ep_feedmill/bloc/bloc_base.dart';
import 'package:ep_feedmill/bloc/bluetooth_bloc.dart';
import 'package:ep_feedmill/screen/premix/bloc/premix_temp_bloc.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class PremixWeighingBloc extends BlocBase {
  final _isWeighingByBtSubject = BehaviorSubject<bool>.seeded(false);

  final _grossWeightSubject = BehaviorSubject<double>();
  final _tareWeightSubject = BehaviorSubject<double>();
  final _netWeightSubject = BehaviorSubject<double>();

  Stream<bool> get isWeighingByBtStream => _isWeighingByBtSubject.stream;

  Stream<double> get grossWeightStream => _grossWeightSubject.stream;

  Stream<double> get tareWeightStream => _tareWeightSubject.stream;

  Stream<double> get netWeightStream => _netWeightSubject.stream;

  @override
  void dispose() {
    _isWeighingByBtSubject.close();
    _grossWeightSubject.close();
    _tareWeightSubject.close();
    _netWeightSubject.close();
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
      _netWeightSubject.add(weight);
    });

    _tempBloc.totalWeightStream.listen((weight){
      _tareWeightSubject.add(weight);
    });
  }

  setIsWeighingByBt(bool b) {
    _isWeighingByBtSubject.add(b);
  }

  bool getIsWeighingByBt() {
    return _isWeighingByBtSubject.value;
  }
}
