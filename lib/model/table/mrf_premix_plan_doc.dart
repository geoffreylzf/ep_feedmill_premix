import 'package:ep_feedmill/model/table/mrf_premix_plan_detail.dart';

class MrfPremixPlanDoc {
  int id, formulaCategoryId, itemPackingId, totalBatch;
  String recipeName, docNo, docDate, remarks;
  List<MrfPremixPlanDetail> mrfPremixPlanDetailList;

  MrfPremixPlanDoc({
    this.id,
    this.recipeName,
    this.formulaCategoryId,
    this.docNo,
    this.docDate,
    this.itemPackingId,
    this.totalBatch,
    this.remarks,
    this.mrfPremixPlanDetailList,
  });

  factory MrfPremixPlanDoc.fromJson(Map<String, dynamic> json) {
    return MrfPremixPlanDoc(
      id: json["id"],
      recipeName: json["recipe_name"],
      formulaCategoryId: json["formula_category_id"],
      docNo: json["doc_no"],
      docDate: json["doc_date"],
      itemPackingId: json["item_packing_id"],
      remarks: json["remarks"],
      totalBatch: json["total_batch"],
      mrfPremixPlanDetailList: json["mrf_premix_plan_detail_list"] != null
          ? List<MrfPremixPlanDetail>.from(json["mrf_premix_plan_detail_list"]
              .map((dt) => MrfPremixPlanDetail.fromJson(dt)))
          : [],
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "recipe_name": recipeName,
        "formula_category_id": formulaCategoryId,
        "doc_no": docNo,
        "doc_date": docDate,
        "item_packing_id": itemPackingId,
        "remarks": remarks,
        "total_batch": totalBatch,
        "mrf_premix_plan_detail_list":
            List<dynamic>.from(mrfPremixPlanDetailList.map((x) => x.toJson())),
      };

  Map<String, dynamic> toDbInsertJson() {
    return toJson()..remove("mrf_premix_plan_detail_list");
  }
}
