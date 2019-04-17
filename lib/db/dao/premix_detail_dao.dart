import 'package:ep_feedmill/db/app_db.dart';
import 'package:ep_feedmill/model/table/premix_detail.dart';

const _table = "premix_detail";

class PremixDetailDao {
  static final _instance = PremixDetailDao._internal();

  PremixDetailDao._internal();

  factory PremixDetailDao() => _instance;

  Future<int> insert(PremixDetail premixDetail) async {
    var db = await AppDb().database;
    var res = await db.insert(_table, premixDetail.toJson());
    return res;
  }

  Future<List<PremixDetailWithInfo>> getByPremixId(int premixId) async {
    var db = await AppDb().database;
    var res = await db.rawQuery("""
    SELECT 
      premix_detail.*,
      item_packing.sku_code,
      item_packing.sku_name
    FROM premix_detail
    LEFT JOIN item_packing 
      ON premix_detail.item_packing_id = item_packing.id
    WHERE premix_detail.premix_id = ?
    ORDER BY premix_detail.id DESC
    """, [premixId]);
    List<PremixDetailWithInfo> list = res.isNotEmpty
        ? res.map((c) => PremixDetailWithInfo.fromJson(c)).toList()
        : [];
    return list;
  }
}

class PremixDetailWithInfo extends PremixDetail {
  String skuName, skuCode;

  PremixDetailWithInfo({
    id,
    premixId,
    mrfPremixPlanDetailId,
    itemPackingId,
    grossWeight,
    tareWeight,
    netWeight,
    isBt,
    this.skuCode,
    this.skuName,
  }) : super(
          id: id,
          premixId: premixId,
          mrfPremixPlanDetailId: mrfPremixPlanDetailId,
          itemPackingId: itemPackingId,
          grossWeight: grossWeight,
          tareWeight: tareWeight,
          netWeight: netWeight,
          isBt: isBt,
        );

  factory PremixDetailWithInfo.fromJson(Map<String, dynamic> json) {
    return PremixDetailWithInfo(
      id: json["id"],
      premixId: json["premix_id"],
      mrfPremixPlanDetailId: json["mrf_premix_plan_detail_id"],
      itemPackingId: json["item_packing_id"],
      grossWeight: json["gross_weight"],
      tareWeight: json["tare_weight"],
      netWeight: json["net_weight"],
      isBt: json["is_bt"],
      skuCode: json["sku_code"],
      skuName: json["sku_name"],
    );
  }
}
