class VoiceModel {
  final String id;
  final String name;
  final String sample;

  VoiceModel({required this.id, required this.name, required this.sample});

  factory VoiceModel.fromJson(Map<String, dynamic> json) {
    return VoiceModel(
      id: json['id'],
      name: json['name'],
      sample: json['sample'],
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
