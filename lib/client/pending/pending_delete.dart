import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../../custom_asset/custom_circular_progress.dart';
import '../../custom_asset/custom_color.dart';
import '../../custom_asset/show_dialog_error_unPage.dart';
import '../../custom_asset/show_snackbar.dart';


class PendingDelete extends StatefulWidget {
  final String id;
  final String idAccount;
  const PendingDelete({Key? key, required this.id, required this.idAccount }) : super(key: key);

  @override
  _PendingDeleteState createState() => _PendingDeleteState();
}

class _PendingDeleteState extends State<PendingDelete> {
  bool _isLoading = false;

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
                child: Center(child: (_isLoading==false) ? const Text('Hapus data?') :  const CustomCircularProgressIndicator()),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // batal button
                  InkWell(
                      onTap: (){Navigator.pop(context);},
                      child: Container(
                          padding: const EdgeInsets.only(top: 14, bottom: 14, left: 47,right: 47),
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(20.0),
                            ),
                          ),
                          child: Text('Batal',style: TextStyle(color: Color(customColorBlue())))
                      )
                  ),
                  InkWell(
                    child: Container(
                        padding: const EdgeInsets.only(top: 14, bottom: 16, left: 51,right: 51),
                        decoration: BoxDecoration(
                          color: Color(customColorRed()),
                          borderRadius: const BorderRadius.only(
                            bottomRight: Radius.circular(20.0),
                          ),
                        ),
                        child: Text('Hapus',style: TextStyle(color: Color(customColorLayoutBackground())))
                    ),
                    onTap: (_isLoading==true) ? (){} : () async {
                      //adjust tinggi layout to avoid overflow
                      setState(() {
                        tinggi+=17;
                      });
                      isLoading(true);
                      //delete database
                      FirebaseDatabase.instance.ref("data/client/${widget.idAccount}/riwayat/${widget.id}").remove()
                          .timeout(const Duration(seconds: 10),
                          onTimeout: (){
                        customAlertDialogUnpage(context, 'Tidak ada Internet!');
                      }).then((value) => customSnackBar(context, "Berhasil dihapus..."));
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
