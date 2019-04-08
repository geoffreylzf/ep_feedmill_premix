import 'package:ep_feedmill/db/app_db.dart';
import 'package:ep_feedmill/model/item_packing.dart';

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
    var db = await AppDb().database;
    var res = await db.query(_table, where: "id = ?", whereArgs: [id]);
    return res.isNotEmpty ? ItemPacking.fromJson(res.first) : null;
  }
}
