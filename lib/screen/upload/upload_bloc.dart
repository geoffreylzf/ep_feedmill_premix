import 'package:ep_feedmill/bloc/bloc_base.dart';
import 'package:ep_feedmill/db/dao/log_dao.dart';
import 'package:ep_feedmill/db/dao/util_dao.dart';
import 'package:ep_feedmill/model/table/log.dart';
import 'package:ep_feedmill/model/upload_body.dart';
import 'package:ep_feedmill/module/api_module.dart';
import 'package:ep_feedmill/repository/premix_repository.dart';
import 'package:ep_feedmill/repository/upload_repository.dart';
import 'package:ep_feedmill/res/string.dart';
import 'package:ep_feedmill/screen/upload/upload_screen.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class UploadBloc extends BlocBase {
  final _uploadLogListSubject = BehaviorSubject<List<Log>>();
  final _noUploadCountSubject = BehaviorSubject<int>();
  final _isLoadingSubject = BehaviorSubject<bool>.seeded(false);

  Stream<List<Log>> get uploadLogListStream => _uploadLogListSubject.stream;

  Stream<int> get noUploadCountStream => _noUploadCountSubject.stream;

  Stream<bool> get isLoadingStream => _isLoadingSubject.stream;

  @override
  void dispose() {
    _uploadLogListSubject.close();
    _noUploadCountSubject.close();
    _isLoadingSubject.close();
  }

  UploadDelegate _delegate;

  UploadBloc({@required UploadDelegate delegate}) {
    _delegate = delegate;
    _init();
  }

  _init() async {
    await loadLog();
    await loadNoUploadCount();
  }

  loadLog() async {
    _uploadLogListSubject.add(await LogDao().getAllByTask(Log.logTaskUpload));
  }

  loadNoUploadCount() async {
    _noUploadCountSubject.add(await UtilDao().getNoUploadCount());
  }

  upload() async {
    if (_noUploadCountSubject.value != 0) {
      try {
        _isLoadingSubject.add(true);
        final premixList = await PremixRepository().getPreparedUploadData();
        final uploadBody = UploadBody(premixList: premixList);

        final idList =
            (await ApiModule().upload(uploadBody)).result.premixIdList;

        await PremixRepository().updateUploadStatus(ids: idList);

        await UploadRepository().insert(Log.logTaskUpload,
            "${idList.length.toString()} record(s) uploaded");

        await loadLog();
        await loadNoUploadCount();
        _delegate.onDialogMessage(Strings.success, "Upload complete.");
      } catch (e) {
        _delegate.onDialogMessage(Strings.error, e.toString());
      } finally {
        _isLoadingSubject.add(false);
      }
    } else {
      _delegate.onDialogMessage(Strings.error, "No data to upload.");
    }
  }
}
