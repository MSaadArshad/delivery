class Postcode {
  int? status;
  Result? result;

  Postcode({this.status, this.result});

  Postcode.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    result =
    json['result'] != null ? Result.fromJson(json['result']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    if (result != null) {
      data['result'] = result!.toJson();
    }
    return data;
  }
}

class Result {
  String? postcode;
  int? quality;
  String? country;
  double? longitude;
  double? latitude;
  String? region;

  Result(
      {this.postcode,
        this.quality,
        this.country,
        this.longitude,
        this.latitude,
        this.region});

  Result.fromJson(Map<String, dynamic> json) {
    postcode = json['postcode'];
    quality = json['quality'];
    country = json['country'];
    longitude = json['longitude'];
    latitude = json['latitude'];
    region = json['region'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['postcode'] = postcode;
    data['quality'] = quality;
    data['country'] = country;
    data['longitude'] = longitude;
    data['latitude'] = latitude;
    data['region'] = region;
    return data;
  }
}

