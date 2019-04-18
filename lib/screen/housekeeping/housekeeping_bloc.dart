import 'package:ep_feedmill/bloc/bloc_base.dart';
import 'package:ep_feedmill/db/dao/item_packing_dao.dart';
import 'package:ep_feedmill/db/dao/mrf_formula_category_dao.dart';
import 'package:ep_feedmill/module/api_module.dart';
import 'package:ep_feedmill/res/string.dart';
import 'package:ep_feedmill/screen/housekeeping/housekeeping_screen.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class HousekeepingBloc extends BlocBase {
  final _ipCountSubject = BehaviorSubject<int>();
  final _fcCountSubject = BehaviorSubject<int>();
  final _isLoadingSubject = BehaviorSubject<bool>.seeded(false);

  Stream<int> get ipCountStream => _ipCountSubject.stream;

  Stream<int> get fcCountStream => _fcCountSubject.stream;

  Stream<bool> get isLoadingStream => _isLoadingSubject.stream;

  @override
  void dispose() {
    _ipCountSubject.close();
    _fcCountSubject.close();
    _isLoadingSubject.close();
  }

  HousekeepingDelegate _delegate;

  HousekeepingBloc({@required HousekeepingDelegate delegate}) {
    _delegate = delegate;
    _loadCount();
  }

  _loadCount() async {
    _ipCountSubject.add(await ItemPackingDao().getCount());
    _fcCountSubject.add(await MrfFormulaCategoryDao().getCount());
  }

  retrieveAll() async {
    try {
      _isLoadingSubject.add(true);
      final ipResponse = await ApiModule().getItemPacking();
      await ItemPackingDao().deleteAll();
      await Future.forEach(ipResponse.result, (ip) async {
        await ItemPackingDao().insert(ip);
      });

      final fcResponse = await ApiModule().getMrfFormulaCategory();
      await MrfFormulaCategoryDao().deleteAll();

      await Future.forEach(fcResponse.result, (fc) async {
        await MrfFormulaCategoryDao().insert(fc);
      });
      await _loadCount();
      _delegate.onDialogMessage(
          Strings.success, "Housekeeping successfully retrieve.");
    } catch (e) {
      _delegate.onDialogMessage(Strings.success,
          e.toString());
    } finally {
      _isLoadingSubject.add(false);
    }
  }
}
