// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'dart:async';

// import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'admin/menu.dart';
import 'client/menu.dart';
import 'custom_asset/custom_circular_progress.dart';
import 'custom_asset/custom_color.dart';
import 'custom_asset/show_dialog_error_unPage.dart';
import 'firebase_options.dart';
import 'login/login.dart';


Future<void> main() async {
  //gatau si yang jelas kalo ada shared preference ini wajib
  WidgetsFlutterBinding.ensureInitialized();
  //inisiasi flutter downloader
  await FlutterDownloader.initialize();
  //inisialisasi firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  //inisialisasi App check firebase
  // await FirebaseAppCheck.instance.activate(
  //   androidProvider: AndroidProvider.debug
  // );
  //disable landscape orientation
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await FirebaseAuth.instance.signInAnonymously();
  //status bar color
  // SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
  //     statusBarColor: Color(customColorGreen())
  // ));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      //disable debug banner
      debugShowCheckedModeBanner: false,
      home: SharedPreferencesDemo(),
    );
  }
}

class SharedPreferencesDemo extends StatefulWidget {
  const SharedPreferencesDemo({Key? key}) : super(key: key);

  @override
  SharedPreferencesDemoState createState() => SharedPreferencesDemoState();
}

class SharedPreferencesDemoState extends State<SharedPreferencesDemo>{

  //deklarasi sharedpreference
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  //deklarasi reatime database
  final _ref = FirebaseDatabase.instance.ref();

  //deklarasi variabel shared preference
  late Future<String> _check;

  Future<void> getId() async {
    final SharedPreferences prefs = await _prefs;


    //get data from shared preference
    final String check = (prefs.getString('nohp')??'');
    // if(snapshot.exists){
      if(check==''){

        Route route = MaterialPageRoute(builder: (context) => const LoginPage());
        Navigator.pushReplacement(context, route);
      }
      else{
        final ref = await _ref.child('users').orderByChild('nohp').equalTo(check).get();
        // print(ref.children.first.key);

        if(ref.children.first.child('kategori').value == 'admin'){
          Route route = MaterialPageRoute(builder: (context) => const AdminMenu());
          Navigator.pushReplacement(context, route);
        }
        else if(ref.children.first.child('kategori').value  == 'Potong Kain'
              || ref.children.first.child('kategori').value == 'Jahit'
              || ref.children.first.child('kategori').value == 'Obras'
              || ref.children.first.child('kategori').value == 'Pasang Kolor'
              || ref.children.first.child('kategori').value == 'Setrika') {
          Route route = MaterialPageRoute(builder: (context) => const ClientMenu());
          Navigator.pushReplacement(context, route);
        }
        else {

          customAlertDialogUnpage(context, 'Akun Tidak Valid!');

        }

      }
   }


  @override
  void initState() {
    super.initState();
    _check = _prefs.then((SharedPreferences prefs) {
      return prefs.getString('nohp') ?? '';
    });
    getId();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
          children:[
            Container(
                height: MediaQuery.of(context).size.height,
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomLeft,
                        colors: <Color>[
                          Color(customColorGreen()),
                          Color(customColorBlue())
                        ]
                    )
                ),
            ),
            Container(
              color: Colors.black.withOpacity(0.5),
            ),
            Center(
              child: Container(
                  width: MediaQuery.of(context).size.width/2,
                  height: MediaQuery.of(context).size.width/2,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Color(customColorWhite()),
                  ),
                  child: const CustomCircularProgressIndicator()

              ),
            )
          ]
        ),
      );
      
  }
}