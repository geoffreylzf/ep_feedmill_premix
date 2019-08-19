import 'package:ep_feedmill/model/plan_check_detail.dart';

class PlanCheck {
  int id;
  String docNo, docDate, recipeName, skuName;
  List<PlanCheckDetail> detailList;

  PlanCheck({
    this.id,
    this.docNo,
    this.docDate,
    this.recipeName,
    this.skuName,
    this.detailList,
  });

  factory PlanCheck.fromJson(Map<String, dynamic> json) {
    return PlanCheck(
      id: json["id"],
      recipeName: json["recipe_name"],
      docNo: json["doc_no"],
      docDate: json["doc_date"],
      skuName: json["sku_name"],
      detailList: json["details"] != null
          ? List<PlanCheckDetail>.from(json["details"].map((dt) => PlanCheckDetail.fromJson(dt)))
          : [],
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "recipe_name": recipeName,
        "doc_no": docNo,
        "doc_date": docDate,
        "sku_name": skuName,
        "details": List<dynamic>.from(detailList.map((x) => x.toJson())),
      };

  Map<String, dynamic> toUploadJson() => {
        "id": id,
        "details": List<dynamic>.from(detailList.map((x) => x.toUploadJson())),
      };
}
