import 'package:ep_feedmill/model/table/temp_premix_detail.dart';
import 'package:flutter/material.dart';

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

  PremixDetail.db({
    @required this.premixId,
    @required this.mrfPremixPlanDetailId,
    @required this.itemPackingId,
    @required this.grossWeight,
    @required this.tareWeight,
    @required this.netWeight,
    @required this.isBt,
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

  static List<PremixDetail> fromTempWithPremixId(
      int premixId, List<TempPremixDetail> tempList) {
    final List<PremixDetail> detailList = [];

    tempList.forEach((temp) {
      detailList.add(PremixDetail.db(
          premixId: premixId,
          mrfPremixPlanDetailId: temp.mrfPremixPlanDetailId,
          itemPackingId: temp.itemPackingId,
          grossWeight: temp.grossWeight,
          tareWeight: temp.tareWeight,
          netWeight: temp.netWeight,
          isBt: temp.isBt));
    });

    return detailList;
  }
}
