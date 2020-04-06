import 'package:covid19/utils/util.dart';
import 'package:flutter/material.dart';
import 'package:covid19/apis/covid.dart';
import 'package:covid19/modules/corona_case_total_count.dart';
import 'modules/corona_case_country.dart';
//import 'package:intl/intl.dart';
import 'utils/util.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class StatsPage extends StatefulWidget {
  StatsPage({Key key}) : super(key: key);
  @override
  _StatsPageStats createState() => _StatsPageStats();
}

class _StatsPageStats extends State<StatsPage>
    with AutomaticKeepAliveClientMixin<StatsPage> {
  @override
  bool get wantKeepAlive => true;

  var service = coronaService.instance;
  Future<CoronaTotalCount> _totalCountFuture;
  Future<List<CoronaCaseCountry>> _allCasesFuture;

  @override
  void initState() {
    _fetchData();
    super.initState();
  }

  _fetchData() {
    _totalCountFuture = service.fetchAllTotalCount();
    _allCasesFuture = service.fetchCases();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: Container(
          constraints: BoxConstraints(maxWidth: 768),
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Column(
              children: <Widget>[
                _buildTotalCountWidget(context),
                Padding(
                  padding: EdgeInsets.only(left: 16, right: 16),
                  child: Divider(),
                ),
                _buildAllCasesWidget(context)
              ],
            ),
          )),
    );
  }

  Widget _buildTotalCountWidget(BuildContext context) {
    return FutureBuilder(
      future: _totalCountFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Padding(
            padding: EdgeInsets.only(top: 16, bottom: 16),
            child: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.error != null) {
          return Padding(
            padding: EdgeInsets.only(top: 16, bottom: 16),
            child: Center(
              child: Text("Error fetching total count data..."),
            ),
          );
        } else {
          final CoronaTotalCount totalCount = snapshot.data;

          final data = [
            LinearCases(CaseType.sick.index, totalCount.sick,
                totalCount.sickRate.toInt(), "Sick"),
            LinearCases(CaseType.recovered.index, totalCount.recovered,
                totalCount.recoveryRate.toInt(), "Recovered"),
            LinearCases(CaseType.deaths.index, totalCount.deaths,
                totalCount.fatalityRate.toInt(), "Deaths"),
          ];

          final series = [
            charts.Series<LinearCases, int>(
              id: 'Total Count',
              domainFn: (LinearCases cases, _) => cases.type,
              measureFn: (LinearCases cases, _) => cases.total,
              labelAccessorFn: (LinearCases cases, _) =>
                  '${cases.text}\n${Utils.numberFormatter.format(cases.count)}',
              colorFn: (cases, index) {
                switch (cases.text) {
                  case "Confirmed":
                    return charts.ColorUtil.fromDartColor(Colors.red);
                  case "Sick":
                    return charts.ColorUtil.fromDartColor(Colors.blue);
                  case "Recovered":
                    return charts.ColorUtil.fromDartColor(Colors.green);
                  default:
                    return charts.ColorUtil.fromDartColor(Colors.orangeAccent);
                }
              },
              data: data,
            )
          ];

          return Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                    "Last Updated: ${Utils.dateFormatter.format(DateTime.now())}"),
                Padding(
                  padding: EdgeInsets.only(bottom: 8),
                ),
                Text(
                  "Global Total Cases Stats",
                  style: Theme.of(context).textTheme.headline,
                ),
                Container(
                    height: 200,
                    child: charts.PieChart(
                      series,
                      animate: true,
                      defaultRenderer: charts.ArcRendererConfig(
                          arcWidth: 60,
                          arcRendererDecorators: [charts.ArcLabelDecorator()]),
                    )),
                Padding(
                    //For Confirmed
                    padding: EdgeInsets.only(top: 16, bottom: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              totalCount.confirmedText,
                              style: Theme.of(context)
                                  .textTheme
                                  .headline
                                  .apply(color: Colors.blue),
                            ),
                            Text("Confirmed")
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              totalCount.sickText,
                              style: Theme.of(context)
                                  .textTheme
                                  .headline
                                  .apply(color: Colors.orange),
                            ),
                            Text("Sick"),
                          ],
                        )
                      ],
                    )),
                Padding(
                    //For Recovered
                    padding: EdgeInsets.only(top: 8, bottom: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              totalCount.recoveredText,
                              style: Theme.of(context)
                                  .textTheme
                                  .headline
                                  .apply(color: Colors.green),
                            ),
                            Text("Recovered")
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              totalCount.recoveredRateText,
                              style: Theme.of(context)
                                  .textTheme
                                  .headline
                                  .apply(color: Colors.greenAccent),
                            ),
                            Text("Recovery Rate"),
                          ],
                        )
                      ],
                    )),
                Padding(
                    //For Deaths
                    padding: EdgeInsets.only(top: 8, bottom: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              totalCount.deathsText,
                              style: Theme.of(context)
                                  .textTheme
                                  .headline
                                  .apply(color: Colors.red),
                            ),
                            Text("Deaths")
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              totalCount.facilityRateText,
                              style: Theme.of(context)
                                  .textTheme
                                  .headline
                                  .apply(color: Colors.red),
                            ),
                            Text("Fatality Rate"),
                          ],
                        )
                      ],
                    )),
              ],
            ),
          );
        }
      },
    );
  }

  //All Cases Widget
  Widget _buildAllCasesWidget(BuildContext context) {
    return FutureBuilder(
      future: _allCasesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Padding(
            padding: EdgeInsets.only(top: 16, bottom: 16),
            child: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.error != null) {
          return Padding(
            padding: EdgeInsets.only(top: 16, bottom: 16),
            child: Center(
              child: Text("Error fetching total count data..."),
            ),
          );
        } else {
          if (snapshot.data == null || snapshot.data.length == 0) {
            return Padding(
                padding: EdgeInsets.only(top: 16, bottom: 16),
                child: Center(
                  child: Text("No Data"),
                ));
          }

          final List<CoronaCaseCountry> cases = snapshot.data;
          var children = List<Widget>();

          final indiaCase = cases.firstWhere(
              (element) => element.country.toLowerCase().contains('sri lanka'));

          if (indiaCase != null) {
            final data = [
              OrdinalCases("Confirmed", indiaCase.totalConfirmedCount,
                  indiaCase.coronaTotalCount),
              OrdinalCases("Recovered", indiaCase.totalRecoveredCount,
                  indiaCase.coronaTotalCount),
              OrdinalCases("Deaths", indiaCase.totalDeathsCount,
                  indiaCase.coronaTotalCount),
            ];

            final seriesList = [
              charts.Series<OrdinalCases, String>(
                id: 'India Cases',
                domainFn: (OrdinalCases cases, _) => cases.country,
                measureFn: (OrdinalCases cases, _) => cases.total,
                data: data,
                labelAccessorFn: (OrdinalCases cases, _) {
                  return '${Utils.numberFormatter.format(cases.total)}';
                },
                colorFn: (cases, index) {
                  switch (cases.country) {
                    case "Confirmed":
                      return charts.ColorUtil.fromDartColor(Colors.red);
                    // case "Sick":
                    //   return charts.ColorUtil.fromDartColor(Colors.blue);
                    case "Recovered":
                      return charts.ColorUtil.fromDartColor(Colors.green);
                    default:
                      return charts.ColorUtil.fromDartColor(
                          Colors.orangeAccent);
                  }
                },
              )
            ];

            children.addAll([
              Padding(
                padding: EdgeInsets.only(top: 8),
              ),
              Text("Cases In Sri Lanka",
                  style: Theme.of(context).textTheme.headline),
              Container(
                  height: 120,
                  child: charts.BarChart(
                    seriesList,
                    animate: true,
                    barRendererDecorator:
                        new charts.BarLabelDecorator<String>(),
                    domainAxis: new charts.OrdinalAxisSpec(),
                  )),
              Padding(
                padding: EdgeInsets.only(bottom: 16),
              ),
              Divider(),
            ]);
          }

          cases.removeWhere(
              (element) => element.country.toLowerCase().contains('sri lanka'));

          var confirmCasesData = List<OrdinalCases>();
          var deathsCasesData = List<OrdinalCases>();
          var recoveredCasesData = List<OrdinalCases>();

          cases.forEach((element) {
            final totalCount = element.coronaTotalCount;
            var tailTexts = List<String>();

            if (totalCount.deaths > 0) {
              tailTexts.add("D:${totalCount.deathsText}"); //D represents Deaths

            }
            if (totalCount.recovered > 0) {
              tailTexts.add(
                  "D:${totalCount.recoveredText}"); //R represents Recovereds

            }
            final tailText = tailTexts.join("-");
            var country = element.country;
            if (tailText.isNotEmpty) {
              country += "\n" + tailText;
            }

            confirmCasesData.add(OrdinalCases(
                country, element.totalSickCount, element.coronaTotalCount));

            deathsCasesData.add(OrdinalCases(
                country, element.totalDeathsCount, element.coronaTotalCount));

            recoveredCasesData.add(OrdinalCases(country,
                element.totalRecoveredCount, element.coronaTotalCount));
          });
          final int height =
              cases.fold(0, (previousValue, element) => previousValue + 40);

          var seriesList = [
            charts.Series<OrdinalCases, String>(
              id: 'Deaths',
              domainFn: (OrdinalCases cases, _) => cases.country,
              measureFn: (OrdinalCases cases, _) => cases.total,
              data: deathsCasesData,
              labelAccessorFn: (OrdinalCases cases, _) {
                return null;
              },
              colorFn: (datum, index) =>
                  charts.ColorUtil.fromDartColor(Colors.red),
            ),
            charts.Series<OrdinalCases, String>(
              id: 'Recovered',
              domainFn: (OrdinalCases cases, _) => cases.country,
              measureFn: (OrdinalCases cases, _) => cases.total,
              data: recoveredCasesData,
              labelAccessorFn: (OrdinalCases cases, _) {
                return null;
              },
              colorFn: (datum, index) =>
                  charts.ColorUtil.fromDartColor(Colors.green),
            ),
            charts.Series<OrdinalCases, String>(
              id: 'Sick',
              domainFn: (OrdinalCases cases, _) => cases.country,
              measureFn: (OrdinalCases cases, _) => cases.total,
              data: confirmCasesData,
              colorFn: (datum, index) =>
                  charts.ColorUtil.fromDartColor(Colors.blue),
              labelAccessorFn: (OrdinalCases cases, _) {
                return '${cases.totalCount.confirmedText}';
              },
            ),
          ];

          children.addAll([
            Padding(
              padding: EdgeInsets.only(top: 8),
            ),
            Text("Cases Outside Sri Lanka",
                style: Theme.of(context).textTheme.headline),
            Container(
                height: height.toDouble(),
                child: charts.BarChart(
                  seriesList,
                  animate: true,
                  barGroupingType: charts.BarGroupingType.stacked,
                  vertical: false,
                  barRendererDecorator: charts.BarLabelDecorator<String>(),
                )),
          ]);

          return Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          );
        }
      },
    );
  }
}

enum CaseType { confirmed, deaths, recovered, sick }

class LinearCases {
  final int type;
  final int count;
  final int total;
  final String text;

  LinearCases(this.type, this.count, this.total, this.text);
}

class OrdinalCases {
  final String country;
  final int total;
  final CoronaTotalCount totalCount;

  OrdinalCases(this.country, this.total, this.totalCount);
}
