import 'package:ep_feedmill/bloc/bloc_base.dart';
import 'package:ep_feedmill/db/dao/premix_dao.dart';
import 'package:ep_feedmill/db/dao/util_dao.dart';
import 'package:ep_feedmill/model/table/premix.dart';
import 'package:ep_feedmill/model/upload_body.dart';
import 'package:ep_feedmill/module/api_module.dart';
import 'package:ep_feedmill/module/shared_preferences_module.dart';
import 'package:ep_feedmill/repository/premix_repository.dart';
import 'package:ep_feedmill/res/string.dart';
import 'package:ep_feedmill/screen/upload/upload_screen.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

import 'dart:convert';

class UploadBloc extends BlocBase {
  final _localCheckedSubject = BehaviorSubject<bool>();
  final _noUploadCountSubject = BehaviorSubject<int>();

  Stream<bool> get localCheckedStream => _localCheckedSubject.stream;

  Stream<int> get noUploadCountStream => _noUploadCountSubject.stream;

  @override
  void dispose() {
    _localCheckedSubject.close();
    _noUploadCountSubject.close();
  }

  UploadDelegate _delegate;

  UploadBloc({@required UploadDelegate delegate}) {
    _delegate = delegate;
    _init();
  }

  _init() async {
    _localCheckedSubject
        .add(await SharedPreferencesModule().getLocalCheck() ?? false);
    await loadNoUploadCount();
  }

  loadNoUploadCount() async {
    _noUploadCountSubject.add(await UtilDao().getNoUploadCount());
  }

  setLocalChecked(bool b) async {
    await SharedPreferencesModule().saveLocalCheck(b);
    _localCheckedSubject.add(b);
  }

  upload() async {
    if (_noUploadCountSubject.value != 0) {
      try {
        final premixList = await PremixRepository().getPreparedUploadData();
        final uploadBody = UploadBody(premixList: premixList);

        final response = await ApiModule().upload(uploadBody);

        await PremixRepository()
            .updateUploadStatus(ids: response.result.premixIdList);

        await loadNoUploadCount();
        _delegate.onDialogMessage(Strings.success, "Upload complete.");
      } catch (e) {
        _delegate.onDialogMessage(Strings.error, e.toString());
      }
    } else {
      _delegate.onDialogMessage(Strings.error, "No data to upload.");
    }
  }
}
