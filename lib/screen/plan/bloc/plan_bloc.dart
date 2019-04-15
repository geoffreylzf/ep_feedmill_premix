import 'package:ep_feedmill/bloc/bloc_base.dart';
import 'package:ep_feedmill/db/dao/mrf_premix_plan_doc_dao.dart';
import 'package:ep_feedmill/db/dao/premix_dao.dart';
import 'package:ep_feedmill/module/shared_preferences_module.dart';
import 'package:rxdart/rxdart.dart';

class PlanBloc extends BlocBase {
  final _planDocSubject = BehaviorSubject<MrfPremixPlanDocWithInfo>();

  int _mrfPremixPlanDocId;
  int _groupNo;

  PlanBloc({int mrfPremixPlanDocId}) {
    _mrfPremixPlanDocId = mrfPremixPlanDocId;
    init();
  }

  init() async {
    _groupNo = await SharedPreferencesModule().getGroupNo();
    await loadMrfPremixPlanDoc();
  }

  loadMrfPremixPlanDoc() async {
    final doc = await MrfPremixPlanDocDao().getByIdWithInfo(
      mrfPremixPlanDocId: _mrfPremixPlanDocId,
    );
    _planDocSubject.add(doc);
  }

  Stream<MrfPremixPlanDocWithInfo> get planDocStream => _planDocSubject.stream;

  Future<bool> getIsPremixDone(int batchNo) async {
    final premix = await PremixDao().getByMrfPremixPlanDocIdBatchNoGroupNo(
      mrfPremixPlanDocId: _mrfPremixPlanDocId,
      batchNo: batchNo,
      groupNo: _groupNo,
    );
    return premix != null;
  }

  @override
  void dispose() {
    _planDocSubject.close();
  }
}
