import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../admin/menu.dart';
import '../client/menu.dart';
import '../custom_asset/custom_circular_progress.dart';
import '../custom_asset/custom_color.dart';
import '../custom_asset/show_dialog_error_unPage.dart';

class ProsesLogin extends StatefulWidget {
  final String nomor;
  final String password;
  const ProsesLogin({Key? key, required this.nomor, required this.password}) : super(key: key);

  @override
  _ProsesLoginState createState() => _ProsesLoginState();
}

class _ProsesLoginState extends State<ProsesLogin> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  final _ref = FirebaseDatabase.instance.ref();
  bool _isLoading = false;

  //set height to avoid overflow on dialog
  double tinggi=200;

  void isLoading(bool value){
    setState(() {
      tinggi += 17;
      _isLoading = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: const EdgeInsets.only(top: 12),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20))),
      content: SizedBox(
        height: tinggi,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 66),
              child: Center(child: (_isLoading==false) ? const Text('Nomor dan password sudah benar?') :  const CustomCircularProgressIndicator()),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                InkWell(
                  onTap: (){Navigator.pop(context);},
                    child: Container(
                        padding: const EdgeInsets.only(top: 14, bottom: 16, left: 36,right: 36),
                        decoration: BoxDecoration(
                          color: Color(customColorRed()),
                          borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(20.0),
                          ),
                        ),
                        child: Text('Tunggu',style: TextStyle(color: Color(customColorLayoutBackground()))))),
                InkWell(
                  child: Container(
                      padding: const EdgeInsets.only(top: 17, bottom: 16, left: 38,right: 37),
                      decoration: BoxDecoration(
                        color: Color(customColorGreen()),
                        borderRadius: const BorderRadius.only(
                            bottomRight: Radius.circular(20.0)),
                      ),
                      child: Text('Ya, lanjutkan',style: TextStyle(color: Color(customColorLayoutBackground()),fontSize: 14))),
                  onTap: (_isLoading==true) ? (){} : () async {


                    isLoading(true);
                    final SharedPreferences prefs = await _prefs;
                    //get value from firebase
                    final snapshot = await _ref.child('users').orderByChild('nohp').equalTo(widget.nomor)
                        .get()
                        .timeout(
                        const Duration(seconds: 15),
                        onTimeout: (){
                          throw customAlertDialogUnpage(context, 'Tidak ada Internet!');
                        });

                    if(snapshot.exists){
                      // print(snapshot.children.first.child('nohp').value);
                      if(snapshot.children.first.child('password').value == widget.password){
                        //simpan id Akun ke shared preferernce
                        prefs.setString('idAccount',snapshot.children.first.key.toString());
                        // simpan no hp ke shared preference
                        prefs.setString('nohp',widget.nomor);
                        // customSnackBar(context, "Login Berhasil...");
                        if(snapshot.children.first.child('kategori').value == 'admin'){
                          //next page
                          Navigator.of(context).pushAndRemoveUntil(
                              PageRouteBuilder(
                                opaque: false, // set to false
                                barrierDismissible: true,
                                barrierColor: Colors.black.withOpacity(0.3),
                                pageBuilder: (_, __, ___) => const AdminMenu(),
                              ), (route) => false
                          );
                        }
                        else{
                        // else if(snapshot.child('kategori').value == 'client'){
                          //next page
                          Navigator.of(context).pushAndRemoveUntil(
                              PageRouteBuilder(
                                opaque: false, // set to false
                                barrierDismissible: true,
                                barrierColor: Colors.black.withOpacity(0.3),
                                pageBuilder: (_, __, ___) => const ClientMenu(),
                              ), (route) => false
                          );
                        }

                      }
                      else {
                        Navigator.pop(context);
                        customAlertDialogUnpage(context, 'Password salah!');

                      }
                    }
                    else {
                      Navigator.pop(context);
                      customAlertDialogUnpage(context, 'No Handphone salah!');

                    }

                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
