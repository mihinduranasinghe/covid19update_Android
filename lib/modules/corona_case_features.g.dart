part of 'corona_case_features.dart';

// import 'package:covid19/modules/corona_case_total_count_attributes.dart';

CoronaCaseFeatures _$CoronaCaseFeaturesFromJson(Map<String, dynamic> json) {
  return CoronaCaseFeatures(
      attributes: json['attributes'] == null
          ? null
          : CoronaCase.fromJson(json['attributes'] as Map<String, dynamic>));
}

Map<String, dynamic> _$CoronaCaseFeaturesToJson(CoronaCaseFeatures instance) =>
    <String, dynamic>{'attributes': instance.attributes};
