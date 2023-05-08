

import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../custom_asset/custom_circular_progress.dart';
import '../../custom_asset/custom_color.dart';
import '../../custom_asset/show_dialog_error_unPage.dart';
import '../../custom_asset/show_snackbar.dart';

class TambahKaryawan extends StatefulWidget {
  final List<TextEditingController> data;
  final String mode;
  final String? keyPath;
  const TambahKaryawan({Key? key, required this.data, required this.mode, this.keyPath,}) : super(key: key);

  @override
  _TambahKaryawanState createState() => _TambahKaryawanState();
}

class _TambahKaryawanState extends State<TambahKaryawan> {
  final _ref = FirebaseDatabase.instance.ref();
  bool _isLoading = false;

  //set height to avoid overflow on dialog
  double tinggi=200;
  void isLoading(bool value){
    setState(() {
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
                padding: const EdgeInsets.symmetric(vertical: 66.0),
                child: Center(child: (_isLoading==false) ? const Text('Simpan data?') :  const CustomCircularProgressIndicator()),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  InkWell(
                      onTap: (){Navigator.pop(context);},
                      child: Container(
                          padding: const EdgeInsets.only(top: 14, bottom: 16, left: 49,right: 49),
                          decoration: BoxDecoration(
                            color: Color(customColorRed()),
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(20.0),
                            ),
                          ),
                          child: Text('Batal',style: TextStyle(color: Color(customColorLayoutBackground())))
                      )
                  ),
                  InkWell(
                    child: Container(
                        padding:  widget.keyPath == null?
                          const EdgeInsets.only(top: 14, bottom: 16, left: 46,right: 45):
                          const EdgeInsets.only(top: 14, bottom: 16, left: 49,right: 49),
                        decoration: BoxDecoration(
                          color: Color(customColorGreen()),
                          borderRadius: const BorderRadius.only(
                            bottomRight: Radius.circular(20.0),
                          ),
                        ),
                        child: AutoSizeText(
                            widget.keyPath == null? 'Simpan' : 'Hapus',
                            style: TextStyle(color: Color(customColorLayoutBackground())))
                    ),
                    onTap: (_isLoading==true) ? (){} : () async {
                      setState(() {
                        tinggi+=17;
                      });
                      isLoading(true);

                      if(widget.mode == 'input'){

                        // --- random value path dengan uuid
                        final now = DateTime.now();
                        final randomValue = const Uuid().v1(options: {'msecs': now.millisecondsSinceEpoch});

                        _ref.child('users').orderByChild('nohp').equalTo(widget.data[1].text).get().then((value){
                          if(value.exists){
                            customAlertDialogUnpage(context, 'Akun Telah ada!');
                          }
                          else{
                            _ref.child('users/$randomValue')
                                .update({
                              'nama'    : widget.data[0].text,
                              'nohp'    : widget.data[1].text,
                              'password': widget.data[2].text,
                              'kategori': widget.data[3].text,

                            }).whenComplete((){
                              _ref.child('data/client/$randomValue/total')
                                  .update({
                                'ami'       : '0',
                                'celana'    : '0',
                                'jumbo'     : '0',
                                'tanggung'  : '0',
                                'tesa'      : '0',

                              });
                              customSnackBar(context,'Akun berhasil dibuat');
                            });
                          }

                        });
                      }
                      else if(widget.mode == 'edit'){
                        _ref.child('users/${widget.keyPath}')
                            .update({
                          'nama'    : widget.data[0].text,
                          'nohp'    : widget.data[1].text,
                          'password': widget.data[2].text,
                          'kategori': widget.data[3].text,

                        });
                      }
                      else if(widget.mode == 'hapus'){
                        _ref.child('users/${widget.keyPath}').remove();
                        _ref.child('data/client/${widget.keyPath}').remove();
                        customSnackBar(context, 'Data Terhapus');
                      }
                      else{
                        customAlertDialogUnpage(context, 'Invalid Input Method!');
                      }
                      //create new database
                      // DatabaseReference ref = FirebaseDatabase.instance.ref("data/client/${widget.nohp}/riwayat/${widget.tanggal}");
                      // await ref.update({
                      //   widget.titleKey[0]: widget.controller[0].text,
                      //   widget.titleKey[1]: widget.controller[1].text,
                      //   widget.titleKey[2]: widget.controller[2].text,
                      //   widget.titleKey[3]: widget.controller[3].text,
                      //   widget.titleKey[4]: widget.controller[4].text,
                      //   'status'          : 'pending',
                      //
                      //   // ignore: void_checks
                      // }).timeout(const Duration(seconds: 10),onTimeout: (){
                      //   return customSnackBar(context, 'Dilanjutkan saat terhubung INTERNET');
                      // }).then((value) => customSnackBar(context, 'Data tersimpan...'));
                      //when time reach 10 seconds auto cancel the update process

                      //update the total value in firebase
                      // ref = FirebaseDatabase.instance.ref("data/total/${widget.nohp}");
                      // await ref.update({
                      //   widget.titleKey[0]: ServerValue.increment(int.p arse(widget.controller[0].text)),
                      //   widget.titleKey[1]: ServerValue.increment(int.parse(widget.controller[1].text)),
                      //   widget.titleKey[2]: ServerValue.increment(int.parse(widget.controller[2].text)),
                      //   widget.titleKey[3]: ServerValue.increment(int.parse(widget.controller[3].text)),
                      //   widget.titleKey[4]: ServerValue.increment(int.parse(widget.controller[4].text))
                      //   // ignore: void_checks
                      // }).timeout(const Duration(seconds: 10),onTimeout: (){
                      //   return customSnackBar(context, 'Dilanjutkan saat terhubung INTERNET');
                      // }).then((value) => customSnackBar(context, 'Data tersimpan...'));

                      Navigator.pop(context,'show');
                    },
                  ),
                ],
              )
            ],
          )),
    );
  }
}
