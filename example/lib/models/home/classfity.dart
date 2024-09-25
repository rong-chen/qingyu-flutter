import 'dart:ffi';

import 'package:example/store/user.dart';

class Classify {
  final int id;
  final String createdAt;
  final String updatedAt;
  final String? deletedAt;
  final String cId;
  final String label;
   List<Map<String,dynamic>> children = [];

  Classify({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.cId,
    required this.label,
  });

  factory Classify.fromJson(Map<String, dynamic> json) {
    return Classify(
        id: json['ID'],
        createdAt: json['CreatedAt'],
        updatedAt: json['UpdatedAt'],
        deletedAt: json['DeletedAt'],
        cId: json['cId'],
        label: json['label'],
       );
  }
}
