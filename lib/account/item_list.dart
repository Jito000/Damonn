import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../custom_asset/custom_color.dart';
import '../custom_asset/custom_circular_progress.dart';
import '../custom_asset/show_dialog_error_unPage.dart';
import '../custom_asset/show_snackbar.dart';
import '../login/login.dart';
import 'proses_logout.dart';
import 'proses_update.dart';

class ItemList extends StatefulWidget {
  const ItemList({Key? key}) : super(key: key);

  @override
  _ItemListState createState() => _ItemListState();
}

class _ItemListState extends State<ItemList> {
  late final List<double> _size = [];
  late final List<double> _turns = [];
  late final List<String> _dataBeforeEdit = [];

  final List<String> _keyUser = ['nama','password','nohp','kategori'];
  final List<String> _labelUser = ['Nama Lengkap','Password','No. Handphone', 'Kategori'];
  final ref = FirebaseDatabase.instance.ref();

  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  //check shared preferences value
  late Future<String> _check;

  final _keyItemList        = GlobalKey<FormState>();

  final List<TextEditingController> _controllerAll = [];


  void changeVisibility(int index){
    setState(() {
      if(_size[index] == 0){
        _size[index] = 72;
        _turns[index] = 0.5;
      }
      else{
        _size[index] = 0;
        _turns[index] = 0;
      }
    });
  }

  void getData(MapEntry data){
    _controllerAll[0].text = data.value['nama'];
    _controllerAll[1].text = data.value['password'];
    _controllerAll[2].text = data.value['nohp'];
    //menyimpan data, dibandingan saat proses update
    // setState(() {
      _dataBeforeEdit[0] = data.value['nama'];
      _dataBeforeEdit[1] = data.value['password'];
      _dataBeforeEdit[2] = data.value['nohp'];
    // });
  }

