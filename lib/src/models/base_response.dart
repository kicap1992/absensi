// To parse this JSON data, do
//
//     final baseResponse = baseResponseFromJson(jsonString);

import 'dart:convert';

BaseResponse baseResponseFromJson(String str) =>
    BaseResponse.fromJson(json.decode(str));

String baseResponseToJson(BaseResponse data) => json.encode(data.toJson());

class BaseResponse {
  BaseResponse(
      {required this.status, required this.message, this.data, this.firstTime});

  bool status;
  String message;
  dynamic data;
  bool? firstTime;

  factory BaseResponse.fromJson(Map<String, dynamic> json) => BaseResponse(
        status: json["status"],
        message: json["message"],
        data: json["data"],
        firstTime: json["firstTime"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data,
        "firstTime": firstTime
      };
}
