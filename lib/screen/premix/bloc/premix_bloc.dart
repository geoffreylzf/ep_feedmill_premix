import 'package:ep_feedmill/bloc/bloc_base.dart';
import 'package:ep_feedmill/db/item_packing_dao.dart';
import 'package:ep_feedmill/model/item_packing.dart';
import 'package:rxdart/rxdart.dart';

class PremixBloc extends BlocBase {
  final _itemPackingListSubject = BehaviorSubject<List<ItemPacking>>();
  final _selectedItemPackingSubject = BehaviorSubject<SelectedItemPacking>();
  final _isItemPackingSelectedSubject = BehaviorSubject<bool>.seeded(false);
  final _isWeighingByBtSubject = BehaviorSubject<bool>.seeded(false);

  PremixDelegate _delegate;

  PremixBloc(PremixDelegate delegate) {
    _loadItemPackingList();
    _delegate = delegate;
  }

  _loadItemPackingList() async {
    final list = await ItemPackingDao().getAll();
    _itemPackingListSubject.add(list);
  }

  scan(int itemPackingId) async {
    if (itemPackingId != null) {
      final itemPacking = await ItemPackingDao().getById(itemPackingId);
      if (itemPacking != null) {
        _selectedItemPackingSubject.add(SelectedItemPacking(
            id: itemPacking.id,
            skuName: itemPacking.skuName,
            skuCode: itemPacking.skuCode,
            weight: 1.89));
        _isItemPackingSelectedSubject.add(true);
      } else {
        _delegate.onPremixError("Invalid Item Packing Barcode");
      }
    } else {
      _delegate.onPremixError("Invalid Item Packing Barcode");
    }
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

  Future<bool> insertTempPremixDetail(double weight) async {
    if (weight == null) {
      _delegate.onPremixError("Please enter weight");
      return false;
    }
    print(weight.toString());
    clearSelectedItemPacking();

    return true;
  }

  Stream<List<ItemPacking>> get itemPackingListStream =>
      _itemPackingListSubject.stream;

  Stream<bool> get isWeighingByBtStream => _isWeighingByBtSubject.stream;

  Stream<bool> get isItemPackingSelectedStream =>
      _isItemPackingSelectedSubject.stream;

  Stream<SelectedItemPacking> get selectedItemPackingStream =>
      _selectedItemPackingSubject.stream;

  @override
  dispose() {
    _itemPackingListSubject.close();
    _isWeighingByBtSubject.close();
    _isItemPackingSelectedSubject.close();
    _selectedItemPackingSubject.close();
  }
}

abstract class PremixDelegate {
  void onTabChange(int i);

  void onPremixError(String message);
}

class SelectedItemPacking {
  final int id;
  final String skuName, skuCode;
  final double weight;

  SelectedItemPacking({this.id, this.skuName, this.skuCode, this.weight});
}
