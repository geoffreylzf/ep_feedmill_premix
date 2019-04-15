import 'package:ep_feedmill/db/app_db.dart';
import 'package:ep_feedmill/model/table/premix.dart';
import 'package:flutter/material.dart';

const _table = "premix";

class PremixDao {
  static final _instance = PremixDao._internal();

  PremixDao._internal();

  factory PremixDao() => _instance;

  Future<int> insert(Premix premix) async {
    var db = await AppDb().database;
    var res = await db.insert(_table, premix.toInsertDbJson());
    return res;
  }

  Future<Premix> getByMrfPremixPlanDocIdBatchNoGroupNo(
      {@required int mrfPremixPlanDocId,
      @required int batchNo,
      @required int groupNo,
      int isDelete: 0}) async {
    final db = await AppDb().database;
    final res = await db.query(
      _table,
      where: """mrf_premix_plan_doc_id = ? 
          AND batch_no = ? 
          AND group_no = ? 
          AND is_delete = ?""",
      whereArgs: [mrfPremixPlanDocId, batchNo, groupNo, isDelete],
    );
    return res.isNotEmpty ? Premix.fromJson(res.first) : null;
  }

  Future<List<Premix>> getAll() async {
    final db = await AppDb().database;
    final res = await db.query(_table, orderBy: "id DESC");
    List<Premix> list =
        res.isNotEmpty ? res.map((c) => Premix.fromJson(c)).toList() : [];
    return list;
  }

  Future<int> deleteAll() async {
    var db = await AppDb().database;
    var res = await db.delete(_table);
    return res;
  }
}
