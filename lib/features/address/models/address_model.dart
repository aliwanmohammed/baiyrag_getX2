import '../../../core/utils/json_parser.dart';

class AddressModel {
  final String id;
  final String title;
  final String address;
  final bool isDefault;
  final double? latitude;
  final double? longitude;

  const AddressModel({
    required this.id,
    required this.title,
    required this.address,
    this.latitude,
    this.longitude,
    this.isDefault = false,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: JsonParser.string(json['id']),
      title: JsonParser.string(json['title']),
      address: JsonParser.string(json['address']),
      isDefault: JsonParser.boolValue(json['is_default'], fallback: false),
      latitude: json['latitude'] == null
          ? null
          : JsonParser.doubleValue(json['latitude']),
      longitude: json['longitude'] == null
          ? null
          : JsonParser.doubleValue(json['longitude']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "title": title,
      "address": address,
      "latitude": latitude,
      "longitude": longitude,
      "is_default": isDefault,
    };
  }
}
