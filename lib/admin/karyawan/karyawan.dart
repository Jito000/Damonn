import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../custom_asset/custom_circular_progress.dart';
import '../../custom_asset/custom_color.dart';
import '../../custom_asset/show_dialog_error_unPage.dart';
import 'proses_karyawan.dart';

class Karyawan extends StatefulWidget {
  const Karyawan({Key? key}) : super(key: key);

  @override
  _KaryawanState createState() => _KaryawanState();
}

class _KaryawanState extends State<Karyawan> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  final _ref = FirebaseDatabase.instance.ref();
  late Future<String> _check;
  late String _mode        ;
  late String _uploadMode;

  final List _datadiriLabel = ['Nama', 'No. Handphone','Password','Kategori'];
  //data detail
  late Map<dynamic,dynamic> _selectedData ;
  late String _keySelectedData;

  // input mode
  late final int _jumlahController;
  final List<TextEditingController> _controllerAll = [];
  final _formKey        = GlobalKey<FormState>();

  //layout state
  late bool isPasswordVisible;

  void changePasswordVisibility(){
    setState(() {
      isPasswordVisible == false
          ? isPasswordVisible = true
          :isPasswordVisible = false;
    });
  }

  void changeMode(String mode) {
    //ketika void dipanggil mengganti mode
    setState(() {
      _mode = mode;
    });
  }

  void fillSelectedData(Map data, String key){
    setState(() {
      _selectedData = data;
      _keySelectedData = key;
    });
  }

  void uploadMode(String mode){
    setState(() {
      _uploadMode = mode;
    });
  }
  @override
  void dispose() {
    for (int i = 0; i <= _jumlahController-1; i++) {
      _controllerAll[i].dispose();
    }
    super.dispose();
  }

  @override
  void initState() {
    _check = _prefs.then((SharedPreferences prefs) {
      return prefs.getString('nohp') ?? '';
    });
    if(_check.toString()==''){changeMode('show');}
    //inisialisasi jumlah controller
    _jumlahController = _datadiriLabel.length;
    //inisialisasi jumlah controller
    for (int i = 1; i <= _jumlahController; i++) {
      _controllerAll.add(TextEditingController());
    }
                // state variabel
    //state empty map
    _selectedData = {};
    _mode = 'show';
    _uploadMode  = '';
    isPasswordVisible = true;
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    switch(_mode){

      case 'show':
        return Scaffold(
          floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: Color(customColorBlue()),
            elevation: 3,
            label: const Text('Tambah Karyawan'),
            onPressed: (){
              uploadMode('input');
              changeMode('edit');
            },
          ),
          body: StreamBuilder(
            //get nohp value from sharedpreferene
            stream: _ref.child('users').orderByChild('status').onValue,
            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
              //get no hp use, passing to delete layout

              if(snapshot.connectionState == ConnectionState.waiting){
                return const CustomCircularProgressIndicator();
              }
              else if (snapshot.data.snapshot.value != null) {
                //menyimpan data snapshot menjadi map
                Map<dynamic,dynamic> map = snapshot.data.snapshot.value;
                // menghapus data map dimana value kategori == admin
                map.removeWhere((key, value) {
                  return value['kategori'] == 'admin';
                });
                return ListView.builder(
                  // panjang list berdasarkan map yang telah dikurangi
                    itemCount: map.length , //get length by key of database
                    padding: const EdgeInsets.only(top: 24),
                    itemBuilder: (BuildContext context, int index) {
                      return itemShow(index, map);
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
          ),
        );
      case 'edit':
        return Scaffold(
          body: editMode(),
          floatingActionButtonLocation:
          FloatingActionButtonLocation.centerFloat,
          floatingActionButton: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
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
                      //membersihkan input field
                      for (var index = 0; index < _controllerAll.length; index++) {
                        setState(() {
                          _controllerAll[index].text = '';
                        });
                      }
                      //mengganti layout ke mode show
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
                          onPressed:() async {
                            if (  _formKey.currentState!.validate()) {
                              var counterFilled = 0;
                              for (var element in _controllerAll) {
                                if(element.text.isNotEmpty){
                                  setState(() {
                                    counterFilled+=1;
                                  });
                                }

                              }
                              if(counterFilled == _controllerAll.length){
                                //mengirim request ke firebase
                                Navigator.of(context).push(
                                  PageRouteBuilder(
                                    opaque: false, // set to false
                                    barrierDismissible: true,
                                    barrierColor: Colors.black.withOpacity(0.5),
                                    pageBuilder: (_, __, ___) => TambahKaryawan(
                                      //send data to process upload
                                      data: _controllerAll,
                                      mode: _uploadMode,
                                      ),
                                  ),
                                ).then((value){
                                  //when back tapped return value to change mode
                                  if(value!=null){
                                    changeMode(value);
                                  }
                                });
                              }
                              else{

                                customAlertDialogUnpage(context, 'Isi Semua data!');
                              }
                            }
                          },
                        );
                      }
                  ),
                ],
              )),
        );
      case 'detail':
        return Scaffold(
          body: detailMode(),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
          floatingActionButton: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                  onPressed: (){
                    Navigator.of(context).push(
                      PageRouteBuilder(
                        opaque: false, // set to false
                        barrierDismissible: true,
                        barrierColor: Colors.black.withOpacity(0.5),
                        pageBuilder: (_, __, ___) => TambahKaryawan(
                          //send data to process upload
                          data: _controllerAll,
                          mode: 'hapus',
                          keyPath: _keySelectedData,
                        ),
                      ),
                    ).then((value){
                      //when back tapped return value to change mode
                      if(value!=null){
                        changeMode(value);
                      }
                    });
                  },
                  color: Color(customColorRed()),
                  icon: const Icon(Icons.delete)
              ),
              InkWell(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width/7, vertical: 12),
                  decoration: BoxDecoration(
                      color: Color(customColorBlue()),
                      border: Border.all(
                        color: Color(customColorBlue()),
                      ),
                      borderRadius: const BorderRadius.horizontal(left: Radius.circular(50))
                  ),
                  child: const Text('Edit',style: TextStyle(color: Colors.white,fontSize: 16)),
                ),
                onTap:(){
                  _controllerAll[0].text = _selectedData.values.elementAt(1);
                  _controllerAll[1].text = _selectedData.values.elementAt(3);
                  _controllerAll[2].text = _selectedData.values.elementAt(0);
                  _controllerAll[3].text = _selectedData.values.elementAt(2);
                  uploadMode('edit');
                  changeMode('edit');
                }
              ),
              InkWell(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width/7 , vertical: 12),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Color(customColorBlue()),
                    ),
                    borderRadius: const BorderRadius.horizontal(right: Radius.circular(50))
                  ),
                  child: Text('Tutup',style: TextStyle(color: Color(customColorBlue()),fontSize: 16),),
                ),
                onTap: (){
                  changeMode('show');
                },
              ),

            ],
          ),
        );
      default:
        return SizedBox(
            height: MediaQuery.of(context).size.height/2,
            width: MediaQuery.of(context).size.width/2,
            child: const Center(child: CustomCircularProgressIndicator()));
    }
  }
  Widget itemShow(int index, Map<dynamic,dynamic> data){
    return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: (){
              fillSelectedData(data.values.elementAt(index), data.keys.elementAt(index));
              changeMode('detail');
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
                          data.entries.elementAt(index).value['nama'],
                          style: TextStyle(fontSize: 16,color: Color(customColorBlack())),
                        ),
                        Text(
                          //call function to delete hour on date and return the value
                          data.entries.elementAt(index).value['kategori'],
                          style: TextStyle(fontSize: 12,color: Color(customColorBlack())),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text('Detail',style: TextStyle(color: Color(customColorBlue()),fontSize: 12),),
                        const SizedBox(width: 3,),
                        Icon(Icons.arrow_forward_ios,color: Color(customColorAccentFont()),size: 12,)
                      ],
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
  //----------- Separator ---------------

  Widget editMode(){

    return Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              //jarak label dengan header
              const SizedBox(height: 24),
              //form nama karyawan
              Padding(
                padding: EdgeInsets.fromLTRB(24, 12, MediaQuery.of(context).size.width/4.toDouble(), 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // title of the card
                    Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 0, 3),
                    child: Text(_datadiriLabel[0],style: TextStyle(color: Color(customColorPrimaryFont()),fontSize: 16),),
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
                          controller: _controllerAll[0],
                          keyboardType: TextInputType.name,
                          cursorColor: Color(customColorGreen()),
                          decoration:  const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Masukkan nama',
                            hintStyle: TextStyle(fontSize: 14),
                          ),
                          validator: (value){
                            if(value!.length < 3){
                              return 'minimal 3 huruf';
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
              ),
              //form no hp
              Padding(
                  padding: EdgeInsets.fromLTRB(24, 12, MediaQuery.of(context).size.width/4.toDouble(), 6),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // title of the card
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 0, 3),
                          child: Text(_datadiriLabel[1],style: TextStyle(color: Color(customColorPrimaryFont()),fontSize: 16),),
                        ),
                        // the card
                        Container(
                          // margin: const EdgeInsets.symmetric(vertical: 3), // jarak antar field
                          decoration: BoxDecoration(
                              color: Color(customColorLayoutBackground()),
                              borderRadius: const BorderRadius.all(Radius.circular(20))
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
                            //input field
                            child: TextFormField(
                              controller: _controllerAll[1],
                              keyboardType: TextInputType.number,
                              cursorColor: Color(customColorGreen()),
                              decoration: const InputDecoration(
                                border: InputBorder.none,


                                hintText: '08xxx',
                                hintStyle: TextStyle(fontSize: 14),
                              ),
                              validator: (value){
                                if(value!.length< 11 || value.length > 12){
                                  return 'No. HP tidak sesuai';
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
              ),
              //form password
              Padding(
                  padding: EdgeInsets.fromLTRB(24, 12, MediaQuery.of(context).size.width/4.toDouble(), 6),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // title of the card
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 0, 3),
                          child: Text(_datadiriLabel[2],style: TextStyle(color: Color(customColorPrimaryFont()),fontSize: 16),),
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
                              controller: _controllerAll[2],
                              obscureText: isPasswordVisible,
                              cursorColor: Color(customColorGreen()),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Masukkan password',
                                hintStyle: const TextStyle(fontSize: 14),
                                suffixIcon: IconButton(
                                  icon: isPasswordVisible == false
                                      ? const Icon(Icons.visibility)
                                      : const Icon(Icons.visibility_off),
                                  onPressed: changePasswordVisibility,

                                ),
                              ),
                              validator: (value){
                                if(value!.length < 5){
                                  return 'password minimal 5 huruf';
                                }
                                return null;
                              },
                            ),
                          ),
                        ),
                        //add empty widget in the last index
                        // (index==_jumlahController-1)? const SizedBox(width: 0,height: 72,) : const SizedBox(height: 0,width: 0,)
                      ])
              ),
              //form kategori karyawan
              Padding(
                  padding: EdgeInsets.fromLTRB(24, 12, MediaQuery.of(context).size.width/4.toDouble(), 6),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // title of the card
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 0, 3),
                          child: Text(_datadiriLabel[3],style: TextStyle(color: Color(customColorPrimaryFont()),fontSize: 16),),
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
                            child: DropdownButtonFormField(
                              value: _controllerAll[3].text.isNotEmpty ? _controllerAll[3].text : null,
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
                                        _controllerAll[3].text = value;
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
                                )
                          ),
                        ),
                        //add empty widget in the last index
                        // (index==_jumlahController-1)? const SizedBox(width: 0,height: 72,) : const SizedBox(height: 0,width: 0,)
                      ])
              ),
            ],
          ),
        )
    );
  }
  //----------- separator ---------------
