import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../custom_asset/custom_circular_progress.dart';
import '../custom_asset/custom_color.dart';
import '../custom_asset/detail.dart';

class AcceptPage extends StatefulWidget {
  final String idAccount;
  const AcceptPage({Key? key, required this.idAccount}) : super(key: key);

  @override
  _AcceptPageState createState() => _AcceptPageState();
}

class _AcceptPageState extends State<AcceptPage> {

  //shared preference
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  late Future<String> _check;
  //INIT firebase
  final _ref = FirebaseDatabase.instance.ref();

  //global variable

  final List<String> _titleKey=['tesa', 'celana','ami', 'jumbo', 'tanggung'];
  //show mode variable

  //init controller
  late ScrollController listController;
  List<int> items = List.generate(10, (index) => index);

  //edit mode variable

  final int _jumlahController = 5;
  final List<TextEditingController> _controllerAll = [];
  //card title

  String convertTitle(String date) {
    final DateFormat inputFormat = DateFormat('d MMMM y HH:mm:ss','id');
    final DateFormat displayFormat = DateFormat('d MMMM y','id');
    final DateTime displayDate = inputFormat.parse(date);
    final String formatted = displayFormat.format(displayDate);
    return formatted;
  }
  String convertTime(String date) {
    final DateFormat inputFormat = DateFormat('d MMMM y HH:mm:ss','id');
    final DateFormat displayFormat = DateFormat('Hm','id');
    final DateTime displayDate = inputFormat.parse(date);
    final String formatted = displayFormat.format(displayDate);
    return formatted;
  }
  @override
  void initState() {
    _check = _prefs.then((SharedPreferences prefs) {
      return prefs.getString('nohp') ?? '';
    });
    for (int i = 1; i <= _jumlahController; i++) {
      _controllerAll.add(TextEditingController());
    }
    listController = ScrollController()..addListener(_scrollListener);
    initializeDateFormatting('id');
    super.initState();
  }
  @override
  void dispose() {
    listController.removeListener(_scrollListener);
    // for (int i = 0; i <= _jumlahController-1; i++) {
    //   _controllerAll[i].dispose();
    // }
    super.dispose();
  }
  void _scrollListener() {
    if (listController.position.extentAfter < 500) {
      setState(() {
        items.addAll(List.generate(10, (index) => index));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
      return Scaffold(
        //future builder to get shared preference : nohp
          body: showMode()
      );
  }

  //show layout

  Widget showMode(){
    return FutureBuilder(
        future: _check,
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshotSharedPref) {
          if(snapshotSharedPref.hasData){
            return StreamBuilder(
              //get nohp value from sharedpreferene
              stream: _ref.child('data/client/${widget.idAccount}/riwayat').onValue,
              builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {

                if(snapshot.connectionState==ConnectionState.waiting){
                  return const CustomCircularProgressIndicator();
                }
                else if (snapshot.data.snapshot.value!=null) {
                  return ListView.builder(
                      itemCount: snapshot.data.snapshot.value.length, //get length by key of database
                      padding: const EdgeInsets.only(top: 24),
                      itemBuilder: (BuildContext context, int index) {
                        //convert snapshot to map
                        Map<dynamic, dynamic> map = snapshot.data.snapshot.value;
                        //sort data by date
                        var sortedEntries = map.entries.toList()..sort((e1, e2) {
                          //init date format
                          final DateFormat displayFormat = DateFormat('d MMMM y HH:mm:ss','id');
                          final DateTime sort2=displayFormat.parse(e2.key);
                          final DateTime sort1=displayFormat.parse(e1.key);
                          var diff = sort2.compareTo(sort1);
                          return diff;
                        });

                        return itemShow(index, sortedEntries, snapshotSharedPref.data );

                      });
                }
                else{
                  return Center(
                    child: SizedBox(
                        height: MediaQuery.of(context).size.height/2,
                        width: MediaQuery.of(context).size.width/2,
                        child: Image.asset('assets/images/empty_data.png')
                    ),
                  );
                }
              },

            );
          }
          else{return Center(child: Text('Anda belum Login',style: TextStyle(color: Color(customColorPrimaryFont())),));}
        }
    );
  }

  Widget itemShow(int  index, List<MapEntry<dynamic, dynamic>> data, String nohp){
    //menghitung total
    int total = 0;
    for(int i = 0; i < 5; i++){
      total += int.parse(data.elementAt(index).value[_titleKey[i]]) ;
    }
    return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [

          GestureDetector(
            onTap: (){
              showCustomDetail(context,data.elementAt(index));
            },
            child: Card(
              color: Color(customColorLayoutBackground()),
              margin: const EdgeInsets.symmetric(vertical: 6,horizontal: 12),
              elevation: 0.2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          //call function to delete time on date and return the value
                          convertTitle(data.elementAt(index).key.toString()),
                          style: TextStyle(fontSize: 16,color: Color(customColorBlack())),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(3.0),
                          child: Text(
                            //show the current status
                            'Pada jam ${convertTime(data.elementAt(index).key.toString())}',
                            style: TextStyle(color: Color(customColorAccentFont()),fontSize: 12),),
                        )
                      ],
                    ),
                    SizedBox(
                      width: 48  ,
                      child: AutoSizeText(
                        total.toString(),
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        style: TextStyle(
                            fontSize: 16, color: Color(customColorGreen())),
                      ),
                    ),


                  ],
                ),
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
            ),
          ),
          //add empty widget in the last index
          (index==data.length-1)? const SizedBox(width: 0,height: 24,) : const SizedBox(height: 0,width: 0,)
        ]);
  }

}
