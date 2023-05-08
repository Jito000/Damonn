import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../custom_asset/custom_circular_progress.dart';
import '../../custom_asset/custom_color.dart';
import '../../custom_asset/detail.dart';
import '../../custom_asset/show_dialog_error_unPage.dart';
import '../proses_simpan.dart';
import 'pending_delete.dart';

class PendingPage extends StatefulWidget {
  final String idAccount;
  const PendingPage({Key? key, required this.idAccount}) : super(key: key);

  @override
  _PendingPageState createState() => _PendingPageState();
}

class _PendingPageState extends State<PendingPage> {

  //shared preference
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  late Future<String> _check;
  //INIT firebase
  final _ref = FirebaseDatabase.instance.ref();

  //global variable

  late String _mode = 'show';
  final List<String> _titleKey=['tesa', 'celana','ami', 'jumbo', 'tanggung'];
  late String _selectedKeyIndex = '';
  //show mode variable

  //init controller
  late ScrollController listController;
  List<int> items = List.generate(10, (index) => index);

  //edit mode variable

  late bool _isButtonEnable   = true;
  final int _jumlahController = 5;
  final List<TextEditingController> _controllerAll = [];
  //card title
  final List<String> _title   =['Tesa', 'Celana','Ami', 'Jumbo', 'Tanggung / ¾'];
  final _formKey        = GlobalKey<FormState>();

  void isButtonEnable(bool value){
    setState(() {
      _isButtonEnable = value;
    });
  }

