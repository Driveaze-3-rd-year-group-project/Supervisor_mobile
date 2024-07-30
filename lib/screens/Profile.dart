import 'package:Samarasinghe/screens/ChangePassword.dart';
import 'package:Samarasinghe/screens/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

import 'EditProfile.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                height: MediaQuery.of(context).size.height * 0.23,
                color: Color(0xFF01103B),
              ),
              Expanded(
                child: Container(
                  // color: Colors.white,
                ),
              ),
            ],
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // SizedBox(height: 40),
                  Text(
                    'Profile',
                    style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    // fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                  ProfileCard(),
                  SizedBox(height: 20),

                  Card(
                    color: Colors.grey[50],
                    // color: Colors.white,
                    margin: EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        ListTile(
                          leading: Icon(MaterialCommunityIcons.shield_account_outline),
                          title: Text('Change Password'),
                          trailing: Icon(Icons.chevron_right),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => ChangePasswordScreen()),
                            );
                          },
                        ),
                        ListTile(
                          leading: Icon(Octicons.info),
                          title: Text('About Us'),
                          trailing: Icon(Icons.chevron_right),
                          onTap: () {
                            // Open language settings
                          },
                        ),
                        ListTile(
                          leading: Icon(Icons.security),
                          title: Text('Privacy Policy'),
                          trailing: Icon(Icons.chevron_right),
                          onTap: () {
                            // Open privacy policy
                          },
                        ),
                        ListTile(
                          leading: Icon(Icons.exit_to_app),
                          title: Text('Logout'),
                          trailing: Icon(Icons.chevron_right),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => Login()),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      color: Colors.grey[50],
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: AssetImage('assets/user.png'),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bellamy Blake',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 2),
                      ElevatedButton.icon(
                        icon: Icon(
                          Icons.edit,
                          size: 18,
                          color: Color(0xFF01103B),
                        ),
                        label: Text(
                          'Edit',
                          style: TextStyle(color: Color(0xFF01103B)),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => EditProfilePage()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xB4BCC3FF), // Use primary instead of backgroundColor
                          textStyle: TextStyle(fontSize: 16),
                          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                          minimumSize: Size(30,20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),

                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.email, color: Color(0xFF3F51B5)),
              title: Text('Email'),
              subtitle: Text('blakeb@gmail.com'),
            ),
            ListTile(
              leading: Icon(Icons.phone, color: Color(0xFF3F51B5)),
              title: Text('Phone'),
              subtitle: Text('+94703452332'),
            ),
          ],
        ),
      ),
    );
  }
}