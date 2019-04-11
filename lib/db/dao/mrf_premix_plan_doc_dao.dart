import 'package:ep_feedmill/db/app_db.dart';
import 'package:ep_feedmill/model/mrf_premix_plan_doc.dart';

const _table = "mrf_premix_plan_doc";

class MrfPremixPlanDocDao {
  static final _instance = MrfPremixPlanDocDao._internal();

  MrfPremixPlanDocDao._internal();

  factory MrfPremixPlanDocDao() => _instance;

  Future<int> insert(MrfPremixPlanDoc mrfPremixPlanDoc) async {
    var db = await AppDb().database;
    var res = await db.insert(_table, mrfPremixPlanDoc.toDbJson());
    return res;
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
