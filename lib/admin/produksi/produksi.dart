import 'dart:async';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../custom_asset/custom_circular_progress.dart';
import '../../custom_asset/custom_color.dart';
import '../../custom_asset/show_dialog_error_unPage.dart';
import '../../custom_asset/detail.dart';
import 'proses_hapus.dart';
import 'proses_simpan.dart';

class ProduksiPage extends StatefulWidget {
  const ProduksiPage({Key? key}) : super(key: key);

  @override
  _ProduksiPageState createState() => _ProduksiPageState();
}

class _ProduksiPageState extends State<ProduksiPage> {

  //shared preference
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  late Future<String> _check;
  //INIT firebase
  final _ref = FirebaseDatabase.instance.ref();

  //global variable

  late String _mode = 'show';
  final List<String> _titleKey=['tesa', 'celana','ami', 'jumbo', 'tanggung', 'status'];
  late String _selectedKeyIndex = '';
  late Map isiList = {};
  late List listObj = [];
  //show mode variable

  //init controller
  late ScrollController listController;
  List<int> items = List.generate(10, (index) => index);

  //edit mode variable

  late bool _isButtonEnable   = true;
  final List<TextEditingController> _controllerAll = [];
  //card title
  final List<String> _title   =['Tesa', 'Celana','Ami', 'Jumbo', 'Tanggung / ¾', 'Status'];
  final _formKey        = GlobalKey<FormState>();
  //filter
  final List<String> _status = ['Potong Kain', 'Jahit', 'Obras', 'Pasang Kolor'];
  late List<bool> _isActiveFilter = [];

