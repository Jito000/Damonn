import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../../custom_asset/custom_color.dart';
import '../custom_asset/custom_circular_progress.dart';
import '../custom_asset/show_dialog_error_unPage.dart';
import '../custom_asset/show_snackbar.dart';


class OverviewProses extends StatefulWidget {
  final List<String> titleKey;
  final List<TextEditingController> controller;
  final String nohp;
  final String randomKeyValue;
  const OverviewProses({Key? key, required this.nohp, required this.titleKey, required this.controller, required this.randomKeyValue }) : super(key: key);

  @override
  _OverviewProsesState createState() => _OverviewProsesState();
}

class _OverviewProsesState extends State<OverviewProses> {
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



                      //create new database
                      DatabaseReference ref = FirebaseDatabase.instance.ref("data/riwayat/${widget.nohp}/${widget.randomKeyValue}");
                      await ref.update({
                        widget.titleKey[0]: widget.controller[0].text,
                        widget.titleKey[1]: widget.controller[1].text,
                        widget.titleKey[2]: widget.controller[2].text,
                        widget.titleKey[3]: widget.controller[3].text,
                        widget.titleKey[4]: widget.controller[4].text,
                        'status'          : 'pending',

                        // ignore: void_checks
                      }).timeout(const Duration(seconds: 10),onTimeout: (){
                        return customSnackBar(context, 'Dilanjutkan saat terhubung INTERNET');
                      });
                      //when time reach 10 seconds auto cancel the update process

                      //update the total value in firebase
                      ref = FirebaseDatabase.instance.ref("data/total/${widget.nohp}");
                      try{
                        await ref.update({
                          widget.titleKey[0]: ServerValue.increment(int.parse(widget.controller[0].text)),
                          widget.titleKey[1]: ServerValue.increment(int.parse(widget.controller[1].text)),
                          widget.titleKey[2]: ServerValue.increment(int.parse(widget.controller[2].text)),
                          widget.titleKey[3]: ServerValue.increment(int.parse(widget.controller[3].text)),
                          widget.titleKey[4]: ServerValue.increment(int.parse(widget.controller[4].text))
                          // ignore: void_checks
                        }).whenComplete((){
                          customSnackBar(context, 'Data tersimpan...');
                        });
                      } catch(error){
                        customAlertDialogUnpage(context, 'Error update data');
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
