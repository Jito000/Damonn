import 'dart:io';

import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tab_indicator_styler/tab_indicator_styler.dart';

import '../account/akun.dart';
import '../custom_asset/custom_circular_progress.dart';
import '../custom_asset/custom_color.dart';
import 'beranda.dart';
import 'pending/pending.dart';
import 'riwayat.dart';

class ClientMenu extends StatefulWidget {
  const ClientMenu({
    Key? key,
  }) : super(key: key);

  @override
  _ClientMenuState createState() => _ClientMenuState();
}

class _ClientMenuState extends State<ClientMenu> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _localFile = File('/storage/emulated/0/Android/data/com.example.damonn/files/avatar/users/user.jpg');

  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();


  @override
  void initState() {
    //set sum of the tab
    _tabController = TabController(length: 3, vsync: this);
    super.initState();
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: StreamBuilder(
        stream: _localFile.exists().asStream(),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) { 
          return NestedScrollView(
              headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
                return <Widget>[
                  //first appbar, only contain account icon button
                  SliverAppBar(
                    automaticallyImplyLeading: false,
                    backgroundColor: Color(customColorGreen()),
                    leading: IconButton(
                      iconSize: 36,
                      onPressed: () {
                        Navigator.push(context, PageTransition(type: PageTransitionType.leftToRight, child: const AccountPage()));
                      },
                      // print(snapshot)
                      icon: snapshot.data == true ?
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            image: DecorationImage(
                                image: FileImage(_localFile),
                              fit: BoxFit.fitHeight
                            )
                          ),

                        ):
                        Icon(
                          Icons.account_circle,
                          color: Color(customColorLayoutBackground()),
                        )

                      ,
                    ),

                  ),
                  //second appbar. contain title my record and tab menu
                  SliverAppBar(
                    flexibleSpace: Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
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
                    automaticallyImplyLeading: false,
                      elevation: 0,
                      backgroundColor: Color(customColorGreen()),
                      pinned: true, //lock tab position on top while scrolling
                      floating: true,
                      forceElevated: innerBoxIsScrolled,
                      title: Text(
                        'Damonn',
                        style: TextStyle(
                            color: Color(customColorBlack()),
                            fontSize: 24,
                            fontWeight: FontWeight.bold),
                      ),

                      shape: const RoundedRectangleBorder(    // set radius appbar
                        borderRadius: BorderRadius.vertical(
                          bottom: Radius.circular(20),
                        ),
                      ),
                      bottom: PreferredSize(
                          preferredSize: const Size.fromHeight(48.0), //tinggi jarak my record
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: TabBar(
                              isScrollable: true,
                              labelColor: Color(customColorBlue()),
                              unselectedLabelColor: Color(customColorWhite()),
                              indicatorSize: TabBarIndicatorSize.tab,
                              indicator: RectangularIndicator(
                                  color: Color(customColorLayoutBackground()),
                                  //padding
                                  verticalPadding: 6,
                                  horizontalPadding: 6,
                                  // tab Radius
                                  bottomRightRadius: 25,
                                  bottomLeftRadius: 25,
                                  topRightRadius: 25,
                                  topLeftRadius: 25
                              ),
                              controller: _tabController,
                              tabs: const [
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 6.0),
                                  child: Tab(text: 'Beranda'),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 6.0),
                                  child: Tab(text: "Pending"),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 6.0),
                                  child: Tab(text: "Riwayat"),
                                ),
                              ],
                            ),
                          )
                      )

                  )
                ];
              },
              body: FutureBuilder(
                future: _prefs.then((SharedPreferences prefs) { return prefs.getString('idAccount') ?? '';}),
                builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                  if(snapshot.hasData){
                    return TabBarView(
                      controller: _tabController,
                      children: [
                        OverviewPage(idAccount: snapshot.data,),
                        PendingPage(idAccount: snapshot.data,),
                        AcceptPage(idAccount: snapshot.data,),
                      ],
                    );
                  }
                  else{
                    return const CustomCircularProgressIndicator();
                  }

                }
              )
          );
        },) 
      
    );
  }
}
