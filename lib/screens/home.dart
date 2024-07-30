import 'package:flutter/material.dart';
import 'second.dart';

class MyHomePage extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Flutter",
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          leading: IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {},
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {},
            ),
          ],
          // flexibleSpace: Image.asset(
          //   "assets/q.jpg",
          //   fit: BoxFit.cover,),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.directions_car)),
              Tab(icon: Icon(Icons.newspaper)),
              Tab(icon: Icon(Icons.settings)),
            ],
          ),
          elevation: 200.0,
          backgroundColor: Colors.blue[300],
        ),
        body: const TabBarView(
          children: [
            Icon(Icons.directions_car),
            Icon(Icons.newspaper),
            Icon(Icons.settings),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: (){
            Navigator.of(context).push(MaterialPageRoute(
              builder: (_) {
                return Second(text: 'Kalindu');
              }
            ));
            // Navigator.of(context).pushNamed('/second');
          },
          child: Icon(Icons.arrow_forward, color: Colors.white,),
          backgroundColor: Colors.blue[300],
        ),
      ),
    );
  }
}