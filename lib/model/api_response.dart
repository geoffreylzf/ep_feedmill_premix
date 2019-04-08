import 'package:ep_feedmill/model/auth.dart';
import 'package:ep_feedmill/model/item_packing.dart';

class ApiResponse<T> {
  final int cod;
  final T result;

  ApiResponse({this.cod, this.result});

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    var result;
    if (T == Auth) {
      result = Auth.fromJson(json['result']);
    } else if (T.toString() == "List<ItemPacking>") {
      result = new List<ItemPacking>.from(
          json["result"].map((x) => ItemPacking.fromJson(x)));
    }
    return ApiResponse(cod: json['cod'], result: result);
  }
}
