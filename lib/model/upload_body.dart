import 'package:ep_feedmill/model/plan_check.dart';
import 'package:ep_feedmill/model/table/premix.dart';

class UploadBody {
  List<Premix> premixList;
  List<PlanCheck> planCheckList;

  UploadBody({this.premixList, this.planCheckList});

  Map<String, dynamic> toJson() => {
        "premix_list": premixList != null && premixList.length > 0
            ? List<dynamic>.from(premixList.map((x) => x.toUploadJson()))
            : [],
        "plan_check_list": planCheckList != null && planCheckList.length > 0
            ? List<dynamic>.from(planCheckList.map((x) => x.toUploadJson()))
            : [],
      };
}
