import 'package:ep_feedmill/bloc/bloc_base.dart';
import 'package:ep_feedmill/db/dao/mrf_premix_plan_detail_dao.dart';
import 'package:ep_feedmill/db/dao/mrf_premix_plan_doc_dao.dart';
import 'package:ep_feedmill/db/dao/premix_dao.dart';
import 'package:ep_feedmill/module/shared_preferences_module.dart';
import 'package:ep_feedmill/res/string.dart';
import 'package:ep_feedmill/screen/plan/plan_screen.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class PlanBloc extends BlocBase {
  final _planDocSubject = BehaviorSubject<MrfPremixPlanDocWithInfo>();

  int _mrfPremixPlanDocId;
  int _groupNo;
  PlanDelegate _delegate;

  PlanBloc(
      {@required PlanDelegate delegate, @required int mrfPremixPlanDocId}) {
    _delegate = delegate;
    _mrfPremixPlanDocId = mrfPremixPlanDocId;
    init();
  }

  init() async {
    _groupNo = await SharedPreferencesModule().getGroupNo();
    await loadMrfPremixPlanDoc();
  }

  loadMrfPremixPlanDoc() async {
    final doc =
        await MrfPremixPlanDocDao().getByIdWithInfo(_mrfPremixPlanDocId);
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

  Future<bool> validateBeforeStartPremix({@required bool isDone}) async {
    if (isDone) {
      _delegate.onDialogMessage(Strings.error, "Batch already done.");
      return false;
    }

    final count = await MrfPremixPlanDetailDao().getCountOfNotExistIngredient(
        mrfPremixPlanDocId: _mrfPremixPlanDocId, groupNo: _groupNo);

    if (count > 0) {
      _delegate.onDialogMessage(Strings.error,
          "Got unknown ingredient, please sync from housekeeping section for newest data.");
      return false;
    }

    return true;
  }

  @override
  void dispose() {
    _planDocSubject.close();
  }
}
