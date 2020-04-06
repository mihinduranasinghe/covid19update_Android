part of 'corona_case.dart';

CoronaCase _$CoronaCaseFromJson(Map<String, dynamic> json) {
  return CoronaCase(
    id: json['OBJECTID'] as int,
    state: json['Province_State'] as String ?? '',
    country: json['Country_Region'] as String ?? '',
    confirmed: json['Confirmed'] as int,
    recovered: json['Recovered'] as int,
    deaths: json['Deaths'] as int,
  );
}

Map<String, dynamic> _$CoronaCaseToJson(CoronaCase instance) =>
    <String, dynamic>{
      'OBJECTID': instance.id,
      'Province_State': instance.state,
      'Country_Region': instance.country,
      'Confirmed': instance.confirmed,
      'Recovered': instance.recovered,
      'Deaths': instance.deaths,
    };
