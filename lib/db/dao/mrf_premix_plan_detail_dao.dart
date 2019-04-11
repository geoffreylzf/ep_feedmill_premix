import 'package:ep_feedmill/db/app_db.dart';
import 'package:ep_feedmill/model/mrf_premix_plan_detail.dart';

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
}
