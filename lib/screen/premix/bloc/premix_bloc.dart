import 'package:ep_feedmill/bloc/bloc_base.dart';
import 'package:ep_feedmill/db/dao/mrf_premix_plan_detail_dao.dart';
import 'package:ep_feedmill/db/dao/mrf_premix_plan_doc_dao.dart';
import 'package:ep_feedmill/db/dao/premix_dao.dart';
import 'package:ep_feedmill/db/dao/premix_detail_dao.dart';
import 'package:ep_feedmill/db/dao/temp_premix_detail_dao.dart';
import 'package:ep_feedmill/model/table/premix.dart';
import 'package:ep_feedmill/model/table/premix_detail.dart';
import 'package:ep_feedmill/model/table/temp_premix_detail.dart';
import 'package:ep_feedmill/module/shared_preferences_module.dart';
import 'package:ep_feedmill/screen/premix/bloc/premix_scan_bloc.dart';
import 'package:ep_feedmill/screen/premix/bloc/premix_temp_bloc.dart';
import 'package:ep_feedmill/screen/premix/bloc/premix_weighing_bloc.dart';
import 'package:ep_feedmill/screen/premix/premix_screen.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:vibration/vibration.dart';

class PremixBloc extends BlocBase {
  final _planDocSubject = BehaviorSubject<MrfPremixPlanDocWithInfo>();
  final _planDetailWithInfoListSubject = BehaviorSubject<List<MrfPremixPlanDetailWithInfo>>();

  Stream<MrfPremixPlanDocWithInfo> get planDocStream => _planDocSubject.stream;

  Stream<List<MrfPremixPlanDetailWithInfo>> get planDetailWithInfoListStream =>
      _planDetailWithInfoListSubject.stream;

  @override
  dispose() {
    _planDocSubject.close();
    _planDetailWithInfoListSubject.close();
  }

  PremixDelegate _delegate;
  PremixScanBloc _scanBloc;
  PremixWeighingBloc _weighingBloc;
  PremixTempBloc _tempBloc;
  int _mrfPremixPlanDocId;
  int _batchNo;
  int _groupNo;
  String _barcode;

  PremixBloc({
    @required PremixDelegate delegate,
    @required PremixScanBloc scanBloc,
    @required PremixWeighingBloc weighingBloc,
    @required PremixTempBloc tempBloc,
    @required int mrfPremixPlanDocId,
    @required int batchNo,
    @required String barcode,
  }) {
    _delegate = delegate;
    _scanBloc = scanBloc;
    _weighingBloc = weighingBloc;
    _tempBloc = tempBloc;
    _mrfPremixPlanDocId = mrfPremixPlanDocId;
    _batchNo = batchNo;
    _barcode = barcode;

    _init();
  }

  int get batchNo => _batchNo;

  _init() async {
    _groupNo = await SharedPreferencesModule().getGroupNo();
    await _loadPlanDoc();
    await _loadPlanDetailWithInfoList();
  }

  _clearTemp() async {
    await TempPremixDetailDao().deleteAll();
  }

  _loadPlanDoc() async {
    final doc = await MrfPremixPlanDocDao().getByIdWithInfo(_mrfPremixPlanDocId);
    _planDocSubject.add(doc);
  }

  _loadPlanDetailWithInfoList() async {
    final list = await MrfPremixPlanDetailDao().getByMrfPremixPlanDocIdGroupNoWithInfoNotInTemp(
      mrfPremixPlanDocId: _mrfPremixPlanDocId,
      groupNo: _groupNo,
    );
    _planDetailWithInfoListSubject.add(list);
  }

