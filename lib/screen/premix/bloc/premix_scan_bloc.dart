import 'package:ep_feedmill/bloc/bloc_base.dart';
import 'package:ep_feedmill/db/dao/item_packing_dao.dart';
import 'package:ep_feedmill/db/dao/mrf_premix_plan_detail_dao.dart';
import 'package:ep_feedmill/db/dao/temp_premix_detail_dao.dart';
import 'package:ep_feedmill/module/shared_preferences_module.dart';
import 'package:ep_feedmill/screen/premix/premix_screen.dart';
import 'package:rxdart/rxdart.dart';

class PremixScanBloc extends BlocBase {
  final _selectedItemPackingSubject = BehaviorSubject<SelectedItemPacking>();
  final _isItemPackingSelectedSubject = BehaviorSubject<bool>.seeded(false);
  final _isAllowAddonSubject = BehaviorSubject<bool>.seeded(false);

  Stream<SelectedItemPacking> get selectedItemPackingStream =>
      _selectedItemPackingSubject.stream;

  Stream<bool> get isItemPackingSelectedStream =>
      _isItemPackingSelectedSubject.stream;

  Stream<bool> get isAllowAddonStream => _isAllowAddonSubject.stream;

  @override
  void dispose() {
    _isItemPackingSelectedSubject.close();
    _selectedItemPackingSubject.close();
    _isAllowAddonSubject.close();
  }

  PremixDelegate _delegate;
  int _mrfPremixPlanDocId;
  int _groupNo;

  PremixScanBloc({PremixDelegate delegate, int mrfPremixPlanDocId}) {
    _delegate = delegate;
    _mrfPremixPlanDocId = mrfPremixPlanDocId;

    _init();
  }

  _init() async {
    _groupNo = await SharedPreferencesModule().getGroupNo();
  }

  clearSelectedItemPacking() {
    _selectedItemPackingSubject.add(null);
    _isItemPackingSelectedSubject.add(false);
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

    var planDetailId;
    var formulaWeight = 0.0;

    if (!getIsAllowAddon()) {
      final planDetail = await MrfPremixPlanDetailDao()
          .getByMrfPremixPlanDocIdGroupNoItemPackingId(
              mrfPremixPlanDocId: _mrfPremixPlanDocId,
              groupNo: _groupNo,
              itemPackingId: itemPackingId);

      if (planDetail == null) {
        _selectedItemPackingSubject.add(SelectedItemPacking.error(
            errorMessage: "Selected ingredient is not in plan formula"));
        return;
      } else {
        planDetailId = planDetail.id;
        formulaWeight = planDetail.formulaWeight;
      }
    }

    _selectedItemPackingSubject.add(SelectedItemPacking(
        id: itemPacking.id,
        mrfPremixPlanDetailId: planDetailId,
        skuName: itemPacking.skuName,
        skuCode: itemPacking.skuCode,
        weight: formulaWeight));
    _isItemPackingSelectedSubject.add(true);
  }

  manualSelectItemPacking(int itemPackingId) {
    scan(itemPackingId);
    _delegate.onTabChange(1);
  }

  SelectedItemPacking getSelectedItemPacking() {
    return _selectedItemPackingSubject.value;
  }

  setIsAllowAddon(bool b) {
    _isAllowAddonSubject.add(b);
  }

  bool getIsAllowAddon() {
    return _isAllowAddonSubject.value;
  }
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