  String convertTitle(String date) {
    final DateFormat inputFormat = DateFormat('d MMMM y HH:mm:ss','id');
    final DateFormat displayFormat = DateFormat('d MMMM y','id');
    final DateTime displayDate = inputFormat.parse(date);
    final String formatted = displayFormat.format(displayDate);
    return formatted;
  }
  String convertTime(String date) {
    final DateFormat inputFormat = DateFormat('d MMMM y HH:mm:ss','id');
    final DateFormat displayFormat = DateFormat('Hm');
    final DateTime displayDate = inputFormat.parse(date);
    final String formatted = displayFormat.format(displayDate);
    return formatted;
  }
  String filterKategori(String kategori){
    //potong kain - jahit - obras - pasang kolor - setrika
    if(kategori == 'Potong Kain'){
      return '';
    }
    else if(kategori == 'Jahit'){

      return 'Potong Kain';
    }
    else if(kategori == 'Obras'){
      return 'Jahit';
    }
    else if(kategori == 'Pasang Kolor'){
      return 'Obras';
    }
    else if(kategori == 'Setrika'){
      return 'Pasang Kolor';
    }
    else{
      return '';
    }
    // print(status);
    // return status;
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
  void changeMode(String mode) {
    //ketika void dipanggil mengganti mode
    setState(() {
      _mode = mode;
    });
  }

  @override
  Widget build(BuildContext context) {
    switch(_mode){
      case 'show':
        return Scaffold(
        //future builder to get shared preference : nohp
        body: showMode()
      );
      case 'edit':
        return Scaffold(
          body: editMode(),
          floatingActionButtonLocation:
          FloatingActionButtonLocation.centerFloat,
          floatingActionButton: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Padding(
                  //   padding: const EdgeInsets.only(bottom: 12),
                  //   child: FloatingActionButton(
                  //     heroTag: 'deleteButton',
                  //     elevation: 3,
                  //       foregroundColor: Color(customColorRed()),
                  //       backgroundColor: Color(customColorLayoutBackground()),
                  //       child: const Icon(Icons.delete),
                  //       onPressed: (){
                  //         Navigator.of(context).push(
                  //             PageRouteBuilder(
                  //               opaque: false, // set
                  //               barrierDismissible: true,
                  //               barrierColor: Colors.black.withOpacity(0.5),
                  //               pageBuilder: (_, __, ___) => PendingDelete(
                  //                 //send data to process upload
                  //                 id: _selectedKeyIndex,
                  //                 idAccount: widget.idAccount,
                  //               ),
                  //             )
                  //         ).then((value){
                  //           if(value != null){
                  //             changeMode(value);
                  //           }
                  //         });
                  //       }
                  //   ),
                  // ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      FloatingActionButton(
                        heroTag: 'cancelButton',
                        elevation: 3,
                        foregroundColor: Color(customColorRed()),
                        backgroundColor: Color(customColorLayoutBackground()),
                        child: const Icon(
                          Icons.close,
                          size: 24,
                        ),
                        onPressed: () {
                          changeMode('show');
                        },
                      ),

                      FutureBuilder(
                          future: _check,
                          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                            return FloatingActionButton(
                              heroTag: 'submitButton',
                              elevation: 3,
                              backgroundColor: Color(customColorGreen()),
                              child: const Icon(
                                Icons.check,
                              ),
                              onPressed:(_isButtonEnable==false) ? (){} : () async {

                                // if the controller text value is ''(empty) replace to 0
                                if (  _formKey.currentState!.validate()) {
                                  int countEmptyController = 0;
                                  bool notAllzero = false;
                                  for (var element in _controllerAll) {
                                    if(element.text=='0' ||element.text==''){
                                      element.text='0';
                                      //increase count to detect empty
                                      setState(() {
                                        countEmptyController+=1;
                                      });
                                    }
                                    else{
                                      setState(() {
                                        notAllzero = true;
                                      });
                                    }
                                  }
                                  if(countEmptyController == 5 && notAllzero==false){
                                    customAlertDialogUnpage(context, 'minimal masukkan satu jenis data');
                                  }
                                  else{
                                    //uploadData(context,snapshot.data);
                                    Navigator.of(context).push(
                                      PageRouteBuilder(
                                        opaque: false, // set to false
                                        barrierDismissible: true,
                                        barrierColor: Colors.black.withOpacity(0.5),
                                        pageBuilder: (_, __, ___) => ProsesSimpan(
                                          //send data to process upload
                                          titleKey        : _titleKey,
                                          idAccount       : widget.idAccount,
                                          controller      : _controllerAll,
                                          tanggal         : _selectedKeyIndex,),
                                      ),
                                    ).then((value){
                                      //when back tapped return value to change mode
                                      if(value!=null){
                                        changeMode(value);
                                      }
                                    });
                                  }
                                }
                              },
                            );
                          }
                      ),
                    ],
                  ),
                ],
              )),
        );
      default:
      return SizedBox(
          height: MediaQuery.of(context).size.height/2,
          width: MediaQuery.of(context).size.width/2,
          child: const Center(child: CustomCircularProgressIndicator()));
    }

  }

  //show layout

  Widget showMode(){
    // print(_check);
    return StreamBuilder(
        stream: _ref.child('users/${widget.idAccount}').onValue,
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshotKategori) {

          if(snapshotKategori.hasData){
            //potong kain - jahit - obras - pasang kolor - setrika
            String kategori = snapshotKategori.data.snapshot.value['kategori'];
            return StreamBuilder(
              //get nohp value from sharedpreferene
              stream: _ref.child('data/admin/riwayat').orderByChild('status').equalTo(filterKategori(kategori)).onValue,
              builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {

                if(snapshot.connectionState==ConnectionState.waiting){
                  return const CustomCircularProgressIndicator();
                }
                else if (snapshot.data.snapshot.value != null) {
                  return ListView.builder(
                    //controller: listController,
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

                        return itemShow(index, sortedEntries);

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

  Widget itemShow(int  index, List<MapEntry<dynamic, dynamic>> data){
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
            onLongPressStart: (_){
              //add more duration while longpress
              Timer(const Duration(milliseconds: 250), (){
                Navigator.of(context).push(
                    PageRouteBuilder(
                      opaque: false, // set
                      barrierDismissible: true,
                      barrierColor: Colors.black.withOpacity(0.5),
                      pageBuilder: (_, __, ___) => PendingDelete(
                        //send data to process upload
                        id: data.elementAt(index).key, idAccount: widget.idAccount,
                       ),
                    )
                );
              });

            },
            child: Card(
              color: Color(customColorLayoutBackground()),
              margin: const EdgeInsets.symmetric(vertical: 6,horizontal: 12),
              elevation: 0.2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          //call function to delete hour on date and return the value
                          convertTitle(data.elementAt(index).key.toString()),
                          style: TextStyle(fontSize: 16,color: Color(customColorBlack())),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(3.0),
                          child: Text(
                            //show the current hour
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

                    TextButton(
                      child: Text('Edit',style: TextStyle(color: Color(customColorBlue())),),
                      onPressed: (){
                        //set selected index when edit cliked
                        setState(() {
                          _selectedKeyIndex = data.elementAt(index).key;
                        });
                        for (int i=0;i<5;i++) {
                          _controllerAll[i].text = data.elementAt(index).value[_titleKey[i]];
                        }
                        changeMode('edit');
                      },
                    )
                  ],
                ),
              ),
            ),
          ),
          //add empty widget in the last index
          (index==data.length-1)? const SizedBox(width: 0,height: 24,) : const SizedBox(height: 0,width: 0,)
        ]);
  }

  // edit layout

  Widget editMode(){
    return Form(
        key: _formKey,
        child: ListView.builder(
          itemCount: _jumlahController,
          itemBuilder: (BuildContext context,int index){

            return Padding(
                padding: EdgeInsets.fromLTRB(24, 12, MediaQuery.of(context).size.width/4.toDouble(), 6),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // title of the card
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 0, 3),
                        child: Text(_title[index],style: TextStyle(color: Color(customColorPrimaryFont()),fontSize: 16),),
                      ),
                      // the card
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 3), // jarak antar field
                        decoration: BoxDecoration(
                            color: Color(customColorLayoutBackground()),
                            borderRadius: const BorderRadius.all(Radius.circular(20))
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
                          //input field
                          child: TextFormField(
                            controller: _controllerAll[index],
                            keyboardType: TextInputType.number,
                            cursorColor: Color(customColorGreen()),
                            decoration:  const InputDecoration(
                              border: InputBorder.none,
                              hintText: '0',
                              hintStyle: TextStyle(fontSize: 14),
                            ),

                          ),
                        ),
                      ),
                      //add empty widget in the last index
                      (index==_jumlahController-1)? const SizedBox(width: 0,height: 72,) : const SizedBox(height: 0,width: 0,)
                    ])
            );
          },
        )
    );
  }
}
