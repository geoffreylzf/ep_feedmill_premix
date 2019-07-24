import 'package:ep_feedmill/db/app_db.dart';
import 'package:ep_feedmill/model/table/temp_premix_detail.dart';
import 'package:flutter/cupertino.dart';

const _table = "temp_premix_detail";

class TempPremixDetailDao {
  static final _instance = TempPremixDetailDao._internal();

  TempPremixDetailDao._internal();

  factory TempPremixDetailDao() => _instance;

  Future<int> insert(TempPremixDetail tempPremixDetail) async {
    var db = await AppDb().database;
    var res = await db.insert(_table, tempPremixDetail.toJson());
    return res;
  }

  Future<TempPremixDetail> getByItemPackingId(int itemPackingId) async {
    var db = await AppDb().database;
    var res = await db.query(
      _table,
      where: "item_packing_id = ?",
      whereArgs: [itemPackingId],
    );
    return res.isNotEmpty ? TempPremixDetail.fromJson(res.first) : null;
  }

  Future<TempPremixDetail> getLast() async {
    var db = await AppDb().database;
    var res = await db.query(
      _table,
      orderBy: "id DESC",
    );
    return res.isNotEmpty ? TempPremixDetail.fromJson(res.first) : null;
  }

  Future<List<TempPremixDetailWithInfo>> getAll() async {
    var db = await AppDb().database;
    var res = await db.rawQuery("""
    SELECT 
      temp_premix_detail.*,
      item_packing.sku_code,
      item_packing.sku_name
    FROM temp_premix_detail
    LEFT JOIN item_packing 
      ON temp_premix_detail.item_packing_id = item_packing.id
    ORDER BY temp_premix_detail.id DESC
    """);
    List<TempPremixDetailWithInfo> list = res.isNotEmpty
        ? res.map((c) => TempPremixDetailWithInfo.fromJson(c)).toList()
        : [];
    return list;
  }

  Future<List<TempPremixDetailWithInfo>> getByPlanIdGroupNo(
      {@required int mrfPremixPlanDocId, @required int groupNo}) async {
    var db = await AppDb().database;
    var res = await db.rawQuery("""
    SELECT 
      temp_premix_detail.*,
      item_packing.sku_code,
      item_packing.sku_name,
      mrf_premix_plan_detail.sequence
    FROM mrf_premix_plan_detail
    LEFT JOIN temp_premix_detail ON temp_premix_detail.item_packing_id = mrf_premix_plan_detail.item_packing_id
    LEFT JOIN item_packing ON mrf_premix_plan_detail.item_packing_id = item_packing.id
    WHERE mrf_premix_plan_detail.mrf_premix_plan_doc_id = ?
    AND group_no = ? 
    ORDER BY mrf_premix_plan_detail.sequence
    """, [mrfPremixPlanDocId, groupNo]);
    List<TempPremixDetailWithInfo> list =
        res.isNotEmpty ? res.map((c) => TempPremixDetailWithInfo.fromJson(c)).toList() : [];
    return list;
  }

  Future<List<TempPremixDetailWithInfo>> getAddOnByPlanIdGroupNo(
      {@required int mrfPremixPlanDocId, @required int groupNo}) async {
    var db = await AppDb().database;
    var res = await db.rawQuery("""
    SELECT 
      temp_premix_detail.*,
      item_packing.sku_code,
      item_packing.sku_name,
      -1 AS sequence
    FROM temp_premix_detail
    LEFT JOIN item_packing ON temp_premix_detail.item_packing_id = item_packing.id
    WHERE temp_premix_detail.item_packing_id NOT IN 
      (SELECT item_packing_id 
      FROM mrf_premix_plan_detail 
      WHERE mrf_premix_plan_doc_id = ? 
      AND group_no = ? )
    ORDER BY temp_premix_detail.id DESC
    """, [mrfPremixPlanDocId, groupNo]);
    List<TempPremixDetailWithInfo> list =
    res.isNotEmpty ? res.map((c) => TempPremixDetailWithInfo.fromJson(c)).toList() : [];
    return list;
  }

  Future<int> deleteById(int id) async {
    var db = await AppDb().database;
    return await db.delete(_table, where: "id = ?", whereArgs: [id]);
  }

  Future<int> deleteAll() async {
    var db = await AppDb().database;
    return await db.delete(_table);
  }
}

class TempPremixDetailWithInfo extends TempPremixDetail {
  int sequence;
  String skuName, skuCode;

  TempPremixDetailWithInfo({
    id,
    mrfPremixPlanDetailId,
    itemPackingId,
    grossWeight,
    tareWeight,
    netWeight,
    isBt,
    this.sequence,
    this.skuCode,
    this.skuName,
  }) : super(
          id: id,
          mrfPremixPlanDetailId: mrfPremixPlanDetailId,
          itemPackingId: itemPackingId,
          grossWeight: grossWeight,
          tareWeight: tareWeight,
          netWeight: netWeight,
          isBt: isBt,
        );

  factory TempPremixDetailWithInfo.fromJson(Map<String, dynamic> json) =>
      new TempPremixDetailWithInfo(
        id: json["id"],
        itemPackingId: json["item_packing_id"],
        mrfPremixPlanDetailId: json["mrf_premix_plan_detail_id"],
        grossWeight: json["gross_weight"],
        tareWeight: json["tare_weight"],
        netWeight: json["net_weight"],
        isBt: json["is_bt"],
        skuCode: json["sku_code"],
        skuName: json["sku_name"],
        sequence: json["sequence"],
      );
}
