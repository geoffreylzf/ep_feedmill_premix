class MrfFormulaCategory {
  static const breederId = 1;
  static const broilerId = 11;
  static const swineId = 21;

  int id;
  String formulaCategoryCode, formulaCategoryName;

  MrfFormulaCategory({
    this.id,
    this.formulaCategoryCode,
    this.formulaCategoryName,
  });

  factory MrfFormulaCategory.fromJson(Map<String, dynamic> json) =>
      MrfFormulaCategory(
        id: json["id"],
        formulaCategoryCode: json["formula_category_code"],
        formulaCategoryName: json["formula_category_name"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "formula_category_code": formulaCategoryCode,
        "formula_category_name": formulaCategoryName,
      };

  static String getSqlFilter({
    bool breeder = false,
    bool broiler = false,
    bool swine = false,
  }) {
    String sql = "null";

    if (breeder) {
      sql += ", $breederId";
    }
    if (broiler) {
      sql += ", $broilerId";
    }
    if (swine) {
      sql += ", $swineId";
    }

    return sql;
  }
}
