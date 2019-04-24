class UploadResult {
  final List<int> premixIdList;

  UploadResult({this.premixIdList});

  factory UploadResult.fromJson(Map<String, dynamic> json) => UploadResult(
        premixIdList: List<int>.from(json["premix_id_list"].map((x) => x)),
      );
}
