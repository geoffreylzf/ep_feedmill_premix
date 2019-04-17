import 'package:ep_feedmill/bloc/bloc_base.dart';
import 'package:ep_feedmill/db/dao/temp_premix_detail_dao.dart';
import 'package:rxdart/rxdart.dart';

class PremixTempBloc extends BlocBase {
  final _tempPremixDetailListSubject =
      BehaviorSubject<List<TempPremixDetailWithInfo>>();
  final _totalWeightSubject = BehaviorSubject<double>();

  Stream<List<TempPremixDetailWithInfo>> get tempPremixDetailListStream =>
      _tempPremixDetailListSubject.stream;

  Stream<double> get totalWeightStream => _totalWeightSubject.stream;

  @override
  void dispose() {
    _tempPremixDetailListSubject.close();
    _totalWeightSubject.close();
  }

  PremixTempBloc() {
    _init();
  }

  _init() async {
    await loadTempPremixDetailList();
  }

  loadTempPremixDetailList() async {
    final list = await TempPremixDetailDao().getAll();
    var totalWeight = 0.0;
    if (list.isNotEmpty) {
      totalWeight = list.map((c) => c.netWeight).reduce((a, b) => a + b);
    }
    _tempPremixDetailListSubject.add(list);
    _totalWeightSubject.add(totalWeight);
  }

  double getTotalWeight() {
    return _totalWeightSubject.value;
  }
}
