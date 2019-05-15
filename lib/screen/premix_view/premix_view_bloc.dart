import 'package:ep_feedmill/bloc/bloc_base.dart';
import 'package:ep_feedmill/db/dao/premix_dao.dart';
import 'package:ep_feedmill/db/dao/premix_detail_dao.dart';
import 'package:rxdart/rxdart.dart';

class PremixViewBloc extends BlocBase {
  final _premixSubject = BehaviorSubject<PremixWithInfo>();
  final _premixDetailListSubject =
  BehaviorSubject<List<PremixDetailWithInfo>>();
  final _ttlNetWgtSubject = BehaviorSubject<double>();

  Stream<PremixWithInfo> get premixStream => _premixSubject.stream;

  Stream<List<PremixDetailWithInfo>> get premixDetailListStream =>
      _premixDetailListSubject.stream;

  Stream<double> get ttlNetWgtStream =>
      _ttlNetWgtSubject.stream;

  @override
  void dispose() {
    _premixSubject.close();
    _premixDetailListSubject.close();
    _ttlNetWgtSubject.close();
  }

  int _premixId;

  PremixViewBloc({int premixId}) {
    _premixId = premixId;
    init();
  }

  init() async {
    await _loadPremix();

    final list = await PremixDetailDao().getByPremixId(_premixId);
    _ttlNetWgtSubject.add(list.map((d) => d.netWeight).reduce((v, e) => v + e));
    _premixDetailListSubject.add(list);
  }

  _loadPremix() async {
    _premixSubject.add(await PremixDao().getById(_premixId));
  }

  deletePremix() async {
    final premix = await PremixDao().getById(_premixId);
    premix.isDelete = 1;
    await PremixDao().update(premix);
    await _loadPremix();
  }

  PremixWithInfo getPremix(){
    return _premixSubject.value;
  }
}
