import 'package:json_annotation/json_annotation.dart';
import 'package:covid19/modules/corona_case_total_count_features.dart';
part 'corona_cases_total_count_response.g.dart';

@JsonSerializable()
class CoronaCaseTotalCountResponse {
  final List<CoronaCaseTotalCountFeatures> features;

  CoronaCaseTotalCountResponse({this.features});

  factory CoronaCaseTotalCountResponse.fromJson(Map<String, dynamic> json) =>
      _$CoronaCaseTotalCountResponseFromJson(json);
  Map<String, dynamic> toJSON() => _$CoronaCaseTotalCountResponseToJson(this);

  static fromJSON(confirmedJson) {}
}