Widget detailMode(){
    return Padding(
      padding: EdgeInsets.only(left: 12, right: MediaQuery.of(context).size.width/4.toDouble(), top: 36),
      child: Column(
        children: [
          // -------------- nama -------------------
          Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.fromLTRB(24, 12, 0, 0),
                  //title card
                  child:  Text('Nama', style:  TextStyle(fontSize: 14,color: Color(customColorPrimaryFont()))),
                ),
                Card(
                  color: Color(customColorLayoutBackground()),
                  margin: const EdgeInsets.all(12),
                  elevation: 0,
                  child: Padding(
                    padding:
                    const EdgeInsets.all(16),
                    child: AutoSizeText(
                      //value card
                      //nama berada pada elemen ke - 1
                      _selectedData.values.elementAt(1),
                      textAlign: TextAlign.left,
                      maxLines: 1,
                      style: TextStyle(
                          fontSize: 16, color: Color(customColorGreen())),
                    ),
                  ),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                )
              ]),
          // --------------- no handphone ----------
          Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.fromLTRB(24, 12, 0, 0),
                  //title card
                  child:  Text('No. Handphone', style:  TextStyle(fontSize: 14,color: Color(customColorPrimaryFont()))),
                ),
                Card(
                  color: Color(customColorLayoutBackground()),
                  margin: const EdgeInsets.all(12),
                  elevation: 0,
                  child: Padding(
                    padding:
                    const EdgeInsets.all(16),
                    child: AutoSizeText(
                      //value card
                      _selectedData.values.elementAt(3),
                      textAlign: TextAlign.left,
                      maxLines: 1,
                      style: TextStyle(
                          fontSize: 16, color: Color(customColorGreen())),
                    ),
                  ),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                )
              ]),
          // --------------------- kategori ------------------
          Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.fromLTRB(24, 12, 0, 0),
                  //title card
                  child:  Text('Kategori', style:  TextStyle(fontSize: 14,color: Color(customColorPrimaryFont()))),
                ),
                Card(
                  color: Color(customColorLayoutBackground()),
                  margin: const EdgeInsets.all(12),
                  elevation: 0,
                  child: Padding(
                    padding:
                    const EdgeInsets.all(16),
                    child: AutoSizeText(
                      //value card
                      //nama berada pada elemen ke - 1
                      _selectedData.values.elementAt(2),
                      textAlign: TextAlign.left,
                      maxLines: 1,
                      style: TextStyle(
                          fontSize: 16, color: Color(customColorGreen())),
                    ),
                  ),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                )
              ]),
        ],
      ),
    );
}
}
