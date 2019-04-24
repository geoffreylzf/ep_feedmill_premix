import 'package:ep_feedmill/model/table/premix.dart';

class UploadBody {
  List<Premix> premixList;

  UploadBody({this.premixList});

  Map<String, dynamic> toJson() => {
        "premix_list": premixList != null && premixList.length > 0
            ? List<dynamic>.from(premixList.map((x) => x.toUploadJson()))
            : [],
      };
}
