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

  static final createMrfPremixPlanDocTable = """
      CREATE TABLE `mrf_premix_plan_doc` (
      `id` INTEGER PRIMARY KEY,
      `recipe_name` TEXT,
      `doc_no` TEXT, 
      `doc_date` TEXT,  
      `item_packing_id` INTEGER,
      `remarks` TEXT,  
      `total_batch` INTEGER);
      """;

  static final createMrfPremixPlanDocDetailTable = """
      CREATE TABLE `mrf_premix_plan_detail` (
      `id` INTEGER PRIMARY KEY,
      `mrf_premix_plan_doc_id` INTEGER,
      `group_no` INTEGER,
      `item_packing_id` INTEGER,
      `formula_weight` REAL);
      """;
}
