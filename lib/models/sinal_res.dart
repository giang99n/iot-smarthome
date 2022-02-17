// To parse this JSON data, do
//
//     final inforResponse = inforResponseFromJson(jsonString);

import 'dart:convert';

SinalResponse inforResponseFromJson(String str) => SinalResponse.fromJson(json.decode(str));

String inforResponseToJson(SinalResponse data) => json.encode(data.toJson());

class SinalResponse {
  SinalResponse({
    this.data,
    this.status,
  });

  Data2 ?data;
  String ?status;

  factory SinalResponse.fromJson(Map<String, dynamic> json) => SinalResponse(
    data: Data2.fromJson(json["data"]),
    status: json["status"],
  );

  Map<String, dynamic> toJson() => {
    "data": data!.toJson(),
    "status": status,
  };
}

class Data2 {
  Data2({
    this.id,
    this.sinal,
  });

  String ?id;
  String ?sinal;


  factory Data2.fromJson(Map<String, dynamic> json) => Data2(
    id: json["id"],
    sinal: json["sinal"],

  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "sinal": sinal,
  };
}

