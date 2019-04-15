import 'package:ep_feedmill/db/app_db.dart';
import 'package:ep_feedmill/model/table/mrf_premix_plan_detail.dart';
import 'package:flutter/foundation.dart';

const _table = "mrf_premix_plan_detail";

class MrfPremixPlanDetailDao {
  static final _instance = MrfPremixPlanDetailDao._internal();

  MrfPremixPlanDetailDao._internal();

  factory MrfPremixPlanDetailDao() => _instance;

  Future<int> insert(MrfPremixPlanDetail mrfPremixPlanDocDetail) async {
    var db = await AppDb().database;
    var res = await db.insert(_table, mrfPremixPlanDocDetail.toJson());
    return res;
  }

  Future<List<MrfPremixPlanDetail>> getAll() async {
    var db = await AppDb().database;
    var res = await db.query(_table);
    return res.isNotEmpty
        ? res.map((c) => MrfPremixPlanDetail.fromJson(c)).toList()
        : [];
  }

  Future<int> deleteAll() async {
    var db = await AppDb().database;
    return await db.delete(_table);
  }

  Future<List<MrfPremixPlanDetailWithInfo>>
      getByMrfPremixPlanDocIdGroupNoWithInfoNotInTemp(
          {@required int mrfPremixPlanDocId, @required int groupNo}) async {
    var db = await AppDb().database;
    var res = await db.rawQuery("""
    SELECT 
    mrf_premix_plan_detail.*,
    item_packing.sku_code,
    item_packing.sku_name
    FROM mrf_premix_plan_detail 
    LEFT JOIN item_packing 
      ON mrf_premix_plan_detail.item_packing_id = item_packing.id
    WHERE mrf_premix_plan_doc_id = ?
    AND group_no = ?
    AND item_packing.id NOT in (SELECT item_packing_id FROM temp_premix_detail)
    """, [mrfPremixPlanDocId, groupNo]);
    return res.isNotEmpty
        ? res.map((c) => MrfPremixPlanDetailWithInfo.fromJson(c)).toList()
        : [];
  }

  Future<MrfPremixPlanDetailWithInfo>
      getByMrfPremixPlanDocIdGroupNoItemPackingId(
          {@required int mrfPremixPlanDocId,
          @required int groupNo,
          @required int itemPackingId}) async {
    var db = await AppDb().database;
    var res = await db.rawQuery("""
    SELECT 
    mrf_premix_plan_detail.*,
    item_packing.sku_code,
    item_packing.sku_name
    FROM mrf_premix_plan_detail 
    LEFT JOIN item_packing 
      ON mrf_premix_plan_detail.item_packing_id = item_packing.id
    WHERE mrf_premix_plan_doc_id = ?
    AND group_no = ? 
    AND item_packing.id = ?
    """, [mrfPremixPlanDocId, groupNo, itemPackingId]);
    return res.isNotEmpty
        ? MrfPremixPlanDetailWithInfo.fromJson(res.first)
        : null;
  }
}

class MrfPremixPlanDetailWithInfo extends MrfPremixPlanDetail {
  String skuName, skuCode;

  MrfPremixPlanDetailWithInfo({
    id,
    mrfPremixPlanDocId,
    groupNo,
    itemPackingId,
    formulaWeight,
    this.skuName,
    this.skuCode,
  }) : super(
          id: id,
          mrfPremixPlanDocId: mrfPremixPlanDocId,
          groupNo: groupNo,
          itemPackingId: itemPackingId,
          formulaWeight: formulaWeight,
        );

  factory MrfPremixPlanDetailWithInfo.fromJson(Map<String, dynamic> json) =>
      new MrfPremixPlanDetailWithInfo(
        id: json["id"],
        mrfPremixPlanDocId: json["mrf_premix_plan_doc_id"],
        groupNo: json["group_no"],
        itemPackingId: json["item_packing_id"],
        formulaWeight: json["formula_weight"] is int
            ? (json["formula_weight"] as int).toDouble()
            : json["formula_weight"],
        skuCode: json["sku_code"],
        skuName: json["sku_name"],
      );
}
