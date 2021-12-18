import 'dart:convert';

LoginResponse loginResponseFromJson(String str) => LoginResponse.fromJson(json.decode(str));

String loginResponseToJson(LoginResponse data) => json.encode(data.toJson());

class LoginResponse {

  Data? data;
  String? status;
  String? error="";

  LoginResponse({
    this.data,
    this.status,
    this.error
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
      data: Data.fromJson(json["data"]),
      status: json["status"],
      error: json["error"]
  );

  Map<String, dynamic> toJson() => {
    "data": data!.toJson()??"{}",
    "status": status,
    "error":error
  };
}

class Data {
  Data({
    this.session,
    this.user,
  });

  Session? session;
  User? user;

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    session: Session.fromJson(json["session"]),
    user: User.fromJson(json["user"]),
  );

  Map<String, dynamic> toJson() => {
    "session": session!.toJson(),
    "user": user!.toJson(),
  };
}

class Session {
  Session({
    this.id,
    this.mtime,
    this.dtime,
    this.username,
    this.userId,
    this.ctime,
  });

  String? id;
  int? mtime;
  int? dtime;
  String? username;
  String? userId;
  int? ctime;

  factory Session.fromJson(Map<String, dynamic> json) => Session(
    id: json["id"],
    mtime: json["mtime"],
    dtime: json["dtime"],
    username: json["username"],
    userId: json["user_id"],
    ctime: json["ctime"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "mtime": mtime,
    "dtime": dtime,
    "username": username,
    "user_id": userId,
    "ctime": ctime,
  };
}

class User {
  User({
    this.id,
    this.mtime,
    this.dtime,
    this.username,
    this.name,
    this.password,
    this.primaryPassword,
    this.phone,
    this.sex,
    this.birthday,
    this.nationality,
    this.avatar,
    this.background,
    this.readedLaw,
    this.verify,
    this.home,
    this.active,
    this.expotoken,
    this.statusactive,
    this.location,
    this.language,
    this.job,
    this.warninglevel,
    this.reportnumber,
  });

  String? id;
  int? mtime;
  int? dtime;
  String? username;
  String? name;
  String? password;
  String? primaryPassword;
  String? phone;
  String? sex;
  String? birthday;
  String? nationality;
  String? avatar;
  String? background;
  bool? readedLaw;
  bool? verify;
  Home? home;
  bool? active;
  String? expotoken;
  Statusactive? statusactive;
  Home? location;
  String? language;
  String? job;
  int? warninglevel;
  int? reportnumber;

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json["id"],
    mtime: json["mtime"],
    dtime: json["dtime"],
    username: json["username"],
    name: json["name"],
    password: json["Password"],
    primaryPassword: json["PrimaryPassword"],
    phone: json["phone"],
    sex: json["sex"],
    birthday: json["birthday"],
    nationality: json["nationality"],
    avatar: json["avatar"],
    background: json["background"],
    readedLaw: json["readed_law"],
    verify: json["verify"],
    home: Home.fromJson(json["home"]),
    active: json["active"],
    expotoken: json["expotoken"],
    statusactive: Statusactive.fromJson(json["statusactive"]),
    location: Home.fromJson(json["location"]),
    language: json["language"],
    job: json["job"],
    warninglevel: json["warninglevel"],
    reportnumber: json["reportnumber"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "mtime": mtime,
    "dtime": dtime,
    "username": username,
    "name": name,
    "Password": password,
    "PrimaryPassword": primaryPassword,
    "phone": phone,
    "sex": sex,
    "birthday": birthday,
    "nationality": nationality,
    "avatar": avatar,
    "background": background,
    "readed_law": readedLaw,
    "verify": verify,
    "home": home!.toJson(),
    "active": active,
    "expotoken": expotoken,
    "statusactive": statusactive!.toJson(),
    "location": location!.toJson(),
    "language": language,
    "job": job,
    "warninglevel": warninglevel,
    "reportnumber": reportnumber,
  };
}

class Home {
  Home({
    this.address,
    this.type,
    this.coordinates,
  });

  String? address;
  String? type;
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

class Statusactive {
  Statusactive({
    this.online,
    this.roomid,
    this.timeout,
    this.device,
  });

  bool? online;
  String? roomid;
  int? timeout;
  String? device;

  factory Statusactive.fromJson(Map<String, dynamic> json) => Statusactive(
    online: json["online"],
    roomid: json["roomid"],
    timeout: json["timeout"],
    device: json["device"],
  );

  Map<String, dynamic> toJson() => {
    "online": online,
    "roomid": roomid,
    "timeout": timeout,
    "device": device,
  };
}
class LoginErrorResponse {
  String? error;
  String? status;

  LoginErrorResponse({this.error, this.status});

  LoginErrorResponse.fromJson(Map<String, dynamic> json) {
    error = json['error'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['error'] = this.error;
    data['status'] = this.status;
    return data;
  }
}