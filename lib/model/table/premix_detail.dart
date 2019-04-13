
const colId = "id";
class PremixDetail {
  int id, premixId, mrfPremixPlanDetailId, itemPackingId, isBt;
  double grossWeight, tareWeight, netWeight;

  PremixDetail({
    this.id,
    this.premixId,
    this.mrfPremixPlanDetailId,
    this.itemPackingId,
    this.grossWeight,
    this.tareWeight,
    this.netWeight,
    this.isBt,
  });

  factory PremixDetail.fromJson(Map<String, dynamic> json) {
    return PremixDetail(
      id: json["id"],
      premixId: json["premix_id"],
      mrfPremixPlanDetailId: json["mrf_premix_plan_detail_id"],
      itemPackingId: json["item_packing_id"],
      grossWeight: json["gross_weight"],
      tareWeight: json["tare_weight"],
      netWeight: json["net_weight"],
      isBt: json["is_bt"],
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "premix_id": premixId,
    "mrf_premix_plan_detail_id": mrfPremixPlanDetailId,
    "item_packing_id": itemPackingId,
    "gross_weight": grossWeight,
    "tare_weight": tareWeight,
    "net_weight": netWeight,
    "is_bt": isBt,
  };
}
