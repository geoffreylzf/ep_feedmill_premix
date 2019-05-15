import 'package:ep_feedmill/db/dao/log_dao.dart';
import 'package:ep_feedmill/model/table/log.dart';

class UploadRepository {
  static final _instance = UploadRepository._internal();

  UploadRepository._internal();

  factory UploadRepository() => _instance;

  insert(String task, remark) async {
    final log = Log.dbInsert(
      task: task,
      remark: remark,
    );
    log.setCurrentTimestamp();
    await LogDao().insert(log);
  }
}
