part of 'corona_case_response.dart';

// import 'package:covid19/modules/corona_case_total_count_attributes.dart';

CoronaCaseResponse _$CoronaCaseResponseFromJson(Map<String, dynamic> json) {
  return CoronaCaseResponse(
    features: (json['features'] as List)
        ?.map((e) => e == null
            ? null
            : CoronaCaseFeatures.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$CoronaCaseResponseToJson(CoronaCaseResponse instance) =>
    <String, dynamic>{'features': instance.features};
