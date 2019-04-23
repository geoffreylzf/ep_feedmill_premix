import 'package:ep_feedmill/bloc/bloc_base.dart';
import 'package:ep_feedmill/db/dao/mrf_premix_plan_detail_dao.dart';
import 'package:ep_feedmill/db/dao/mrf_premix_plan_doc_dao.dart';
import 'package:ep_feedmill/db/dao/premix_dao.dart';
import 'package:ep_feedmill/model/table/mrf_formula_category.dart';
import 'package:ep_feedmill/model/table/mrf_premix_plan_doc.dart';
import 'package:ep_feedmill/module/api_module.dart';
import 'package:ep_feedmill/module/shared_preferences_module.dart';
import 'package:ep_feedmill/res/string.dart';
import 'package:ep_feedmill/screen/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class HomeBloc extends BlocBase {
  final _mrfPremixPlanDocListSubject =
      BehaviorSubject<List<MrfPremixPlanDocWithInfo>>();

  final _broilerCheckedSubject = BehaviorSubject<bool>();
  final _breederCheckedSubject = BehaviorSubject<bool>();
  final _swineCheckedSubject = BehaviorSubject<bool>();

  Stream<List<MrfPremixPlanDocWithInfo>> get mrfPremixPlanDocListStream =>
      _mrfPremixPlanDocListSubject.stream;

  Stream<bool> get broilerCheckedStream => _broilerCheckedSubject.stream;

  Stream<bool> get breederCheckedStream => _breederCheckedSubject.stream;

  Stream<bool> get swineCheckedStream => _swineCheckedSubject.stream;

  Stream<String> get categorySqlStream => Observable.combineLatest3(
          broilerCheckedStream, breederCheckedStream, swineCheckedStream,
          (bool broiler, bool breeder, bool swine) {
        return MrfFormulaCategory.getSqlFilter(
          broiler: broiler,
          breeder: breeder,
          swine: swine,
        );
      });

  @override
  void dispose() {
    _mrfPremixPlanDocListSubject.close();
    _broilerCheckedSubject.close();
    _breederCheckedSubject.close();
    _swineCheckedSubject.close();
  }

  String _categoryFilterSql;

  HomeDelegate _delegate;

  HomeBloc({@required HomeDelegate delegate}) {
    _delegate = delegate;
    _init();
  }

  _init() async {
    _broilerCheckedSubject
        .add(await SharedPreferencesModule().getBroilerCheck() ?? true);
    _breederCheckedSubject
        .add(await SharedPreferencesModule().getBreederCheck() ?? true);
    _swineCheckedSubject
        .add(await SharedPreferencesModule().getSwineCheck() ?? true);

    categorySqlStream.listen((sql) {
      _categoryFilterSql = sql;
      loadMrfPremixPlanDoc();
    });
  }

  loadMrfPremixPlanDoc() async {
    final groupNo = await SharedPreferencesModule().getGroupNo();
    _mrfPremixPlanDocListSubject.add(await MrfPremixPlanDocDao()
        .getAllWithInfo(_categoryFilterSql, groupNo));
  }

  retrieveCurrentMrfPremixPlan() async {
    try {
      _mrfPremixPlanDocListSubject.add(null);
      var response = await ApiModule().getMrfPremixPlanDoc();
      await MrfPremixPlanDocDao().deleteAll();
      await MrfPremixPlanDetailDao().deleteAll();

      await Future.forEach<MrfPremixPlanDoc>(response.result, (doc) async {
        await MrfPremixPlanDocDao().insert(doc);
        await Future.forEach(doc.mrfPremixPlanDetailList, (detail) async {
          await MrfPremixPlanDetailDao().insert(detail);
        });
      });
      _delegate.onDialogMessage(Strings.success,
          "Newest premix plan document successfully retrieve.");
    } catch (e) {
      _delegate.onDialogMessage(Strings.success, e.toString());
    } finally {
      await loadMrfPremixPlanDoc();
    }
  }

  setBroilerChecked(bool b) async {
    await SharedPreferencesModule().saveBroilerCheck(b);
    _broilerCheckedSubject.add(b);
  }

  setBreederChecked(bool b) async {
    await SharedPreferencesModule().saveBreederCheck(b);
    _breederCheckedSubject.add(b);
  }

  setSwineChecked(bool b) async {
    await SharedPreferencesModule().saveSwineCheck(b);
    _swineCheckedSubject.add(b);
  }

  Future<int> getBatchDoneCount(int mrfPremixPlanDocId) async {
    final groupNo = await SharedPreferencesModule().getGroupNo();
    return await PremixDao().getCountByMrfPremixPlanDocIdGroupNo(
      mrfPremixPlanDocId: mrfPremixPlanDocId,
      groupNo: groupNo,
    );
  }
}