  void isButtonEnable(bool value){
    setState(() {
      _isButtonEnable = value;
    });
  }
void changeActiveFilter(int index){
    // if(_isActiveFilter[index]){
      setState(() {
        _isActiveFilter[index] == true
            ? _isActiveFilter[index] = false
            : _isActiveFilter[index] = true;
      });
    // }
}
void resetSelectedItem(){
  setState(() {
    _selectedKeyIndex = '';
  });
}
String convertTanggal(String date) {
    final DateFormat inputFormat = DateFormat('d MMMM y HH:mm:ss','id');
    final DateFormat displayFormat = DateFormat('d MMMM y','id');
    final DateTime displayDate = inputFormat.parse(date);
    final String formatted = displayFormat.format(displayDate);
    return formatted;
  }
  @override
  void initState() {
    _check = _prefs.then((SharedPreferences prefs) {
      return prefs.getString('nohp') ?? '';
    });
    // init controller
    for (int i = 1; i <= _titleKey.length; i++) {
      _controllerAll.add(TextEditingController());
    }
    //init filter
    for (int i = 1; i <= _status.length; i++) {
      _isActiveFilter.add(false);
    }
    //data awal
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
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          floatingActionButton: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
            // print(snapshotKategori.data.value);
              FloatingActionButton(
                elevation: 3,
                child: const Icon(Icons.add_outlined),
                backgroundColor: Color(customColorGreen()),
                onPressed:  () {
                  setState(() {
                    for (int i = 0; i < _titleKey.length; i++) {
                      _controllerAll[i].text = '';
                    }
                    _selectedKeyIndex ='';
                  });
                  changeMode('edit'); //pindah halaman input
                },

              ),
            ],
          ),
          //future builder to get shared preference : nohp
            body: showMode(),
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(12),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 4,
              itemBuilder:(BuildContext context, int index){

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2,vertical: 6),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(50),
                    onTap: (){
                      //filter aktif
                      changeActiveFilter(index);
                      //
                      // getData(false);

                      // print(_isActiveFilter);
                    },
                    child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                          color: Color(
                              _isActiveFilter[index] == true
                                  ? customColorBlue()
                                  : customColorWhite()
                          ),
                          border: Border.all(color: Color(customColorBlue())),
                        borderRadius: BorderRadius.circular(50)
                      ),
                        child: Text(_status[index],
                          style: TextStyle(
                              color: Color( _isActiveFilter[index] == false
                                  ? customColorBlue()
                                  : customColorWhiteFF())
                          )
                        )
                    ),
                  ),
                );
              }
            )
          ),
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
                  _selectedKeyIndex !='' ? Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: FloatingActionButton(
                        heroTag: 'deleteButton',
                        elevation: 3,
                        foregroundColor: Color(customColorRed()),
                        backgroundColor: Color(customColorLayoutBackground()),
                        child: const Icon(Icons.delete),
                        onPressed: (){
                          Navigator.of(context).push(
                              PageRouteBuilder(
                                opaque: false, // set
                                barrierDismissible: true,
                                barrierColor: Colors.black.withOpacity(0.5),
                                pageBuilder: (_, __, ___) => ProsesHapus(
                                  //send data to process upload
                                  id: _selectedKeyIndex,
                                ),
                              )
                          ).then((value){
                            if(value != null){
                              changeMode(value);
                              resetSelectedItem();
                            }
                          });

                        }
                    ),
                  )
                  : Container(),
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
                          resetSelectedItem();
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
                                // print(_selectedKeyIndex);
                                // if the controller text value is ''(empty) replace to 0
                                if (  _formKey.currentState!.validate()) {
                                  int countEmptyController = 0;
                                  bool notAllzero = false;
                                  for (var element in (_controllerAll)) {
                                    if(element.text=='0' ||element.text==''){
                                      element.text='0';
                                      //increase count to detect empty
                                      setState(() {
                                        countEmptyController += 1;
                                      });
                                    }
                                    else{
                                      setState(() {
                                        notAllzero = true;
                                      });
                                    }
                                  }
                                  if(countEmptyController < _titleKey.length && notAllzero== false){
                                    customAlertDialogUnpage(context, 'minimal masukkan satu jenis data');
                                  }
                                  else{
                                    final now = DateTime.now();
                                    //mengambil waktu sekarang hingga detik
                                    String tanggal = DateFormat('d MMMM y HH:mm:ss','id').format(now);
                                    Navigator.of(context).push(
                                      PageRouteBuilder(
                                        opaque: false, // set to false
                                        barrierDismissible: true,
                                        barrierColor: Colors.black.withOpacity(0.5),
                                        pageBuilder: (_, __, ___) => ProsesSimpan(
                                          //send data to process upload
                                          titleKey        : _titleKey,
                                          controller      : _controllerAll,
                                          tanggal         : _selectedKeyIndex == ''? tanggal : _selectedKeyIndex,
                                        ),
                                      ),
                                    ).then((value){
                                      //when back tapped return value to change mode
                                      if(value!=null){
                                        changeMode(value);
                                      }
                                      resetSelectedItem();
                                    });
                                    // mereset item yang dipilih

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
    return StreamBuilder(
      stream: _ref.child('data/admin/riwayat').onValue,
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {


        if(snapshot.connectionState == ConnectionState.waiting){
          // downloadDataUnfilter();
          // print(_dataUnFiltered);
          return const CustomCircularProgressIndicator();

        }
        else if(snapshot.data.snapshot.value != null){
          // menghapus data yang statusnya telah disetrika
          snapshot.data.snapshot.value.removeWhere((key, value) {return value['status'] == 'Setrika';});
          bool isFiltered = false;
          Map filter = {};
          filter.addAll(snapshot.data.snapshot.value);

          for(int i = 0; i < _status.length; i++){
            if(_isActiveFilter[i] == false){
              //     // print(_isActiveFilter);
              filter.removeWhere((key, value) => value['status'] == _status[i]);
              //     // counter++;
            }
            else{
              isFiltered = true;
            }
          }
          if(!isFiltered){
            return ListView.builder(
              //controller: listController,
                itemCount: snapshot.data.snapshot.value.length, //get length by key of database
                // padding: const EdgeInsets.only(top: 12),
                itemBuilder: (BuildContext context, int index) {
                  return itemShow(index, snapshot.data.snapshot.value);
                });
          }
          else if(isFiltered && filter.isNotEmpty){
            return ListView.builder(
              //controller: listController,
                itemCount: filter.length, //get length by key of database
                // padding: const EdgeInsets.only(top: 12),
                itemBuilder: (BuildContext context, int index) {
                  return itemShow(index, filter);
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

        });

  }

  Widget itemShow(int  index, Map data){
    //menghitung total
    int total = 0;
    for(int i = 0; i < 5; i++){
      total += int.parse(data.entries.elementAt(index).value[_titleKey[i]]) ;
    }
    return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [

          GestureDetector(
            onTap: (){
              //melihat detail
              showCustomDetail(context,data.entries.elementAt(index));
            },
            onLongPressStart: (_){
              Navigator.of(context).push(
                  PageRouteBuilder(
                    opaque: false, // set
                    barrierDismissible: true,
                    barrierColor: Colors.black.withOpacity(0.5),
                    pageBuilder: (_, __, ___) => ProsesHapus(
                      //send data to process upload
                      id: data.entries.elementAt(index).key,
                    ),
                  )
              ).then((value){
                if(value != null){
                  changeMode(value);
                }
              });

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
                          //call function to delete hour on date and return the value
                          convertTanggal(data.entries.elementAt(index).key.toString()),
                          style: TextStyle(fontSize: 16,color: Color(customColorBlack())),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(3.0),
                          child: Text(
                            //show the current hour
                            // 'Pada jam ${convertTime(data.entries.elementAt(index).key.toString())}',
                            data.entries.elementAt(index).value['status'],
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
                          _selectedKeyIndex = data.entries.elementAt(index).key;
                        });
                        //memperbarui value edit
                        for (int i = 0; i < _titleKey.length; i++) {
                          _controllerAll[i].text = data.entries.elementAt(index).value[_titleKey[i]];
                        }
                        changeMode('edit');
                      },
                    )
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

  // edit layout

  Widget editMode(){
    return Form(
        key: _formKey,
        child: ListView.builder(
          itemCount: _titleKey.length,
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
                          child: index <= 4 ? TextFormField(
                            controller: _controllerAll[index],
                            keyboardType: TextInputType.number,
                            cursorColor: Color(customColorGreen()),
                            decoration:  const InputDecoration(
                              border: InputBorder.none,
                              hintText: '0',
                              hintStyle: TextStyle(fontSize: 14),
                            ),

                          )
                              : DropdownButtonFormField(
                            value: _controllerAll[index].text.isNotEmpty ? _controllerAll[index].text : null,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Pilih',
                              hintStyle: TextStyle(fontSize: 14),
                            ),
                            items: <String>[
                              'Potong Kain',
                              'Jahit',
                              'Obras',
                              'Pasang Kolor',
                              'Setrika'
                            ].map((String value) {

                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                                onTap: (){
                                  setState(() {
                                    _controllerAll[index].text = value;
                                  });
                                },
                              );
                            }).toList(),
                            onChanged: (_){},
                            validator: (value){
                              if(value == null || value.toString() == ''){
                                return 'Pilih salah satu';
                              }
                              else{
                                return null;
                              }
                            },
                          ),
                        ),
                      ),
                      //add empty widget in the last index
                      // (index==_jumlahController-1)? const SizedBox(width: 0,height: 72,) : const SizedBox(height: 0,width: 0,)
                    ])
            );
          },
        )
    );
  }
}
