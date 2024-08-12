import 'package:flutter_corelib/flutter_corelib.dart';

class VoiceModel {
  final String id;
  final String name;
  final String sample;

  VoiceModel({required this.id, required this.name, required this.sample});

  factory VoiceModel.fromJson(Map<String, dynamic> json) {
    return VoiceModel(
      id: json.getString('id'),
      name: json.getString('name'),
      sample: json.getString('sample'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'sample': sample,
    };
  }
}
