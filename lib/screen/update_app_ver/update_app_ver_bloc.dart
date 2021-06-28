import 'dart:convert';

import 'package:ep_feedmill/bloc/bloc_base.dart';
import 'package:ep_feedmill/module/shared_preferences_module.dart';
import 'package:ep_feedmill/res/string.dart';
import 'package:flutter/widgets.dart';
import 'package:package_info/package_info.dart';
import 'package:rxdart/rxdart.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

const BASE_LOCAL_URL = "http://192.168.8.6";
const BASE_GLOBAL_URL = "http://epgroup.dyndns.org:5031";

abstract class UpdateAppVerDelegate {
  void onDialogMessage(String title, String message);
}

class UpdateAppVerBloc extends BlocBase {
  final _verCodeSubject = BehaviorSubject<int>();
  final _verNameSubject = BehaviorSubject<String>();
  final _appCodeSubject = BehaviorSubject<String>();

  Stream<int> get verCodeStream => _verCodeSubject.stream;

  Stream<String> get verNameStream => _verNameSubject.stream;

  Stream<String> get appCodeStream => _appCodeSubject.stream;

  UpdateAppVerDelegate _delegate;

  @override
  void dispose() {
    _verCodeSubject.close();
    _verNameSubject.close();
    _appCodeSubject.close();
  }

  UpdateAppVerBloc({@required UpdateAppVerDelegate delegate}) {
    _delegate = delegate;
    _init();
  }

  _init() async {
    final PackageInfo info = await PackageInfo.fromPlatform();

    _verCodeSubject.add(int.tryParse(info.buildNumber));
    _verNameSubject.add(info.version);
    _appCodeSubject.add(info.packageName);
  }

  void updateApp() async {
    String url = "/api/info/mobile/apps/${_appCodeSubject.value}/latest";

    try {
      final isLocal = await SharedPreferencesModule().getLocalCheck() ?? false;
      if (isLocal) {
        url = BASE_LOCAL_URL + url;
      } else {
        url = BASE_GLOBAL_URL + url;
      }

      final response = await http.get(url);
      if (response.statusCode >= 200 && response.statusCode <= 299) {
        final res = jsonDecode(response.body);
        final latestVerCode = int.tryParse(res['version_code'].toString());
        final latestVerDownloadLink = res['download_link'].toString();

        if (latestVerCode > _verCodeSubject.value) {
          if (await canLaunch(latestVerDownloadLink)) {
            await launch(latestVerDownloadLink);
          } else {
            _delegate.onDialogMessage(Strings.error, "Cannot launch download apk url");
          }
        } else if (latestVerCode == _verCodeSubject.value) {
          _delegate.onDialogMessage(Strings.error, "Current app is the latest version");
        } else {
          _delegate.onDialogMessage(Strings.error,
              "Current Ver : ${_verCodeSubject.value} \nLatest Ver : $latestVerCode");
        }
      } else {
        _delegate.onDialogMessage(Strings.error, response.body);
      }
    } catch (e) {
      _delegate.onDialogMessage(Strings.error, e.toString());
    }
  }
}
