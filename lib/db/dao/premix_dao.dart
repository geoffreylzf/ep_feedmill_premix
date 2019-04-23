import 'package:ep_feedmill/db/app_db.dart';
import 'package:ep_feedmill/model/table/premix.dart';
import 'package:flutter/material.dart';

const _table = "premix";

class PremixDao {
  static final _instance = PremixDao._internal();

  PremixDao._internal();

  factory PremixDao() => _instance;

  Future<int> insert(Premix premix) async {
    final db = await AppDb().database;
    final res = await db.insert(_table, premix.toDbJson());
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

  Future<int> getCountByMrfPremixPlanDocIdGroupNo({
    @required int mrfPremixPlanDocId,
    @required int groupNo,
    int isDelete: 0,
  }) async {
    final db = await AppDb().database;
    final res = await db.rawQuery("""
    SELECT 
      COUNT(*) as count
    FROM premix
    WHERE mrf_premix_plan_doc_id = ?
    AND group_no = ? 
    AND is_delete = ?
    """, [mrfPremixPlanDocId, groupNo, isDelete]);
    return res.isNotEmpty ? res.first['count'] : 0;
  }

  Future<PremixWithInfo> getById(int id) async {
    final db = await AppDb().database;
    final res = await db.rawQuery("""
    SELECT
      premix.*,
      item_packing.sku_code,
      item_packing.sku_name
    FROM premix
    LEFT JOIN item_packing 
      ON premix.item_packing_id = item_packing.id
    WHERE premix.id = ?
    """, [id]);
    return res.isNotEmpty ? PremixWithInfo.fromJson(res.first) : null;
  }

  Future<List<Premix>> getAll() async {
    final db = await AppDb().database;
    final res = await db.query(_table, orderBy: "id DESC");
    return res.isNotEmpty ? res.map((c) => Premix.fromJson(c)).toList() : [];
  }

  Future<int> update(Premix premix) async {
    final db = await AppDb().database;
    return await db.update(_table, premix.toDbJson(),
        where: "id = ?", whereArgs: [premix.id]);
  }
}

class PremixWithInfo extends Premix {
  String skuName, skuCode;

  PremixWithInfo({
    id,
    mrfPremixPlanDocId,
    batchNo,
    groupNo,
    uuid,
    isUpload,
    isDelete,
    timestamp,
    recipeName,
    docNo,
    formulaCategoryId,
    itemPackingId,
    this.skuName,
    this.skuCode,
  }) : super(
          id: id,
          mrfPremixPlanDocId: mrfPremixPlanDocId,
          batchNo: batchNo,
          groupNo: groupNo,
          uuid: uuid,
          isUpload: isUpload,
          isDelete: isDelete,
          timestamp: timestamp,
          recipeName: recipeName,
          docNo: docNo,
          formulaCategoryId: formulaCategoryId,
          itemPackingId: itemPackingId,
        );

  factory PremixWithInfo.fromJson(Map<String, dynamic> json) {
    return PremixWithInfo(
      id: json["id"],
      mrfPremixPlanDocId: json["mrf_premix_plan_doc_id"],
      batchNo: json["batch_no"],
      groupNo: json["group_no"],
      uuid: json["uuid"],
      isUpload: json["is_upload"],
      isDelete: json["is_delete"],
      timestamp: json["timestamp"],
      recipeName: json["recipe_name"],
      docNo: json["doc_no"],
      formulaCategoryId: json["formula_category_id"],
      itemPackingId: json["item_packing_id"],
      skuCode: json["sku_code"],
      skuName: json["sku_name"],
    );
  }
}
