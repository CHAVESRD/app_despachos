// ignore_for_file: file_names

import 'dart:convert';

class BEToken {
  BEToken({required this.token});

  String token;

  factory BEToken.fromJson(String str) => BEToken.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory BEToken.fromMap(Map<String, dynamic> json) => BEToken(
        token: json["token"],
      );

  Map<String, dynamic> toMap() => {
        "token": token,
      };
}
