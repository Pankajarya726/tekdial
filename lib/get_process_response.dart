// To parse this JSON data, do
//
//     final getProcessResponse = getProcessResponseFromMap(jsonString);

import 'dart:convert';

class GetProcessResponse {
  GetProcessResponse({
    this.success,
    this.message,
    this.process,
  });

  bool success;
  String message;
  List<Process> process;

  factory GetProcessResponse.fromJson(String str) => GetProcessResponse.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory GetProcessResponse.fromMap(Map<String, dynamic> json) => GetProcessResponse(
        success: json["success"] == null ? null : json["success"],
        message: json["message"] == null ? null : json["message"],
        process: json["process"] == null ? null : List<Process>.from(json["process"].map((x) => Process.fromMap(x))),
      );

  Map<String, dynamic> toMap() => {
        "success": success == null ? null : success,
        "message": message == null ? null : message,
        "process": process == null ? null : List<dynamic>.from(process.map((x) => x.toMap())),
      };
}

class Process {
  Process({
    this.id,
    this.name,
    this.url,
  });

  String id;
  String name;
  String url;

  factory Process.fromJson(String str) => Process.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Process.fromMap(Map<String, dynamic> json) => Process(
        id: json["id"] == null ? null : json["id"],
        name: json["name"] == null ? null : json["name"],
        url: json["url"] == null ? null : json["url"],
      );

  Map<String, dynamic> toMap() => {
        "id": id == null ? null : id,
        "name": name == null ? null : name,
        "url": url == null ? null : url,
      };
}
