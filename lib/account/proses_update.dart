import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../../custom_asset/custom_color.dart';
import '../custom_asset/custom_circular_progress.dart';
import '../custom_asset/show_snackbar.dart';



class UpdateProses extends StatefulWidget {
  final String titleKey;
  final String controller;
  final String idUser;
  const UpdateProses({Key? key, required this.idUser, required this.titleKey, required this.controller }) : super(key: key);

  @override
  _UpdateProsesState createState() => _UpdateProsesState();
}

class _UpdateProsesState extends State<UpdateProses> {
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

                      isLoading(true);

                      // //create database
                      DatabaseReference ref = FirebaseDatabase.instance.ref("users/${widget.idUser}");
                      await ref.update({
                        widget.titleKey: widget.controller,

                      }).timeout(const Duration(seconds: 15),onTimeout: (){customSnackBar(context, 'Masuk antrian upload...');})
                          .then((value) => customSnackBar(context, 'Berhasil. Memuat data...'));

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
