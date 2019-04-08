class DbSql {
  static final createItemPackingTable = """
      CREATE TABLE `item_packing` (
      `id` INTEGER PRIMARY KEY, 
      `sku_code` TEXT, 
      `sku_name` TEXT);
      """;

  static final createTempPremixDetailTable = """
      CREATE TABLE `temp_premix_detail` (
      `id` INTEGER PRIMARY KEY AUTOINCREMENT,
      `item_packing_id` INTEGER,
      `gross_weight` REAL,
      `tare_weight` REAL,
      `net_weight` REAL);
      """;
}
