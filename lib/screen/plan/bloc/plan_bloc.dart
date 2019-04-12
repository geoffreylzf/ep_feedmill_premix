import 'package:ep_feedmill/bloc/bloc_base.dart';
import 'package:ep_feedmill/db/dao/mrf_premix_plan_doc_dao.dart';
import 'package:rxdart/rxdart.dart';

class PlanBloc extends BlocBase {
  final _planDocSubject = BehaviorSubject<MrfPremixPlanDocWithInfo>();

  final int mrfPremixPlanDocId;

  PlanBloc({this.mrfPremixPlanDocId}) {
    loadMrfPremixPlanDoc();
  }

  loadMrfPremixPlanDoc() async {
    final doc = await MrfPremixPlanDocDao().getByIdWithInfo(mrfPremixPlanDocId);
    _planDocSubject.add(doc);
  }

  Stream<MrfPremixPlanDocWithInfo> get planDocStream => _planDocSubject.stream;

  @override
  void dispose() {
    _planDocSubject.close();
  }
}
