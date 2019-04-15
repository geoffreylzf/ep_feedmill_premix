import 'package:intl/intl.dart';

class DateTimeUtil {
  final _timestampFormat = "yyyy-MM-dd HH:mm:ss";

  String getCurrentTimestamp() {
    return DateFormat(_timestampFormat).format(DateTime.now());
  }
}
