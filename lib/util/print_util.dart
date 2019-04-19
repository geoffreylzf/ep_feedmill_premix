import 'package:ep_feedmill/db/dao/premix_dao.dart';
import 'package:ep_feedmill/db/dao/premix_detail_dao.dart';
import 'package:ep_feedmill/module/shared_preferences_module.dart';
import 'package:ep_feedmill/util/date_time_util.dart';

const _lineLimit = 45;
const _separator = "---------------------------------------------";

class PrintUtil {
  Future<String> generatePremixReceipt(int premixId) async {
    var s = "";
    final premix = await PremixDao().getById(premixId);
    final detailList = await PremixDetailDao().getByPremixId(premixId);
    final user = await SharedPreferencesModule().getUser();

    s += _fmtLeftLine("Premix Receipt");
    s += _fmtLeftLine("Recipe N.: " + premix.recipeName);
    s += _fmtLeftLine("Group    : " + premix.groupNo.toString());
    s += _fmtLeftLine("Batch    : " + premix.batchNo.toString());
    s += _fmtLeftLine("Sku Name : " + premix.skuName);
    s += _fmtLeftLine("Sku Code : " + premix.skuCode);
    s += _fmtLeftLine("Doc No   : " + premix.docNo);
    s += _fmtLeftLine("Timestamp: " + premix.timestamp);
    s += _fmtLeftLine();
    s += _fmtLeftLine("-----------------Ingredients-----------------");

    var ttlNetWeight = 0.0;

    detailList.forEach((d) {
      ttlNetWeight += d.netWeight;

      s += _fmtLeftLine(d.skuName);
      s += _fmtRightLine(d.netWeight.toStringAsFixed(2) + " Kg");
    });
    s += _fmtLeftLine(_separator);
    s += _fmtRightLine(ttlNetWeight.toStringAsFixed(2) + " Kg");
    s += _fmtLeftLine(_separator);

    s += _fmtLeftLine("Printed By : " + user.username);
    s += _fmtLeftLine("Date : " + DateTimeUtil().getCurrentDate());
    s += _fmtLeftLine("Time : " + DateTimeUtil().getCurrentTime());

    if(premix.isDeleted()){
      s += _fmtLeftLine("---Deleted---");
    }
    if(premix.isUploaded()){
      s += _fmtLeftLine("---Uploaded---");
    }
    s += _fmtLeftLine();
    s += _fmtLeftLine();
    s += _fmtLeftLine();
    s += _fmtLeftLine();
    s += _fmtLeftLine();

    return s;
  }

  String _fmtLeftLine([String text = ""]) {
    if (text.length > _lineLimit) {
      String s = "";
      final count = (text.length / _lineLimit).ceil();

      for (int i = 0; i < count; i++) {
        int start = i * _lineLimit;
        int end = (i + 1) * _lineLimit;

        if (end > text.length) {
          end = text.length;
        }
        s += text.substring(start, end) + "\n";
      }
      return s;
    } else {
      return text.padRight(_lineLimit) + "\n";
    }
  }

  String _fmtRightLine([String text = ""]) {
    return text.padLeft(_lineLimit) + "\n";
  }
}
