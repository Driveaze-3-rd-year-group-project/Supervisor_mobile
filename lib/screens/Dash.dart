import 'dart:async';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class Dashboard extends StatefulWidget {
  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  late PageController _pageController;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _timer = Timer.periodic(Duration(seconds: 3), (Timer timer) {
      int nextPage = _pageController.page!.round() + 1;
      if (nextPage == 3) {
        nextPage = 0;
      }
      _pageController.animateToPage(
        nextPage,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF01103B),
        title: Center(
          child: Image.asset(
            'assets/1.png',
            height: 300,
          ),
        ),
        toolbarHeight: 150.0,
      ),

      body: SingleChildScrollView(

        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: 20),
              SizedBox(height: 10),
              Container(
                height: 150,
                child: PageView(
                  controller: _pageController,
                  children: [
                    _buildAnnouncementCard('System Maintenance Notice', 'Due to scheduled maintenance, our services will be unavailable on 20/08/2024 from 9 AM to 12 PM.'),
                    _buildAnnouncementCard('Announcement 2', 'Details of announcement 2'),
                    _buildAnnouncementCard('Announcement 3', 'Details of announcement 3'),
                  ],
                ),
              ),
              SizedBox(height: 40),
              Container(
                padding: EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Color(0xFF01103B),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Text(
                  'Summary',
                  style: TextStyle(fontSize: 25.0 ,fontWeight: FontWeight.w500,color: Colors.white),
                ),
              ),
              SizedBox(height: 10),
              // Cards in Grid
              GridView.count(
                shrinkWrap: true,
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 3 / 2,
                physics: NeverScrollableScrollPhysics(),
                children: [
                  _buildSummaryCard('Repairing', '7', Color(0xFF01103B)),
                  _buildSummaryCard('Completed', '10', Color(0xFF01103B)),
                  _buildSummaryCard('Inventory item', '100', Color(0xFF01103B)),
                  _buildSummaryCard('Technicians', '30', Color(0xFF01103B)),
                ],
              ),
              SizedBox(height: 40),

              Container(
                padding: EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Color(0xFF01103B),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Text(
                  'Monthly Repairs',
                  style: TextStyle(fontSize: 25.0 ,fontWeight: FontWeight.w500,color: Colors.white),
                ),
              ),
              SizedBox(height: 10),

              _buildPerfexChart(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String title, String count, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
            Text(count, style: TextStyle(fontSize: 32, color: color, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildPerfexChart() {
    List<_ChartData> data = [
      _ChartData('Jan', 10),
      _ChartData('Feb', 28),
      _ChartData('Mar', 27),
      _ChartData('Apr', 39),
      _ChartData('May', 35),
      _ChartData('Jun', 44),

    ];

    return SfCartesianChart(
      primaryXAxis: CategoryAxis(),
      // title: ChartTitle(text: 'Monthly Completed Vehicles'),
      legend: Legend(isVisible: true),
      tooltipBehavior: TooltipBehavior(enable: true),
      series: <CartesianSeries>[
        LineSeries<_ChartData, String>(
          dataSource: data,
          xValueMapper: (_ChartData data, _) => data.month,
          yValueMapper: (_ChartData data, _) => data.completedVehicles,
          name: 'Completed Vehicles',
          // dataLabelSettings: DataLabelSettings(isVisible: true),
        )
      ],
    );
  }

  Widget _buildAnnouncementCard(String title, String details) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              details,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChartData {
  _ChartData(this.month, this.completedVehicles);

  final String month;
  final double completedVehicles;
}
