import 'package:ep_feedmill/db/app_db.dart';

class UtilDao {
  static final _instance = UtilDao._internal();

  UtilDao._internal();

  factory UtilDao() => _instance;

  Future<int> getNoUploadCount() async {
    final db = await AppDb().database;
    final res = await db.rawQuery("""
    SELECT
      COUNT(*) as count
    FROM premix
    WHERE is_upload = 0
    """);

    return res.isNotEmpty ? res.first['count'] : 0;
  }
}
