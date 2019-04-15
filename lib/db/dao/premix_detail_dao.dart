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
}
