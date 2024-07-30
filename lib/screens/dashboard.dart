import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {
  final String username;
  final String profileImageUrl;

  DashboardPage({required this.username, required this.profileImageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        backgroundColor: Color(0xFF01103B),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Section
              Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: NetworkImage(profileImageUrl),
                  ),
                  SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hey, $username!',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Welcome back!',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 20),
              // Announcement Panel
              Text(
                'Announcements',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Container(
                height: 150,
                child: PageView(
                  children: [
                    _buildAnnouncementCard('Announcement 1', 'Details of announcement 1'),
                    _buildAnnouncementCard('Announcement 2', 'Details of announcement 2'),
                    _buildAnnouncementCard('Announcement 3', 'Details of announcement 3'),
                  ],
                ),
              ),
              SizedBox(height: 20),
              // Statistics Section
              Text(
                'Statistics',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              _buildStatisticCard('Repairing Cars', '10'),
              _buildStatisticCard('Completed Repairs', '50'),
              SizedBox(height: 20),
              // QR Code Scan Button
              Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Implement QR code scan functionality here
                  },
                  icon: Icon(Icons.qr_code_scanner),
                  label: Text('Scan QR Code'),
                  style: ElevatedButton.styleFrom(
                    // primary: Color(0xFF01103B),
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    textStyle: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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

  Widget _buildStatisticCard(String title, String count) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(
          Icons.directions_car,
          size: 40,
          color: Color(0xFF01103B),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        trailing: Text(
          count,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

