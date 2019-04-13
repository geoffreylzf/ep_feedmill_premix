import 'package:ep_feedmill/model/table/premix_detail.dart';

/*const colId = "id";
const colMrfPremixPlanDocId = "mrf_premix_plan_doc_id";
const colBatchNo = "batch_no";
const colGroupNo = "group_no";
const colIsUpload = "is_upload";
const colIsDelete = "is_delete";
const colTimeStamp = "timestamp";
const oPremixDetailList = "premix_detail_list";*/

class Premix {
  int id, mrfPremixPlanDocId, batchNo, groupNo, isUpload, isDelete;
  String timestamp;
  List<PremixDetail> premixDetailList;

  Premix({
    this.id,
    this.mrfPremixPlanDocId,
    this.batchNo,
    this.groupNo,
    this.isUpload,
    this.isDelete,
    this.timestamp,
    this.premixDetailList,
  });

  factory Premix.fromJson(Map<String, dynamic> json) {
    return Premix(
      id: json["id"],
      mrfPremixPlanDocId: json["mrf_premix_plan_doc_id"],
      batchNo: json["batch_no"],
      groupNo: json["group_no"],
      isUpload: json["is_upload"],
      isDelete: json["is_delete"],
      timestamp: json["timestamp"],
      premixDetailList: json["premix_detail_list"] != null
          ? List<PremixDetail>.from(
              json["premix_detail_list"].map((dt) => PremixDetail.fromJson(dt)))
          : [],
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "mrf_premix_plan_doc_id": mrfPremixPlanDocId,
        "batch_no": batchNo,
        "group_no": groupNo,
        "is_upload": isUpload,
        "is_delete": isDelete,
        "timestamp": timestamp,
        "premix_detail_list":
            List<dynamic>.from(premixDetailList.map((x) => x.toJson())),
      };
}
