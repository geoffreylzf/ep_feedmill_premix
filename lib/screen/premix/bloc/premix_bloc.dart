import 'package:ep_feedmill/bloc/bloc_base.dart';
import 'package:ep_feedmill/db/dao/item_packing_dao.dart';
import 'package:ep_feedmill/db/dao/mrf_premix_plan_detail_dao.dart';
import 'package:ep_feedmill/db/dao/mrf_premix_plan_doc_dao.dart';
import 'package:ep_feedmill/db/dao/temp_premix_detail_dao.dart';
import 'package:ep_feedmill/model/table/temp_premix_detail.dart';
import 'package:rxdart/rxdart.dart';
import 'package:vibrate/vibrate.dart';

class PremixBloc extends BlocBase {
  final _planDocSubject = BehaviorSubject<MrfPremixPlanDocWithInfo>();
  final _planDetailWithInfoListSubject =
      BehaviorSubject<List<MrfPremixPlanDetailWithInfo>>();
  final _tempPremixDetailListSubject =
      BehaviorSubject<List<TempPremixDetailWithInfo>>();

  final _totalWeightSubject = BehaviorSubject<double>();

  final _selectedItemPackingSubject = BehaviorSubject<SelectedItemPacking>();
  final _isItemPackingSelectedSubject = BehaviorSubject<bool>.seeded(false);

  final _isWeighingByBtSubject = BehaviorSubject<bool>.seeded(false);

  Stream<MrfPremixPlanDocWithInfo> get planDocStream => _planDocSubject.stream;

  Stream<List<MrfPremixPlanDetailWithInfo>> get planDetailWithInfoListStream =>
      _planDetailWithInfoListSubject.stream;

  Stream<List<TempPremixDetailWithInfo>> get tempPremixDetailListStream =>
      _tempPremixDetailListSubject.stream;

  Stream<double> get totalWeightStream => _totalWeightSubject.stream;

  Stream<bool> get isWeighingByBtStream => _isWeighingByBtSubject.stream;

  Stream<bool> get isItemPackingSelectedStream =>
      _isItemPackingSelectedSubject.stream;

  Stream<SelectedItemPacking> get selectedItemPackingStream =>
      _selectedItemPackingSubject.stream;

  @override
  dispose() {
    _planDocSubject.close();
    _planDetailWithInfoListSubject.close();
    _tempPremixDetailListSubject.close();
    _totalWeightSubject.close();

    _isItemPackingSelectedSubject.close();
    _selectedItemPackingSubject.close();

    _isWeighingByBtSubject.close();
  }

  PremixDelegate _delegate;
  int _mrfPremixPlanDocId;
  int _batchNo;

  PremixBloc({PremixDelegate delegate, int mrfPremixPlanDocId, int batchNo}) {
    _delegate = delegate;
    _mrfPremixPlanDocId = mrfPremixPlanDocId;
    _batchNo = batchNo;
    _loadPlanDoc();
    _loadPlanDetailWithInfoList();
    _loadTempPremixDetailList();
  }

  int get batchNo => _batchNo;

  _loadPlanDoc() async {
    final doc =
        await MrfPremixPlanDocDao().getByIdWithInfo(_mrfPremixPlanDocId);
    _planDocSubject.add(doc);
  }

  _loadPlanDetailWithInfoList() async {
    final list = await MrfPremixPlanDetailDao()
        .getByMrfPremixPlanDocIdWithInfoNotInTemp(_mrfPremixPlanDocId);
    _planDetailWithInfoListSubject.add(list);
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

    var formulaWeight = 0.0;

    final planDetail = await MrfPremixPlanDetailDao()
        .getByMrfPremixPlanDocIdItemPackingId(
            _mrfPremixPlanDocId, itemPackingId);

    if (planDetail == null) {
      _selectedItemPackingSubject.add(SelectedItemPacking.error(
          errorMessage: "Selected ingredient is not in plan formula"));
      return;
    } else {
      formulaWeight = planDetail.formulaWeight;
    }

    _selectedItemPackingSubject.add(SelectedItemPacking(
        id: itemPacking.id,
        mrfPremixPlanDetailId: planDetail.id,
        skuName: itemPacking.skuName,
        skuCode: itemPacking.skuCode,
        weight: formulaWeight));
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
      mrfPremixPlanDetailId: itemPacking.mrfPremixPlanDetailId,
      grossWeight: grossWeight,
      tareWeight: tareWeight,
      netWeight: netWeight,
      isBt: _isWeighingByBtSubject.value ? 1 : 0,
    );

    await TempPremixDetailDao().insert(tempPremixDetail);
    await _loadTempPremixDetailList();
    await _loadPlanDetailWithInfoList();
    clearSelectedItemPacking();
    Vibrate.vibrate();
    return true;
  }

  deleteTempPremixDetail(int itemPackingId) async {
    await TempPremixDetailDao().deleteById(itemPackingId);
    await _loadTempPremixDetailList();
    await _loadPlanDetailWithInfoList();
  }
}

abstract class PremixDelegate {
  void onTabChange(int i);

  void onPremixError(String message);
}

class SelectedItemPacking {
  int id, mrfPremixPlanDetailId;
  String skuName, skuCode;
  double weight;
  bool isError = false;
  String errorMessage;

  SelectedItemPacking(
      {this.id,
      this.mrfPremixPlanDetailId,
      this.skuName,
      this.skuCode,
      this.weight});

  SelectedItemPacking.error({this.errorMessage}) : this.isError = true;
}
