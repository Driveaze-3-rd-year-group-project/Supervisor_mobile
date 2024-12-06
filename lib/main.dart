import 'package:flutter/material.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'screens/login.dart';
import 'screens/vehicles.dart';
import 'screens/dashboard.dart';


main(){
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  // runApp(
  //   DevicePreview(
  //     enabled: true,
  //     builder: (context) => MyApp(),
  //   ),
  // );
  runApp(MyApp());
}

class MyApp extends StatefulWidget{
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    initialization();
  }

  void initialization() async{
    print("pausing");
    await Future.delayed(const Duration(seconds: 2));
    print("unpausing");
    FlutterNativeSplash.remove();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      home: Login(),
      // home: DashboardPage(username: 'kalindu',
      //   profileImageUrl: 'https://www.google.com/url?sa=i&url=https%3A%2F%2Fwww.imagella.com%2Fproducts%2Fcartoon-dp-for-whatsapp-picture-perfect-profiles-9&psig=AOvVaw3lP-_EtZMtq794b9iKQ77D&ust=1721242854780000&source=images&cd=vfe&opi=89978449&ved=0CBEQjRxqFwoTCMiQ7cKfrIcDFQAAAAAdAAAAABAE',),
      // routes: <String,WidgetBuilder> {
      //   '/second': (context)=>Second(),
      // },
    );
  }
}