  Future<bool> insertTempPremixDetail(double weight) async {
    if (weight == null || weight == 0) {
      _delegate.onPremixError("Please enter weight");
      return false;
    }
    var itemPacking = _scanBloc.getSelectedItemPacking();
    if (itemPacking == null) {
      _delegate.onPremixError("Please enter ingredient");
      return false;
    }

    var lastItemPacking = await TempPremixDetailDao().getLast();
    double grossWeight;
    double tareWeight;
    double netWeight;

    if (lastItemPacking == null || !_weighingBloc.getIsTaring()) {
      grossWeight = weight;
      tareWeight = 0;
      netWeight = weight;
    } else {
      grossWeight = weight;
      tareWeight = lastItemPacking.grossWeight;
      netWeight = double.tryParse((weight - lastItemPacking.grossWeight).toStringAsFixed(2));
    }

    var tempPremixDetail = TempPremixDetail(
      itemPackingId: itemPacking.id,
      mrfPremixPlanDetailId: itemPacking.mrfPremixPlanDetailId,
      grossWeight: grossWeight,
      tareWeight: tareWeight,
      netWeight: netWeight,
      isBt: _weighingBloc.getIsWeighingByBt() ? 1 : 0,
    );

    await TempPremixDetailDao().insert(tempPremixDetail);
    await _tempBloc.loadTempPremixDetailList();
    await _loadPlanDetailWithInfoList();
    _scanBloc.clearSelectedItemPacking();
    if (Vibration.hasVibrator() != null) {
      Vibration.vibrate();
    }
    return true;
  }

  Future<bool> autoInsertTempPremixDetailWithWeight() async {
    final itemPacking = _scanBloc.getSelectedItemPacking();
    if (itemPacking == null) {
      _delegate.onPremixError("Please enter ingredient");
      return false;
    }

    final weight = itemPacking.weight;

    var lastItemPacking = await TempPremixDetailDao().getLast();
    double grossWeight;
    double tareWeight;
    double netWeight;

    if (lastItemPacking == null || !_weighingBloc.getIsTaring()) {
      grossWeight = weight;
      tareWeight = 0;
      netWeight = weight;
    } else {
      grossWeight = weight;
      tareWeight = lastItemPacking.grossWeight;
      netWeight = double.tryParse((weight - lastItemPacking.grossWeight).toStringAsFixed(2));
    }

    var tempPremixDetail = TempPremixDetail(
      itemPackingId: itemPacking.id,
      mrfPremixPlanDetailId: itemPacking.mrfPremixPlanDetailId,
      grossWeight: grossWeight,
      tareWeight: tareWeight,
      netWeight: netWeight,
      isBt: 0,
    );

    await TempPremixDetailDao().insert(tempPremixDetail);
    await _tempBloc.loadTempPremixDetailList();
    await _loadPlanDetailWithInfoList();
    _scanBloc.clearSelectedItemPacking();
    if (Vibration.hasVibrator() != null) {
      Vibration.vibrate();
    }
    return true;
  }

  deleteTempPremixDetail(int id) async {
    await TempPremixDetailDao().deleteById(id);
    await _tempBloc.loadTempPremixDetailList();
    await _loadPlanDetailWithInfoList();
  }

  Future<int> savePremix() async {
    final plan = await MrfPremixPlanDocDao().getByIdWithInfo(_mrfPremixPlanDocId);

    final premix = Premix.dbInsert(
      mrfPremixPlanDocId: _mrfPremixPlanDocId,
      batchNo: _batchNo,
      groupNo: _groupNo,
      uuid: _barcode,
      recipeName: plan.recipeName,
      docNo: plan.docNo,
      formulaCategoryId: plan.formulaCategoryId,
      itemPackingId: plan.itemPackingId,
    );

    final premixId = await PremixDao().insert(premix);
    final tempList = await TempPremixDetailDao().getAll();
    final detailList = PremixDetail.fromTempWithPremixId(premixId, tempList);

    await Future.forEach(detailList, (detail) async {
      await PremixDetailDao().insert(detail);
    });

    await _clearTemp();

    return premixId;
  }

  Future<bool> validate() async {
    //20190828 This is check for at least 1 item in temp
    //final temp = await TempPremixDetailDao().getAll();
    //if (temp.length == 0) {
    //  _delegate.onPremixError("Please select at least 1 ingredient to save.");
    //  return false;
    //}
    //return true;

    final list = await MrfPremixPlanDetailDao().getByMrfPremixPlanDocIdGroupNoWithInfoNotInTemp(
      mrfPremixPlanDocId: _mrfPremixPlanDocId,
      groupNo: _groupNo,
    );
    if (list.length > 0) {
      final skuNameList = list.map((x) => x.skuName).join("\n");
      _delegate.onPremixError("Premix Not Complete !!!\n\n"
          "Following ingredient is missing :\n\n"
          "$skuNameList");
      return false;
    }
    return true;
  }
}
