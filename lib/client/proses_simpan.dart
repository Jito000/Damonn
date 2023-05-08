import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../custom_asset/custom_circular_progress.dart';
import '../custom_asset/custom_color.dart';
import '../custom_asset/show_dialog_error_unPage.dart';
import '../custom_asset/show_snackbar.dart';

class ProsesSimpan extends StatefulWidget {
  final List<String> titleKey;
  final List<TextEditingController> controller;
  final String idAccount;
  final String tanggal;
  const ProsesSimpan({Key? key, required this.idAccount, required this.titleKey, required this.controller, required this.tanggal }) : super(key: key);

  @override
  _ProsesSimpanState createState() => _ProsesSimpanState();
}

class _ProsesSimpanState extends State<ProsesSimpan> {
  bool _isLoading = false;
  final _ref = FirebaseDatabase.instance.ref();

  //set height to avoid overflow on dialog
  double tinggi = 200;

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
                          padding: const EdgeInsets.only(top: 14, bottom: 16, left: 51,right: 40),
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
                        padding: const EdgeInsets.only(top: 14, bottom: 16, left: 49,right: 49),
                        decoration: BoxDecoration(
                          color: Color(customColorGreen()),
                          borderRadius: const BorderRadius.only(
                            bottomRight: Radius.circular(20.0),
                          ),
                        ),
                        child: Text('Simpan',style: TextStyle(color: Color(customColorLayoutBackground())))
                    ),
                    onTap: (_isLoading==true) ? (){} : () async {
                      setState(() {
                        tinggi+=17;
                      });
                      isLoading(true);
                      try {
                        _ref.child('users/${widget.idAccount}').get().then((
                            snapshot) async {
                          // print(snapshot.child('kategori').value);
                          //menyalin data ke riwayat user
                          _ref.child(
                              "data/client/${widget.idAccount}/riwayat/${widget
                                  .tanggal}")
                              .update({
                            widget.titleKey[0]: widget.controller[0].text,
                            widget.titleKey[1]: widget.controller[1].text,
                            widget.titleKey[2]: widget.controller[2].text,
                            widget.titleKey[3]: widget.controller[3].text,
                            widget.titleKey[4]: widget.controller[4].text,
                            'status': snapshot
                                .child('kategori')
                                .value,

                          });
                          //mengupdate status dan jumlah pada admin
                          _ref.child("data/admin/riwayat/${widget.tanggal}")
                              .update({
                            widget.titleKey[0]: widget.controller[0].text,
                            widget.titleKey[1]: widget.controller[1].text,
                            widget.titleKey[2]: widget.controller[2].text,
                            widget.titleKey[3]: widget.controller[3].text,
                            widget.titleKey[4]: widget.controller[4].text,
                            // memperbarui status berdasarkan kategori akun/job user
                            'status': snapshot
                                .child('kategori')
                                .value,

                          });
                          //jika kategori pengguna adalah setrika, menambahkan total produksi db total admin
                          if(snapshot.child('kategori').value == 'Setrika'){
                            _ref.child("data/admin/total")
                                .update({
                              widget.titleKey[0]: ServerValue.increment(
                                  int.parse(widget.controller[0].text)),
                              widget.titleKey[1]: ServerValue.increment(
                                  int.parse(widget.controller[1].text)),
                              widget.titleKey[2]: ServerValue.increment(
                                  int.parse(widget.controller[2].text)),
                              widget.titleKey[3]: ServerValue.increment(
                                  int.parse(widget.controller[3].text)),
                              widget.titleKey[4]: ServerValue.increment(
                                  int.parse(widget.controller[4].text))
                            });
                          }
                          //MENGUPDATAE JUMLAH TOTAL hasil produksi user
                          _ref.child("data/client/${widget.idAccount}/total")
                              .update({
                            widget.titleKey[0]: ServerValue.increment(
                                int.parse(widget.controller[0].text)),
                            widget.titleKey[1]: ServerValue.increment(
                                int.parse(widget.controller[1].text)),
                            widget.titleKey[2]: ServerValue.increment(
                                int.parse(widget.controller[2].text)),
                            widget.titleKey[3]: ServerValue.increment(
                                int.parse(widget.controller[3].text)),
                            widget.titleKey[4]: ServerValue.increment(
                                int.parse(widget.controller[4].text))
                          });
                          customSnackBar(context, 'Data tersimpan...');
                        });
                      }catch(error){
                        customAlertDialogUnpage(context, error.toString());
                      }
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
