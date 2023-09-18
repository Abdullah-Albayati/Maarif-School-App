import 'package:flutter/material.dart';
import 'package:maarif_app/pages/home.dart';
import 'package:maarif_app/pages/loading.dart';
import 'package:maarif_app/pages/login.dart';
import 'package:maarif_app/services/AuthenticationProvider.dart';
import 'package:provider/provider.dart';

void main() => runApp(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthenticationProvider())
      ],
      child: MaterialApp(
        initialRoute:
            '/login', // TODO: Later on make it so that if the user is logged in already, save it to shared perfrences and check and make the initial route home.

        routes: {
          '/login': (context) => Login(),
          '/home': (context) => Home(),
          '/loading': (context) => Loading()
        },
      ),
    ));
