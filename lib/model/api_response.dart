import 'package:ep_feedmill/model/auth.dart';
import 'package:ep_feedmill/model/table/item_packing.dart';
import 'package:ep_feedmill/model/table/mrf_premix_plan_doc.dart';

class ApiResponse<T> {
  final int cod;
  final T result;

  ApiResponse({this.cod, this.result});

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    var result;

    if (T == Auth) {
      result = Auth.fromJson(json['result']);
    } else if (T.toString() == "List<ItemPacking>") {
      result = new List<ItemPacking>.from(
          json["result"].map((x) => ItemPacking.fromJson(x)));
    } else if (T.toString() == "List<MrfPremixPlanDoc>") {
      result = new List<MrfPremixPlanDoc>.from(
          json["result"].map((x) => MrfPremixPlanDoc.fromJson(x)));
    }

    return ApiResponse(cod: json['cod'], result: result);
  }
}
