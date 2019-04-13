import 'dart:convert';

import 'package:ep_feedmill/model/api_response.dart';
import 'package:ep_feedmill/model/auth.dart';
import 'package:ep_feedmill/model/table/item_packing.dart';
import 'package:ep_feedmill/model/table/mrf_premix_plan_doc.dart';
import 'package:ep_feedmill/model/user.dart';
import 'package:ep_feedmill/module/shared_preferences_module.dart';
import 'package:http/http.dart';

class ApiModule {
  static final _instance = ApiModule._internal();

  factory ApiModule() => _instance;

  ApiModule._internal();

  static const _globalUrl =
      "http://epgroup.dlinkddns.com:5030/eperp/index.php?r=";
  static const _localUrl = "http://192.168.8.1:8833/eperp/index.php?r=";

  static const _loginModule = "apiMobileAuth/login";
  static const _housekeepingModule = "apiMobileFeedmill/getHouseKeeping";

  bool isLocal = true;

  String constructUrl(String module) {
    if (isLocal) {
      return _localUrl + module;
    }
    return _globalUrl + module;
  }

  String validateResponse(Response response) {
    if (response.statusCode == 200) {
      return response.body;
    }
    throw Exception('Connection Failed');
  }

  Future<ApiResponse<Auth>> login(
      String username, String password, String email) async {
    String basicAuth = User(username, password).getCredential();

    final response = await post(constructUrl(_loginModule),
        headers: {'authorization': basicAuth}, body: {"email": email});

    return ApiResponse.fromJson(jsonDecode(validateResponse(response)));
  }

  Future<ApiResponse<List<ItemPacking>>> getItemPacking() async {
    final user = await SharedPreferencesModule().getUser();
    String basicAuth = user.getCredential();

    final response = await get(
      constructUrl(_housekeepingModule) + "&type=item_packing",
      headers: {'authorization': basicAuth},
    );
    return ApiResponse.fromJson(jsonDecode(validateResponse(response)));
  }

  Future<ApiResponse<List<MrfPremixPlanDoc>>> getMrfPremixPlanDoc() async {
    final user = await SharedPreferencesModule().getUser();
    String basicAuth = user.getCredential();
    
    final response = await get(
      constructUrl(_housekeepingModule) + "&type=mrf_premix_plan_doc",
      headers: {'authorization': basicAuth},
    );
    return ApiResponse.fromJson(jsonDecode(validateResponse(response)));
  }
}
