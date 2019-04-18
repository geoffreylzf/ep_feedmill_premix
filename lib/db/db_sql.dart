class DbSql {
  static final createItemPackingTable = """
      CREATE TABLE `item_packing` (
      `id` INTEGER PRIMARY KEY, 
      `sku_code` TEXT, 
      `sku_name` TEXT);
      """;

  static final createMrfFormulaCategoryTable = """
      CREATE TABLE `mrf_formula_category` (
      `id` INTEGER PRIMARY KEY, 
      `formula_category_code` TEXT, 
      `formula_category_name` TEXT);
      """;

  static final createMrfPremixPlanDocTable = """
      CREATE TABLE `mrf_premix_plan_doc` (
      `id` INTEGER PRIMARY KEY,
      `recipe_name` TEXT,
      `formula_category_id` INTEGER,
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

  static final createTempPremixDetailTable = """
      CREATE TABLE `temp_premix_detail` (
      `id` INTEGER PRIMARY KEY AUTOINCREMENT,
      `mrf_premix_plan_detail_id` INTEGER,
      `item_packing_id` INTEGER,
      `gross_weight` REAL,
      `tare_weight` REAL,
      `net_weight` REAL,
      `is_bt` INTEGER);
      """;

  static final createPremixTable = """
      CREATE TABLE `premix` (
      `id` INTEGER PRIMARY KEY AUTOINCREMENT,
      `mrf_premix_plan_doc_id` INTEGER,
      `batch_no` INTEGER,
      `group_no` INTEGER,
      `recipe_name` TEXT,
      `doc_no` TEXT, 
      `formula_category_id` INTEGER,
      `item_packing_id` INTEGER,
      `is_delete` INTEGER DEFAULT 0,
      `is_upload` INTEGER DEFAULT 0,
      `timestamp` TIMESTAMP);
      """;

  static final createPremixDetailTable = """
      CREATE TABLE `premix_detail` (
      `id` INTEGER PRIMARY KEY AUTOINCREMENT,
      `premix_id` INTEGER,
      `mrf_premix_plan_detail_id` INTEGER,
      `item_packing_id` INTEGER,
      `gross_weight` REAL,
      `tare_weight` REAL,
      `net_weight` REAL,
      `is_bt` INTEGER);
      """;
}
