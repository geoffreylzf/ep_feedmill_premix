import 'package:ep_feedmill/bloc/bloc_base.dart';
import 'package:ep_feedmill/db/dao/item_packing_dao.dart';
import 'package:ep_feedmill/db/dao/temp_premix_detail_dao.dart';
import 'package:ep_feedmill/model/item_packing.dart';
import 'package:ep_feedmill/model/temp_premix_detail.dart';
import 'package:rxdart/rxdart.dart';
import 'package:vibrate/vibrate.dart';

class PremixBloc extends BlocBase {
  final _itemPackingListSubject = BehaviorSubject<List<ItemPacking>>();
  final _tempPremixDetailListSubject =
      BehaviorSubject<List<TempPremixDetailWithIp>>();

  final _totalWeightSubject = BehaviorSubject<double>();

  final _selectedItemPackingSubject = BehaviorSubject<SelectedItemPacking>();
  final _isItemPackingSelectedSubject = BehaviorSubject<bool>.seeded(false);

  final _isWeighingByBtSubject = BehaviorSubject<bool>.seeded(false);

  PremixDelegate _delegate;

  PremixBloc(PremixDelegate delegate) {
    _loadItemPackingList();
    _loadTempPremixDetailList();
    _delegate = delegate;
  }

  _loadItemPackingList() async {
    final list = await ItemPackingDao().getAllNotInTemp();
    _itemPackingListSubject.add(list);
  }

  _loadTempPremixDetailList() async {
    final list = await TempPremixDetailDao().getAll();
    var totalWeight = 0.0;
    if (list.isNotEmpty) {
      totalWeight = list.map((c) => c.netWeight).reduce((a, b) => a + b);
    }
    _tempPremixDetailListSubject.add(list);
    _totalWeightSubject.add(totalWeight);
  }

  setIsWeighingByBt(bool b) {
    _isWeighingByBtSubject.add(b);
  }

  clearSelectedItemPacking() {
    _selectedItemPackingSubject.add(null);
    _isItemPackingSelectedSubject.add(false);
  }

  manualSelectItemPacking(int itemPackingId) {
    scan(itemPackingId);
    _delegate.onTabChange(1);
  }

  scan(int itemPackingId) async {
    if (itemPackingId == null) {
      _selectedItemPackingSubject.add(SelectedItemPacking.error(
          errorMessage: "Invalid ingredient barcode"));
      return;
    }
    final itemPacking = await ItemPackingDao().getById(itemPackingId);
    if (itemPacking == null) {
      _selectedItemPackingSubject.add(SelectedItemPacking.error(
          errorMessage: "Ingredient barcode not exist"));
      return;
    }

    final temp = await TempPremixDetailDao().getByItemPackingId(itemPackingId);
    if (temp != null) {
      _selectedItemPackingSubject.add(SelectedItemPacking.error(
          errorMessage: "Selected ingredient already weighted"));
      return;
    }

    _selectedItemPackingSubject.add(SelectedItemPacking(
        id: itemPacking.id,
        skuName: itemPacking.skuName,
        skuCode: itemPacking.skuCode,
        weight: 1.89));
    _isItemPackingSelectedSubject.add(true);
  }

  Future<bool> insertTempPremixDetail(double weight) async {
    if (weight == null || weight == 0) {
      _delegate.onPremixError("Please enter weight");
      return false;
    }
    var itemPacking = _selectedItemPackingSubject.value;
    if (itemPacking == null) {
      _delegate.onPremixError("Please enter ingredient");
      return false;
    }

    var lastItemPacking = await TempPremixDetailDao().getLast();
    double grossWeight;
    double tareWeight;
    double netWeight;

    if (lastItemPacking == null) {
      grossWeight = weight;
      tareWeight = 0;
      netWeight = weight;
    } else {
      grossWeight = weight;
      tareWeight = lastItemPacking.grossWeight;
      netWeight = double.tryParse(
          (weight - lastItemPacking.grossWeight).toStringAsFixed(2));
    }

    var tempPremixDetail = TempPremixDetail(
      itemPackingId: itemPacking.id,
      grossWeight: grossWeight,
      tareWeight: tareWeight,
      netWeight: netWeight,
    );

    await TempPremixDetailDao().insert(tempPremixDetail);
    await _loadTempPremixDetailList();
    await _loadItemPackingList();
    clearSelectedItemPacking();
    Vibrate.vibrate();
    return true;
  }

  deleteTempPremixDetail(int itemPackingId) async {
    await TempPremixDetailDao().deleteById(itemPackingId);
    await _loadTempPremixDetailList();
    await _loadItemPackingList();
  }

  Stream<List<ItemPacking>> get itemPackingListStream =>
      _itemPackingListSubject.stream;

  Stream<List<TempPremixDetailWithIp>> get tempPremixDetailListStream =>
      _tempPremixDetailListSubject.stream;

  Stream<double> get totalWeightStream => _totalWeightSubject.stream;

  Stream<bool> get isWeighingByBtStream => _isWeighingByBtSubject.stream;

  Stream<bool> get isItemPackingSelectedStream =>
      _isItemPackingSelectedSubject.stream;

  Stream<SelectedItemPacking> get selectedItemPackingStream =>
      _selectedItemPackingSubject.stream;

  @override
  dispose() {
    _itemPackingListSubject.close();
    _tempPremixDetailListSubject.close();
    _totalWeightSubject.close();

    _isItemPackingSelectedSubject.close();
    _selectedItemPackingSubject.close();

    _isWeighingByBtSubject.close();
  }
}

abstract class PremixDelegate {
  void onTabChange(int i);

  void onPremixError(String message);
}

class SelectedItemPacking {
  int id;
  String skuName, skuCode;
  double weight;
  bool isError = false;
  String errorMessage;

  SelectedItemPacking({this.id, this.skuName, this.skuCode, this.weight});

  SelectedItemPacking.error({this.errorMessage}) : this.isError = true;
}
