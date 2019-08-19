class UploadResult {
  final List<int> premixIdList;

  final int recordCount;

  UploadResult({this.premixIdList, this.recordCount});

  factory UploadResult.fromJson(Map<String, dynamic> json) => UploadResult(
        premixIdList: json["premix_id_list"] != null
            ? List<int>.from(json["premix_id_list"].map((x) => x))
            : [],
        recordCount: json["recordCount"] != null ? json["recordCount"] : 0,
      );
}
