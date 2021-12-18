// To parse this JSON data, do
//
//     final inforResponse = inforResponseFromJson(jsonString);

import 'dart:convert';

InforResponse inforResponseFromJson(String str) => InforResponse.fromJson(json.decode(str));

String inforResponseToJson(InforResponse data) => json.encode(data.toJson());

class InforResponse {
  InforResponse({
    this.data,
    this.status,
  });

  Data2 ?data;
  String ?status;

  factory InforResponse.fromJson(Map<String, dynamic> json) => InforResponse(
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
    this.name,
    this.home,
    this.avatar,
    this.background,
    this.job,
    this.rankname,
    this.levelUpPercent,
    this.starnumber,
    this.fbNumber,
    this.phone,
    this.email,
    this.introduction,
  });

  String ?id;
  String ?name;
  Home ?home;
  String ?avatar;
  String ?background;
  String ?job;
  String ?rankname;
  dynamic levelUpPercent;
  int ?starnumber;
  int ?fbNumber;
  String ?phone;
  String ?email;
  String ?introduction;

  factory Data2.fromJson(Map<String, dynamic> json) => Data2(
    id: json["id"],
    name: json["name"],
    home: Home.fromJson(json["home"]),
    avatar: json["avatar"],
    background: json["background"],
    job: json["job"],
    rankname: json["rankname"],
    levelUpPercent: json["level_up_percent"],
    starnumber: json["starnumber"],
    fbNumber: json["fb_number"],
    phone: json["phone"],
    email: json["email"],
    introduction: json["introduction"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "home": home!.toJson(),
    "avatar": avatar,
    "background": background,
    "job": job,
    "rankname": rankname,
    "level_up_percent": levelUpPercent,
    "starnumber": starnumber,
    "fb_number": fbNumber,
    "phone": phone,
    "email": email,
    "introduction": introduction,
  };
}

class Home {
  Home({
    this.address,
    this.type,
    this.coordinates,
  });

  String ?address;
  String ?type;
  List<double>? coordinates;

  factory Home.fromJson(Map<String, dynamic> json) => Home(
    address: json["address"],
    type: json["type"],
    coordinates: List<double>.from(json["coordinates"].map((x) => x.toDouble())),
  );

  Map<String, dynamic> toJson() => {
    "address": address,
    "type": type,
    "coordinates": List<dynamic>.from(coordinates!.map((x) => x)),
  };
}
