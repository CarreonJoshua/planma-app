import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:http/http.dart' as http;
import 'package:planma_app/Providers/user_provider.dart';
import 'package:planma_app/reports/reportservice.dart';
import 'package:provider/provider.dart';
import 'package:jwt_decode/jwt_decode.dart';
 
class ReportPage extends StatefulWidget {
  // ignore: prefer_const_constructors_in_immutables
  ReportPage({Key? key}) : super(key: key);
 
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<ReportPage> {
  late List<_ChartData> data;
  late TooltipBehavior _tooltip;
  @override
  void initState() {
    final carreon = Jwt.parseJwt(context.read<UserProvider>().accessToken!)['user_id'];
    final result = ReportAct().fetchActivities(carreon);
    data = [ //X y
      _ChartData('CN', 12),
    ];
    _tooltip = TooltipBehavior(enable: true);
    super.initState();
  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Syncfusion Flutter chart'),
        ),
        body: SfCartesianChart(
            primaryXAxis: CategoryAxis(),
            primaryYAxis: NumericAxis(minimum: 0, maximum: 40, interval: 10),
            tooltipBehavior: _tooltip,
            series: <CartesianSeries<_ChartData, String>>[
              ColumnSeries<_ChartData, String>(
                  dataSource: data,
                  xValueMapper: (_ChartData data, _) => data.x,
                  yValueMapper: (_ChartData data, _) => data.y,
                  name: 'Gold',
                  color: Color.fromRGBO(8, 142, 255, 1))
            ]));
  }
}

 
class _ChartData {
  _ChartData(this.x, this.y);
 
  final String x;
  final double y;
}