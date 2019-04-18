import 'package:ep_feedmill/db/app_db.dart';
import 'package:ep_feedmill/model/table/mrf_formula_category.dart';

const _table = "mrf_formula_category";

class MrfFormulaCategoryDao{
  static final _instance = MrfFormulaCategoryDao._internal();

  MrfFormulaCategoryDao._internal();

  factory MrfFormulaCategoryDao() => _instance;

  Future<int> insert(MrfFormulaCategory mrfFormulaCategory) async {
    var db = await AppDb().database;
    var res = await db.insert(_table, mrfFormulaCategory.toJson());
    return res;
  }

  Future<List<MrfFormulaCategory>> getAll() async {
    var db = await AppDb().database;
    var res = await db.query(_table);
    List<MrfFormulaCategory> list =
    res.isNotEmpty ? res.map((c) => MrfFormulaCategory.fromJson(c)).toList() : [];
    return list;
  }

  Future<int> deleteAll() async {
    var db = await AppDb().database;
    var res = await db.delete(_table);
    return res;
  }

  Future<MrfFormulaCategory> getById(int id) async {
    final db = await AppDb().database;
    final res = await db.query(_table, where: "id = ?", whereArgs: [id]);
    return res.isNotEmpty ? MrfFormulaCategory.fromJson(res.first) : null;
  }

  Future<int> getCount() async {
    final db = await AppDb().database;
    final res = await db.rawQuery("""
    SELECT
      COUNT(*) as count
    FROM mrf_formula_category
    """);
    return res.isNotEmpty ? res.first['count'] : 0;
  }
}