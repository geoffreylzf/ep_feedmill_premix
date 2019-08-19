import 'package:ep_feedmill/bloc/bloc_base.dart';
import 'package:ep_feedmill/mixin/simple_alert_dialog_mixin.dart';
import 'package:ep_feedmill/model/plan_check.dart';
import 'package:ep_feedmill/model/upload_body.dart';
import 'package:ep_feedmill/module/api_module.dart';
import 'package:ep_feedmill/res/string.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class PlanCheckListBloc extends BlocBase {
  final _planCheckListSubject = BehaviorSubject<List<PlanCheck>>();
  final _isForCheckSubject = BehaviorSubject<bool>.seeded(true);

  Stream<List<PlanCheck>> get planCheckListStream => _planCheckListSubject.stream;

  Stream<bool> get isForCheckStream => _isForCheckSubject.stream;

  List<PlanCheck> _planCheckList = new List<PlanCheck>();

  @override
  void dispose() {
    _planCheckListSubject.close();
    _isForCheckSubject.close();
  }

  SimpleAlertDialogMixin _simpleAlertDialogMixin;

  PlanCheckListBloc({
    @required SimpleAlertDialogMixin mixin,
  }) {
    _simpleAlertDialogMixin = mixin;
    loadPlanCheckList();
  }

  loadPlanCheckList() async {
    try {
      int isVerify = 1;
      if (_isForCheckSubject.value) {
        isVerify = 0;
      }
      _planCheckListSubject.add(null);
      final response = await ApiModule().getPlanCheckList(isVerify);
      _planCheckList = response.result;
      _planCheckListSubject.add(_planCheckList);
    } catch (e) {
      _simpleAlertDialogMixin.onDialogMessage(Strings.error, e.toString());
    }
  }

  tickGroupVerify() {
    _planCheckListSubject.add(_planCheckList);
  }

  refreshPlanCheckList() {
    loadPlanCheckList();
  }

  savePlanCheckList() async {
    try {
      if (_planCheckList.length == 0) {
        _simpleAlertDialogMixin.onDialogMessage(Strings.error, "Nothing to update");
        return;
      }

      int isVerify = 0;
      if (_isForCheckSubject.value) {
        isVerify = 1;
      }

      _planCheckList.forEach((pl){
        pl.detailList = pl.detailList.where((d) => d.isVerify == isVerify).toList();
      });

      final uploadBody = UploadBody(planCheckList: _planCheckList);

      print(uploadBody.toJson());

      final recordCount = (await ApiModule().updatePlanCheckList(uploadBody)).result.recordCount;

      _simpleAlertDialogMixin.onDialogMessage(Strings.success, "Update $recordCount record(s)");

      await loadPlanCheckList();
    } catch (e) {
      _simpleAlertDialogMixin.onDialogMessage(Strings.error, e.toString());
    }
  }

  setForCheck(bool b) {
    _isForCheckSubject.add(b);
    loadPlanCheckList();
  }
}
