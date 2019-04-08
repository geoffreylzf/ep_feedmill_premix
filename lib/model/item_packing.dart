class ItemPacking {
  int id;
  String skuCode;
  String skuName;

  ItemPacking({
    this.id,
    this.skuCode,
    this.skuName,
  });

  factory ItemPacking.fromJson(Map<String, dynamic> json) => new ItemPacking(
        id: json["id"],
        skuCode: json["sku_code"],
        skuName: json["sku_name"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "sku_code": skuCode,
        "sku_name": skuName,
      };
}
