import 'package:ep_feedmill/db/app_db.dart';
import 'package:ep_feedmill/model/table/item_packing.dart';

const _table = "item_packing";

class ItemPackingDao {
  static final _instance = ItemPackingDao._internal();

  ItemPackingDao._internal();

  factory ItemPackingDao() => _instance;

  Future<int> insert(ItemPacking itemPacking) async {
    var db = await AppDb().database;
    var res = await db.insert(_table, itemPacking.toJson());
    return res;
  }

  Future<List<ItemPacking>> getAll() async {
    var db = await AppDb().database;
    var res = await db.query(_table);
    List<ItemPacking> list =
        res.isNotEmpty ? res.map((c) => ItemPacking.fromJson(c)).toList() : [];
    return list;
  }

  Future<int> deleteAll() async {
    var db = await AppDb().database;
    var res = await db.delete(_table);
    return res;
  }

  Future<ItemPacking> getById(int id) async {
    final db = await AppDb().database;
    final res = await db.query(_table, where: "id = ?", whereArgs: [id]);
    return res.isNotEmpty ? ItemPacking.fromJson(res.first) : null;
  }

  Future<int> getCount() async {
    final db = await AppDb().database;
    final res = await db.rawQuery("""
    SELECT
      COUNT(*) as count
    FROM item_packing
    """);
    return res.isNotEmpty ? res.first['count'] : 0;
  }
}
