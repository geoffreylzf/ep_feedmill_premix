class ItemPacking {
  int id, isPremix;
  String skuCode;
  String skuName;

  ItemPacking({
    this.id,
    this.skuCode,
    this.skuName,
    this.isPremix,
  });

  factory ItemPacking.fromJson(Map<String, dynamic> json) => ItemPacking(
        id: json["id"],
        skuCode: json["sku_code"],
        skuName: json["sku_name"],
        isPremix: json["is_premix"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "sku_code": skuCode,
        "sku_name": skuName,
        "is_premix": isPremix,
      };
}
