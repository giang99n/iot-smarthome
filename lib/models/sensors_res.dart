
import 'dart:convert';

SensorsResponse sensorsResponseFromJson(String str) => SensorsResponse.fromJson(json.decode(str));

String sensorsResponseToJson(SensorsResponse data) => json.encode(data.toJson());

class SensorsResponse {
  SensorsResponse({
    this.code,
    this.message,
    this.data,
  });

  int? code;
  String? message;
  List<Datum>? data;

  factory SensorsResponse.fromJson(Map<String, dynamic> json) => SensorsResponse(
    code: json["code"] == null ? null : json["code"],
    message: json["message"] == null ? null : json["message"],
    data: json["data"] == null ? null : List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "code": code == null ? null : code,
    "message": message == null ? null : message,
    "data": data == null ? null : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class Datum {
  Datum({
    this.humidityAir,
    this.temperature,
    this.time,
  });

  double? humidityAir;
  double? temperature;
  DateTime? time;

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    humidityAir: json["humidityAir"] == null ? null : json["humidityAir"].toDouble(),
    temperature: json["temperature"] == null ? null : json["temperature"].toDouble(),
    time: json["time"] == null ? null : DateTime.parse(json["time"]),
  );

  Map<String, dynamic> toJson() => {
    "humidityAir": humidityAir == null ? null : humidityAir,
    "temperature": temperature == null ? null : temperature,
    "time": time == null ? null : time!.toIso8601String(),
  };
}
