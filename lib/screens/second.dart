import 'package:flutter/material.dart';
import 'home.dart';

class Second extends StatelessWidget {
  final String text;

  Second({required this.text});
  // String text;
  // Second(String text){
  //   this.text = text;
  // }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Second Screen"),
        leading: IconButton(
          icon: Icon(Icons.home),
          onPressed: () {
            Navigator.pop(context, MyHomePage());
          },
        ),
        elevation: 200.0,
        backgroundColor: Colors.blue[300],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
                text,
              style: TextStyle(fontSize: 20.0),
            )
          ],
        ),
      ),
    );
  }
}
