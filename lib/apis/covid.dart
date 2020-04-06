import 'dart:async';
import 'dart:convert';
import 'package:covid19/modules/corona_case.dart';
import 'package:covid19/modules/corona_case_country.dart';
import 'package:covid19/modules/corona_case_response.dart';
import 'package:covid19/modules/corona_case_total_count.dart';
import 'package:covid19/modules/corona_cases_total_count_response.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';

class TimeoutException implements Exception {
  final String message = 'Server TimeOut';
  TimeoutException();
  String toString() => message;
}

class ServerException implements Exception {
  final String message = "Server Busy";
  ServerException();
  String toString() => message;
}

class ServerErrorException implements Exception {
  String message;
  ServerErrorException(this.message);
  String toString() => message;
}

const KTimeoutDuration = Duration(seconds: 25);

class coronaService {
  coronaService._privateConstructor();
  static final coronaService instance = coronaService._privateConstructor();

  static var baseURL =
      "https://services1.arcgis.com/0MSEUqKaxRlEPj5g/arcgis/rest/services/ncov_cases/FeatureServer/1/query";
  static String get caseUrl {
    return '$baseURL?f=json&where=(Confirmed%3E%200)%20OR%20(Deaths%3E0)%20OR%20(Recovered%3E0)&returnGeometry=false&spatialRef=ersiSpatialRelIntersects&outFields=*&orderByFields=Country_Region%20asc,Province_State%20asc&resultoffset=0&resultRecordCount=250&cacheHint=false';
  }

  static String get totalConfirmedURL {
    return '$baseURL?f=json&where=Confirmed%20%3E%200&returnGeometry=false&spatialRel=esriSpatialRelIntersects&outFields=*&outStatistics=%5B%7B%22statisticType%22%3A%22sum%22,%22onStatisticField%22%3A%22Confirmed%22,%22outStatisticFieldName%22%3A%22value%22%7D%5D&cacheHint=false';
  }

  static String get totalRecoveredURL {
    return '$baseURL?f=json&where=Confirmed%20%3E%200&returnGeometry=false&spatialRel=esriSpatialRelIntersects&outFields=*&outStatistics=%5B%7B%22statisticType%22%3A%22sum%22,%22onStatisticField%22%3A%22Recovered%22,%22outStatisticFieldName%22%3A%22value%22%7D%5D&cacheHint=false';
  }

  static String get totalDeathCaseURL {
    return '$baseURL?f=json&where=Confirmed%20%3E%200&returnGeometry=false&spatialRel=esriSpatialRelIntersects&outFields=*&outStatistics=%5B%7B%22statisticType%22%3A%22sum%22,%22onStatisticField%22%3A%22Deaths%22,%22outStatisticFieldName%22%3A%22value%22%7D%5D&cacheHint=false';
  }

  Future<CoronaTotalCount> fetchAllTotalCount() async {
    try {
      final confirmedJson = await _fetchJSON(totalConfirmedURL);
      final deathsJson = await _fetchJSON(totalDeathCaseURL);
      final recoveredJson = await _fetchJSON(totalRecoveredURL);

      final confirmed = CoronaCaseTotalCountResponse.fromJson(confirmedJson)
          .features
          .first
          .attributes
          .value;
      final deaths = CoronaCaseTotalCountResponse.fromJson(deathsJson)
          .features
          .first
          .attributes
          .value;

      final recovered = CoronaCaseTotalCountResponse.fromJson(recoveredJson)
          .features
          .first
          .attributes
          .value;

      if (confirmed == null || deaths == null || recovered == null) {
        throw ServerException();
      }

      return CoronaTotalCount(
          confirmed: confirmed, deaths: deaths, recovered: recovered);
    } on PlatformException catch (_) {
      throw ServerException();
    } on Exception catch (e) {
      throw (e);
    } catch (e) {
      throw e;
    }
  }

  Future<List<CoronaCaseCountry>> fetchCases() async {
    try {
      final url = caseUrl;
      final json = await _fetchJSON(url);
      final response = CoronaCaseResponse.fromJson(json);
      final coronaCases = response.features.map((e) => e.attributes).toList();

      Map<String, List<CoronaCase>> dict = Map();
      coronaCases.forEach((element) {
        if (dict[element.country] != null) {
          var countryCases = dict[element.country];
          countryCases.add(element);
          dict[element.country] = countryCases;
        } else {
          var countryCases = List<CoronaCase>();
          countryCases.add(element);
          dict[element.country] = countryCases;
        }
      });

      var coronaCountryCases = List<CoronaCaseCountry>();
      dict.forEach((key, value) {
        final confirmed = value.fold(
            0, (previousValue, element) => previousValue + element.confirmed);
        final deaths = value.fold(
            0, (previousValue, element) => previousValue + element.deaths);
        final recovered = value.fold(
            0, (previousValue, element) => previousValue + element.recovered);

        coronaCountryCases.add(CoronaCaseCountry(
          country: key,
          totalConfirmedCount: confirmed,
          totalDeathsCount: deaths,
          totalRecoveredCount: recovered,
        ));
      });

      coronaCountryCases
          .sort((a, b) => b.totalConfirmedCount - a.totalConfirmedCount);
      coronaCountryCases
          .sort((a, b) => b.totalDeathsCount - a.totalDeathsCount);
      coronaCountryCases
          .sort((a, b) => b.totalRecoveredCount - a.totalRecoveredCount);
      return coronaCountryCases;
    } on PlatformException catch (_) {
      throw ServerException();
    } on Exception catch (e) {
      throw (e);
    } catch (e) {
      throw e;
    }
  }

  Future<dynamic> _fetchJSON(String url) async {
    final response =
        await http.get(url).timeout(Duration(seconds: 25), onTimeout: () {
      throw Error();
    });

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw ServerErrorException("Error Retrievig Data...");
    }
  }
}
