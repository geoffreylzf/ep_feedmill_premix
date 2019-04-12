class TempPremixDetail {
  int id, mrfPremixPlanDetailId, itemPackingId, isBt;
  double grossWeight, tareWeight, netWeight;

  TempPremixDetail(
      {this.id,
      this.mrfPremixPlanDetailId,
      this.itemPackingId,
      this.grossWeight,
      this.tareWeight,
      this.netWeight,
      this.isBt});

  factory TempPremixDetail.fromJson(Map<String, dynamic> json) =>
      new TempPremixDetail(
        id: json["id"],
        mrfPremixPlanDetailId: json["mrf_premix_plan_detail_id"],
        itemPackingId: json["item_packing_id"],
        grossWeight: json["gross_weight"],
        tareWeight: json["tare_weight"],
        netWeight: json["net_weight"],
        isBt: json["is_bt"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "mrf_premix_plan_detail_id": mrfPremixPlanDetailId,
        "item_packing_id": itemPackingId,
        "gross_weight": grossWeight,
        "tare_weight": tareWeight,
        "net_weight": netWeight,
        "is_bt": isBt,
      };
}
