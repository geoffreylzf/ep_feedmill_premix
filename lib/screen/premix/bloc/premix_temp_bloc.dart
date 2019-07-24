import 'package:ep_feedmill/bloc/bloc_base.dart';
import 'package:ep_feedmill/db/dao/temp_premix_detail_dao.dart';
import 'package:ep_feedmill/module/shared_preferences_module.dart';
import 'package:rxdart/rxdart.dart';

class PremixTempBloc extends BlocBase {
  final _tempPremixDetailListSubject = BehaviorSubject<List<TempPremixDetailWithInfo>>();
  final _totalWeightSubject = BehaviorSubject<double>();

  Stream<List<TempPremixDetailWithInfo>> get tempPremixDetailListStream =>
      _tempPremixDetailListSubject.stream;

  Stream<double> get totalWeightStream => _totalWeightSubject.stream;

  @override
  void dispose() {
    _tempPremixDetailListSubject.close();
    _totalWeightSubject.close();
  }

  int _mrfPremixPlanDocId;
  int _groupNo;

  PremixTempBloc({int mrfPremixPlanDocId}) {
    _mrfPremixPlanDocId = mrfPremixPlanDocId;
    _init();
  }

  _init() async {
    _groupNo = await SharedPreferencesModule().getGroupNo();
    await TempPremixDetailDao().deleteAll();
    await loadTempPremixDetailList();
  }

  loadTempPremixDetailList() async {
    final list = await TempPremixDetailDao()
        .getByPlanIdGroupNo(mrfPremixPlanDocId: _mrfPremixPlanDocId, groupNo: _groupNo);
    final addOnList = await TempPremixDetailDao()
        .getAddOnByPlanIdGroupNo(mrfPremixPlanDocId: _mrfPremixPlanDocId, groupNo: _groupNo);
    list.addAll(addOnList);
    var totalWeight = 0.0;
    if (list.isNotEmpty) {
      totalWeight = list.map((c) => c.netWeight ?? 0).reduce((a, b) => a + b);
    }
    _tempPremixDetailListSubject.add(list);
    _totalWeightSubject.add(totalWeight);
  }

  double getTotalWeight() {
    return _totalWeightSubject.value;
  }
}
