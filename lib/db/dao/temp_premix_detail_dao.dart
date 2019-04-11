import 'package:ep_feedmill/db/app_db.dart';
import 'package:ep_feedmill/model/temp_premix_detail.dart';

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

  Future<List<TempPremixDetailWithIp>> getAll() async {
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
    List<TempPremixDetailWithIp> list = res.isNotEmpty
        ? res.map((c) => TempPremixDetailWithIp.fromJson(c)).toList()
        : [];
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

class TempPremixDetailWithIp {
  int id, itemPackingId;
  String skuName, skuCode;
  double grossWeight, tareWeight, netWeight;

  TempPremixDetailWithIp(
      {this.id,
      this.itemPackingId,
      this.skuCode,
      this.skuName,
      this.grossWeight,
      this.tareWeight,
      this.netWeight});

  factory TempPremixDetailWithIp.fromJson(Map<String, dynamic> json) =>
      new TempPremixDetailWithIp(
        id: json["id"],
        itemPackingId: json["item_packing_id"],
        skuCode: json["sku_code"],
        skuName: json["sku_name"],
        grossWeight: json["gross_weight"],
        tareWeight: json["tare_weight"],
        netWeight: json["net_weight"],
      );
}
