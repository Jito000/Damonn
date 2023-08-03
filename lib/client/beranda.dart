
import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../custom_asset/custom_circular_progress.dart';
import '../custom_asset/custom_color.dart';
import '../custom_asset/show_dialog_error_unPage.dart';
import 'proses_simpan.dart';

class OverviewPage extends StatefulWidget {
  final String idAccount;
  const OverviewPage({Key? key, required this.idAccount}) : super(key: key);

  @override
  _OverviewPageState createState() => _OverviewPageState();
}

class _OverviewPageState extends State<OverviewPage> {

  final _ref = FirebaseDatabase.instance.ref();
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  //check shared preferences value
  late Future<String> _check;
  late var _mode        = 'show';
  final _formKey        = GlobalKey<FormState>();

  final int _jumlahController = 5;
  final List<TextEditingController> _controllerAll = [];
  //card title
  final List<String> _title   =['Tesa', 'Celana','Ami', 'Jumbo', 'Tanggung / ¾'];
  //firebase key so the value same with title above
  final List<String> _titleKey=['tesa', 'celana','ami', 'jumbo', 'tanggung'];
  late bool _isButtonEnable = true;

  void changeMode(String mode) {
    //ketika void dipanggil mengganti mode
    setState(() {
      _mode = mode;
    });
  }
  void isButtonEnable(bool value){
    setState(() {
      _isButtonEnable = value;
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
    for (int i = 1; i <= _jumlahController; i++) {
      _controllerAll.add(TextEditingController());
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    switch(_mode){
      case 'show':
        return Scaffold(
          body: showMode(),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          floatingActionButton: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FutureBuilder(
                future: _ref.child('users/${widget.idAccount}/kategori').get(),
                builder: (BuildContext context, AsyncSnapshot<dynamic> snapshotKategori) {

                  // print(snapshotKategori.data.value);
                  if(snapshotKategori.hasData){
                    return snapshotKategori.data.value == 'Potong Kain' ?
                      FloatingActionButton(
                        elevation: 3,
                        backgroundColor: Color(customColorGreen()),
                        onPressed:  () {

                          changeMode('edit'); //pindah halaman input
                        },
                        child: const Icon(Icons.add_outlined),
                      )
                        : Container();
                  }
                  else{
                    return const CustomCircularProgressIndicator();
                  }

                }
              ),
            ],
          ),
        );

      case 'edit' :
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
                      changeMode('show');
                    },
                  ),

                  FloatingActionButton(
                     heroTag: 'submitButton',
                      elevation: 3,
                      backgroundColor: Color(customColorGreen()),
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
                            initializeDateFormatting() ;  //penting mengubah waktu ke indo
                            final now = DateTime.now();
                            //mengambil waktu sekarang hingga detik
                            String tanggal = DateFormat('d MMMM y HH:mm:ss','id').format(now);
                            //uploadData(context,snapshot.data);
                            Navigator.of(context).push(
                              PageRouteBuilder(
                                opaque: false, // set to false
                                barrierDismissible: true,
                                barrierColor: Colors.black.withOpacity(0.5),
                                pageBuilder: (_, __, ___) => ProsesSimpan(
                                  //send data to process upload
                                  titleKey: _titleKey,
                                  idAccount: widget.idAccount,
                                  controller: _controllerAll,
                                  tanggal: tanggal,),
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
                      child: const Icon(
                        Icons.check,
                      ),
                    )

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

  //------------------- Separator ---------------

  //layout show mode
  Widget showMode(){
    //future builder to get shared preference : nohp
    return FutureBuilder(
        future: _check,
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshotSharedPref) {
          //future builder to get data from firebase
          if(snapshotSharedPref.hasData){

            return StreamBuilder(
              stream: _ref.child('users').orderByChild('nohp').equalTo(snapshotSharedPref.data).onValue,
              builder: (BuildContext context, AsyncSnapshot<dynamic> snapshotAkun) {
                if(snapshotAkun.hasData){
                  final Map dataAkun = snapshotAkun.data.snapshot.value;
                  // print(dataAkun.entries.elementAt(0).key);
                  return StreamBuilder(
                    //get nohp value from sharedpreferene
                    stream: _ref.child('data/client/${dataAkun.entries.elementAt(0).key}/total').onValue,
                    builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                      if (snapshot.hasData) {
                        //show
                        return GridView.builder(
                            padding: const EdgeInsets.only(top: 24),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: (1 / .75),
                            ),
                            itemCount: _titleKey.length,
                            itemBuilder: (BuildContext contex, int index) {
                              //separating widget so can easily read the code
                              return itemShowMode(snapshot.data.snapshot, index);
                            });
                      }
                      else{return const Center(child: CustomCircularProgressIndicator());}
                    },
                  );
                }
                else{return const Center(child: CustomCircularProgressIndicator());}
              }
            );
          }
          else{return const Center(child: CustomCircularProgressIndicator());}
        }
    );
  }

  Widget itemShowMode(DataSnapshot snapshot,int index){

          return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.fromLTRB(36, 6, 0, 0),
                  //title card
                  child:  Text(_title[index], style:  TextStyle(fontSize: 14,color: Color(customColorBlack()))),
                ),
                Card(
                  color: Color(customColorLayoutBackground()),
                  margin: const EdgeInsets.all(12),
                  elevation: 0,
                  child: Padding(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
                    child: AutoSizeText(
                      //value card
                      snapshot.child(_titleKey[index]).value.toString(),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      style: TextStyle(
                          fontSize: 24, color: Color(customColorGreen())),
                    ),
                  ),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                )
              ]);
  }

  //----------- Separator ---------------

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
