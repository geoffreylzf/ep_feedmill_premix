import 'package:ep_feedmill/db/app_db.dart';
import 'package:ep_feedmill/model/table/mrf_premix_plan_doc.dart';

const _table = "mrf_premix_plan_doc";

class MrfPremixPlanDocDao {
  static final _instance = MrfPremixPlanDocDao._internal();

  MrfPremixPlanDocDao._internal();

  factory MrfPremixPlanDocDao() => _instance;

  Future<int> insert(MrfPremixPlanDoc mrfPremixPlanDoc) async {
    var db = await AppDb().database;
    var res = await db.insert(_table, mrfPremixPlanDoc.toDbInsertJson());
    return res;
  }

  Future<MrfPremixPlanDocWithInfo> getByIdWithInfo(
      int mrfPremixPlanDocId) async {
    var db = await AppDb().database;
    var res = await db.rawQuery("""
    SELECT
    mrf_premix_plan_doc.*,
    item_packing.sku_code,
    item_packing.sku_name
    FROM mrf_premix_plan_doc
    LEFT JOIN item_packing 
      ON mrf_premix_plan_doc.item_packing_id = item_packing.id
    WHERE mrf_premix_plan_doc.id = ?
    """, [mrfPremixPlanDocId]);
    return res.isNotEmpty ? MrfPremixPlanDocWithInfo.fromJson(res.first) : null;
  }

  Future<List<MrfPremixPlanDoc>> getAll() async {
    var db = await AppDb().database;
    var res = await db.query(_table);
    return res.isNotEmpty
        ? res.map((c) => MrfPremixPlanDoc.fromJson(c)).toList()
        : [];
  }

  Future<int> deleteAll() async {
    var db = await AppDb().database;
    return await db.delete(_table);
  }
}

class MrfPremixPlanDocWithInfo extends MrfPremixPlanDoc {
  String skuName, skuCode;

  MrfPremixPlanDocWithInfo({
    id,
    formulaCategoryId,
    itemPackingId,
    totalBatch,
    recipeName,
    docNo,
    docDate,
    remarks,
    this.skuCode,
    this.skuName,
  }) : super(
          id: id,
          formulaCategoryId: formulaCategoryId,
          itemPackingId: itemPackingId,
          totalBatch: totalBatch,
          recipeName: recipeName,
          docNo: docNo,
          docDate: docDate,
          remarks: remarks,
        );

  factory MrfPremixPlanDocWithInfo.fromJson(Map<String, dynamic> json) =>
      new MrfPremixPlanDocWithInfo(
        id: json["id"],
        recipeName: json["recipe_name"],
        formulaCategoryId: json["formula_category_id"],
        docNo: json["doc_no"],
        docDate: json["doc_date"],
        itemPackingId: json["item_packing_id"],
        remarks: json["remarks"],
        totalBatch: json["total_batch"],
        skuCode: json["sku_code"],
        skuName: json["sku_name"],
      );
}
