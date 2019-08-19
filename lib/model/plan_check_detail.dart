class PlanCheckDetail {
  int groupNo, totalBatch, completeBatch, isVerify;
  String verifyDate;

  PlanCheckDetail({
    this.groupNo,
    this.totalBatch,
    this.completeBatch,
    this.isVerify,
    this.verifyDate,
  });

  factory PlanCheckDetail.fromJson(Map<String, dynamic> json) {
    return PlanCheckDetail(
      groupNo: json["group_no"],
      totalBatch: json["total_batch"],
      isVerify: json["is_verify"],
      verifyDate: json["verify_date"],
      completeBatch: json["complete_batch"],
    );
  }

  Map<String, dynamic> toJson() => {
    "group_no": groupNo,
    "total_batch": totalBatch,
    "is_verify": isVerify,
    "verify_date": verifyDate,
    "complete_batch": completeBatch,
  };

  Map<String, dynamic> toUploadJson() {
    return toJson()
      ..remove("total_batch")
      ..remove("verify_date")
      ..remove("complete_batch");
  }
}
