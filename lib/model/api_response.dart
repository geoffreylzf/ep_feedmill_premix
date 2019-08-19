import 'package:ep_feedmill/model/auth.dart';
import 'package:ep_feedmill/model/plan_check.dart';
import 'package:ep_feedmill/model/table/item_packing.dart';
import 'package:ep_feedmill/model/table/mrf_formula_category.dart';
import 'package:ep_feedmill/model/table/mrf_premix_plan_doc.dart';
import 'package:ep_feedmill/model/upload_result.dart';

class ApiResponse<T> {
  final int cod;
  final T result;

  ApiResponse({this.cod, this.result});

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    var result;
    if (T == Auth) {
      result = Auth.fromJson(json['result']);
    } else if (T == UploadResult) {
      result = UploadResult.fromJson(json['result']);
    } else if (T.toString() == "List<ItemPacking>") {
      result = List<ItemPacking>.from(json["result"].map((x) => ItemPacking.fromJson(x)));
    } else if (T.toString() == "List<MrfPremixPlanDoc>") {
      result = List<MrfPremixPlanDoc>.from(json["result"].map((x) => MrfPremixPlanDoc.fromJson(x)));
    } else if (T.toString() == "List<MrfFormulaCategory>") {
      result =
          List<MrfFormulaCategory>.from(json["result"].map((x) => MrfFormulaCategory.fromJson(x)));
    } else if (T.toString() == "List<PlanCheck>") {
      result = List<PlanCheck>.from(json["result"].map((x) => PlanCheck.fromJson(x)));
    }

    return ApiResponse(cod: json['cod'], result: result);
  }
}
