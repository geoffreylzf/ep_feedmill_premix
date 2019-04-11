import 'package:ep_feedmill/bloc/bloc_base.dart';
import 'package:ep_feedmill/db/dao/mrf_premix_plan_detail_dao.dart';
import 'package:ep_feedmill/db/dao/mrf_premix_plan_doc_dao.dart';
import 'package:ep_feedmill/model/mrf_premix_plan_doc.dart';
import 'package:ep_feedmill/module/api_module.dart';
import 'package:rxdart/rxdart.dart';

class HomeBloc extends BlocBase {
  final _mrfPremixPlanDocListSubject =
      BehaviorSubject<List<MrfPremixPlanDoc>>();

  _loadMrfPremixPlanDoc() async {
    _mrfPremixPlanDocListSubject.add(await MrfPremixPlanDocDao().getAll());
  }

  retrieveCurrentMrfPremixPlan() async {
    var response = await ApiModule().getMrfPremixPlanDoc();
    await MrfPremixPlanDocDao().deleteAll();
    await MrfPremixPlanDetailDao().deleteAll();

    response.result.forEach((doc) async {
      await MrfPremixPlanDocDao().insert(doc);
      doc.mrfPremixPlanDetailList.forEach((detail) async {
        await MrfPremixPlanDetailDao().insert(detail);
      });
    });
    await _loadMrfPremixPlanDoc();
  }

  Stream<List<MrfPremixPlanDoc>> get mrfPremixPlanDocListStream =>
      _mrfPremixPlanDocListSubject.stream;

  @override
  void dispose() {
    _mrfPremixPlanDocListSubject.close();
  }
}
