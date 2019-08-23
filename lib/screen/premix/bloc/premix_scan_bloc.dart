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

  final _scanFocusSubject = BehaviorSubject<void>.seeded(0);

  Stream<SelectedItemPacking> get selectedItemPackingStream => _selectedItemPackingSubject.stream;

  Stream<bool> get isItemPackingSelectedStream => _isItemPackingSelectedSubject.stream;

  Stream<bool> get isAllowAddonStream => _isAllowAddonSubject.stream;

  Stream<void> get scanFocusStream => _scanFocusSubject.stream;

  @override
  void dispose() {
    _isItemPackingSelectedSubject.close();
    _selectedItemPackingSubject.close();
    _isAllowAddonSubject.close();
    _scanFocusSubject.close();
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
    _scanFocusSubject.add(null);
  }

  _recursiveSumAllIntChar(String str) {
    if (str.length == 1) {
      return int.parse(str);
    } else {
      var sumOfIpId = 0;
      for (int i = 0; i < str.length; i++) {
        sumOfIpId += int.parse(str[i]);
      }
      final sumStr = sumOfIpId.toString();
      return int.parse(sumStr.substring(sumStr.length - 1));
    }
  }

  scan(int itemPackingId, {manual = false}) async {
    if (itemPackingId == null) {
      _selectedItemPackingSubject
          .add(SelectedItemPacking.error(errorMessage: "Invalid ingredient barcode"));
      return;
    }

    if (!manual) {
      final str = itemPackingId.toString();
      final strLength = str.length;
      final ipIdStr = str.substring(0, strLength - 1);
      final sumSingle = int.parse(str.substring(strLength - 1));

      final recursiveSumSingle = _recursiveSumAllIntChar(ipIdStr);

      if (recursiveSumSingle != sumSingle) {
        _selectedItemPackingSubject
            .add(SelectedItemPacking.error(errorMessage: "Invalid barcode format"));
        return;
      }
      itemPackingId = int.parse(ipIdStr);
    }

    final itemPacking = await ItemPackingDao().getById(itemPackingId);
    if (itemPacking == null) {
      _selectedItemPackingSubject
          .add(SelectedItemPacking.error(errorMessage: "Ingredient barcode not exist"));
      return;
    }

    final temp = await TempPremixDetailDao().getByItemPackingId(itemPackingId);
    if (temp != null) {
      _selectedItemPackingSubject
          .add(SelectedItemPacking.error(errorMessage: "Selected ingredient already weighted"));
      return;
    }

    var planDetailId;
    var formulaWeight = 0.0;

    if (!getIsAllowAddon()) {
      final planDetail = await MrfPremixPlanDetailDao().getByMrfPremixPlanDocIdGroupNoItemPackingId(
          mrfPremixPlanDocId: _mrfPremixPlanDocId, groupNo: _groupNo, itemPackingId: itemPackingId);

      if (planDetail == null) {
        _selectedItemPackingSubject.add(
            SelectedItemPacking.error(errorMessage: "Selected ingredient is not in plan formula"));
        return;
      }

      //check sequence
      final currentSequence = planDetail.sequence;
      final requireSequence = await MrfPremixPlanDetailDao()
          .getMinSequence(mrfPremixPlanDocId: _mrfPremixPlanDocId, groupNo: _groupNo);

      if (requireSequence == null) {
        _selectedItemPackingSubject
            .add(SelectedItemPacking.error(errorMessage: "No additional ingredient require"));
        return;
      }

      if (requireSequence != currentSequence) {
        _selectedItemPackingSubject.add(SelectedItemPacking.error(
            errorMessage:
                "Ingredient sequence incorrect,\nplease select sequence $requireSequence"));
        return;
      }

      planDetailId = planDetail.id;
      formulaWeight = planDetail.formulaWeight;
    }

    _selectedItemPackingSubject.add(SelectedItemPacking(
        id: itemPacking.id,
        mrfPremixPlanDetailId: planDetailId,
        skuName: itemPacking.skuName,
        skuCode: itemPacking.skuCode,
        isPremix: itemPacking.isPremix,
        weight: formulaWeight));
    _isItemPackingSelectedSubject.add(true);
  }

  manualSelectItemPacking(int itemPackingId) {
    scan(itemPackingId, manual: true);
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
  int id, mrfPremixPlanDetailId, isPremix;
  String skuName, skuCode;
  double weight;
  bool isError = false;
  String errorMessage;

  SelectedItemPacking({
    this.id,
    this.mrfPremixPlanDetailId,
    this.skuName,
    this.skuCode,
    this.isPremix,
    this.weight,
  });

  SelectedItemPacking.error({this.errorMessage}) : this.isError = true;
}
