class TempPremixDetail {
  int id, itemPackingId;
  double grossWeight, tareWeight, netWeight;

  TempPremixDetail(
      {this.id,
      this.itemPackingId,
      this.grossWeight,
      this.tareWeight,
      this.netWeight});

  factory TempPremixDetail.fromJson(Map<String, dynamic> json) =>
      new TempPremixDetail(
        id: json["id"],
        itemPackingId: json["item_packing_id"],
        grossWeight: json["gross_weight"],
        tareWeight: json["tare_weight"],
        netWeight: json["net_weight"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "item_packing_id": itemPackingId,
        "gross_weight": grossWeight,
        "tare_weight": tareWeight,
        "net_weight": netWeight,
      };
}
