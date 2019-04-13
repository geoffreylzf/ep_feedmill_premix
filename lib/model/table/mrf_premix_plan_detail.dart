class MrfPremixPlanDetail {
  int id, mrfPremixPlanDocId, groupNo, itemPackingId;
  double formulaWeight;

  MrfPremixPlanDetail(
      {this.id,
      this.mrfPremixPlanDocId,
      this.groupNo,
      this.itemPackingId,
      this.formulaWeight});

  factory MrfPremixPlanDetail.fromJson(Map<String, dynamic> json) {
    return MrfPremixPlanDetail(
      id: json["id"],
      mrfPremixPlanDocId: json["mrf_premix_plan_doc_id"],
      groupNo: json["group_no"],
      itemPackingId: json["item_packing_id"],
      formulaWeight: json["formula_weight"] is int
          ? (json["formula_weight"] as int).toDouble()
          : json["formula_weight"],
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "mrf_premix_plan_doc_id": mrfPremixPlanDocId,
        "group_no": groupNo,
        "item_packing_id": itemPackingId,
        "formula_weight": formulaWeight,
      };
}
