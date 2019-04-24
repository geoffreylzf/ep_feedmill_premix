import 'package:ep_feedmill/db/dao/premix_dao.dart';
import 'package:ep_feedmill/model/table/premix.dart';
import 'package:flutter/material.dart';

class PremixRepository {
  static final _instance = PremixRepository._internal();

  PremixRepository._internal();

  factory PremixRepository() => _instance;

  updateUploadStatus({
    @required List<int> ids,
    int uploadStatus = 1,
  }) async {
    await Future.forEach(ids, (id) async {
      final premix = await PremixDao().getById(id);
      premix.isUpload = 1;
      await PremixDao().update(premix);
    });
  }

  Future<List<Premix>> getPreparedUploadData() async {
    final premixList =  await PremixDao().getByUpload(isUpload: 0);
    await Future.forEach(premixList, (premix) async {
      await (premix as Premix).loadDetailList();
    });

    return premixList;
  }
}