  @override
  void initState() {
    _check = _prefs.then((SharedPreferences prefs) {
      return prefs.getString('nohp') ?? '';
    });
    for(int i = 0;i < _keyUser.length; i++){
      _size.add(0);
      _turns.add(0);
      _dataBeforeEdit.add('');
      _controllerAll.add(TextEditingController());
    }

    super.initState();
  }
  @override
  void dispose() {
    _keyItemList.currentState?.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _check,
      builder: (BuildContext context, AsyncSnapshot<String> snapshotSharedPref) {
        if(snapshotSharedPref.hasData){

          return StreamBuilder(
            stream: ref.child('users').orderByChild('nohp').equalTo(snapshotSharedPref.data).onValue,
            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshotFirebase) {
              if(snapshotFirebase.hasData){
                // print(map.entries.elementAt(0).value['nama']);
                final Map data = snapshotFirebase.data.snapshot.value ;
                // menyimpan data untuk dibandingkan dengan input
                // dan mengisi input field
                getData(data.entries.elementAt(0));
                return Column(
                  children: [
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _keyUser.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          elevation: 2,
                          color: Color(customColorGray()),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)
                          ),
                          child: Stack(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: AnimatedContainer(
                                    margin: EdgeInsets.only(top: _size[index]),
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(50)
                                    ),
                                    duration: const Duration(milliseconds: 750),
                                    curve: Curves.ease,
                                    child: Stack(
                                      alignment: Alignment.centerRight,
                                      children: [
                                        Form(
                                          // key: _keyItemList,
                                          child: Padding(
                                            padding: const EdgeInsets.only(left: 24,right: 50),
                                            child: TextFormField(
                                              controller: _controllerAll[index],
                                              cursorColor: Color(customColorGreen()),
                                              decoration:  const InputDecoration(
                                                border: InputBorder.none,
                                                hintText: 'Tidak boleh dikosongkan',
                                                hintStyle: TextStyle(fontSize: 14),

                                              ),
                                            ),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6),
                                          decoration: BoxDecoration(
                                              color: Color(customColorGreen()),
                                              borderRadius: const BorderRadius.only(bottomRight: Radius.circular(50),topRight: Radius.circular(50))
                                          ),
                                          child: IconButton(
                                            icon: const Icon(
                                              Icons.check,
                                              color: Colors.white,
                                            ),
                                            onPressed: (){
                                              // index 2 is password input field
                                              if(_dataBeforeEdit[index] == _controllerAll[index].text){
                                                customAlertDialogUnpage(context, 'Input tidak boleh sama.');
                                              }
                                              else if(_controllerAll[index].text == ''){
                                                customAlertDialogUnpage(context, 'Tidak Boleh kosong!');
                                              }
                                              else if(_controllerAll[index].text.length < 5 && index != 2){
                                                customAlertDialogUnpage(context, 'Minimal 5 karakter');
                                              }
                                              else if(_controllerAll[index].text.length < 11 && index == 2){
                                                customAlertDialogUnpage(context, 'Minimal 11 angka');
                                              }
                                              else if(index != 2){
                                                Navigator.of(context).push(
                                                  PageRouteBuilder(
                                                    opaque: false, // set to false
                                                    barrierDismissible: true,
                                                    barrierColor: Colors.black.withOpacity(0.5),
                                                    pageBuilder: (_, __, ___) => UpdateProses(
                                                      //send data to process upload
                                                      titleKey: _keyUser[index],
                                                      idUser: data.entries.elementAt(0).key,
                                                      controller: _controllerAll[index].text,
                                                      ),
                                                  ),
                                                ).then((value){
                                                  //when back tapped return value to change mode
                                                  if(value != null){
                                                    changeVisibility(index);
                                                  }
                                                });
                                              }
                                              else{
                                                customAlertDialogUnpage(context, 'No HP belum bisa diubah');
                                              }

                                            },
                                          ),
                                        ),
                                      ],
                                    )
                                ),
                              ),
                              Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                      color: Color(customColorLayoutBackground()),
                                      borderRadius: BorderRadius.circular(20)
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(left: 6),
                                        child: Text(
                                          _labelUser[index],
                                          style: TextStyle(
                                              color: Color(customColorBlack()),
                                              fontSize: 16
                                          ),
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          SizedBox(
                                            width: 108,
                                            child: Text(
                                              //index 0 = nama, 1 password, 2 nohp
                                              index == 1 ?
                                                '*******'
                                                  : data.entries.elementAt(0).value[_keyUser[index]],

                                              textAlign: TextAlign.end,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  color: Color(customColorAccentFont()),
                                                  fontSize: 12
                                              ),
                                            ),
                                          ),
                                          AnimatedRotation(
                                              turns: _turns[index],
                                              duration: const Duration(milliseconds: 500),
                                            curve: Curves.easeOut,
                                            child: IconButton(
                                                icon: const Icon(Icons.keyboard_arrow_down),
                                                onPressed: index == 3 ? (){
                                                  customSnackBar(context, 'Tidak dapat diedit.');
                                                } : (){
                                                  changeVisibility(index);
                                                },
                                              ),
                                          )

                                        ],
                                      ),
                                    ],
                                  )),
                            ],
                          ),
                        );
                      },

                    ),
                    Container(
                      margin: const EdgeInsets.all(36),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(50),
                        onTap: (){
                          Navigator.of(context).push(
                            PageRouteBuilder(
                              opaque: false, // set to false
                              barrierDismissible: true,
                              barrierColor: Colors.black.withOpacity(0.5),
                              pageBuilder: (_, __, ___) => const LogoutProcess(),
                            ),
                          );
                        },
                        child: Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            border: Border.all(
                              color: Color(customColorRed()).withOpacity(0.8)
                            ),

                          ),

                            child: Text('Logout',style: TextStyle(color: Color(customColorRed())),)
                        ),
                      ),
                    )
                  ],
                );
              }
              else{
                return SizedBox(
                  height: MediaQuery.of(context).size.height/2,
                    child: const Center(child: CustomCircularProgressIndicator()));
              }

            },
          );
        }
        else{
          return errorLayout('Sepertinya anda belum login', true);
        }

      },);

  }
  Widget errorLayout(String message, bool login){
    return Center(
      child: Container(
        color: Color(customColorWhite()),
        width: 200,
        height: 200,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
            ),
            login == true ?
              InkWell(
                child: const Text('Login'),
                onTap: (){
                  Navigator.of(context).push(
                    PageRouteBuilder(
                        pageBuilder: (_, __, ___) => const LoginPage()
                    ),
                  );
                },
              ) : Container()
          ],
        ),
      ),
    );
  }
}
