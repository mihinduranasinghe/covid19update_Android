import 'corona_case_total_count.dart';
import 'package:json_annotation/json_annotation.dart';
part 'corona_case.g.dart';

@JsonSerializable()
class CoronaCase {
  @JsonKey(name: "OBJECTID")
  final int id;

  @JsonKey(name: "Province_State", defaultValue: '')
  final String state;

  @JsonKey(name: "Country_region", defaultValue: '')
  final String country;

  @JsonKey(name: "Confirmed")
  final int confirmed;

  @JsonKey(name: "Deaths")
  final int deaths;

  @JsonKey(name: "Recovered")
  final int recovered;

  CoronaCase({
    this.id,
    this.state,
    this.country,
    this.confirmed,
    this.deaths,
    this.recovered,
  });

  CoronaTotalCount get totalCount {
    return CoronaTotalCount(
        confirmed: confirmed, deaths: deaths, recovered: recovered);
  }

  factory CoronaCase.fromJson(Map<String, dynamic> json) =>
      _$CoronaCaseFromJson(json);
  Map<String, dynamic> toJSON() => _$CoronaCaseToJson(this);
}
