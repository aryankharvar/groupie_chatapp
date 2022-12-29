import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:groupie_chatapp/pages/auth/login_page.dart';
import 'package:groupie_chatapp/pages/home_page.dart';
import 'package:groupie_chatapp/utils/AppPref.dart';
import 'package:groupie_chatapp/utils/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: FirebaseOptions(
          apiKey: Constants.apiKey,
          appId: Constants.appId,
          messagingSenderId: Constants.messagingSenderId,
          projectId: Constants.projectId,
          storageBucket: "groupie-chat-app.appspot.com",
      )
  );
  await AppPref.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    bool isUserLogin=AppPref.getIsUserLogin()??false;
    Map<int, Color> color = {
      50: const Color.fromRGBO(255, 92, 87, .1),
      100: const Color.fromRGBO(255, 92, 87, .2),
      200: const Color.fromRGBO(255, 92, 87, .3),
      300: const Color.fromRGBO(255, 92, 87, .4),
      400: const Color.fromRGBO(255, 92, 87, .5),
      500: const Color.fromRGBO(255, 92, 87, .6),
      600: const Color.fromRGBO(255, 92, 87, .7),
      700: const Color.fromRGBO(255, 92, 87, .8),
      800: const Color.fromRGBO(255, 92, 87, .9),
      900: const Color.fromRGBO(255, 92, 87, 1),
    };

    return MaterialApp(
      title: 'Groupie chat app',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch:MaterialColor(Constants.primaryColour.value,color),
        backgroundColor: Colors.white,
        scaffoldBackgroundColor: Colors.white
      ),
      home: isUserLogin?const HomePage(): LoginPage(),
    );
  }
}

