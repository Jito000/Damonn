import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../custom_asset/custom_circular_progress.dart';
import '../custom_asset/custom_color.dart';
import '../login/login.dart';



class LogoutProcess extends StatefulWidget {

  const LogoutProcess({Key? key, }) : super(key: key);

  @override
  _LogoutProcessState createState() => _LogoutProcessState();
}

class _LogoutProcessState extends State<LogoutProcess> {
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
                child: Center(child: (_isLoading==false) ? const Text('Yakin ingin keluar?') :  const CustomCircularProgressIndicator()),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  InkWell(
                      onTap: (){Navigator.pop(context);},
                      child: Container(
                          padding: const EdgeInsets.only(top: 14, bottom: 16, left: 50,right: 49),
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
                        child: Text('Keluar',style: TextStyle(color: Color(customColorLayoutBackground())))
                    ),
                    onTap: (_isLoading==true) ? (){} : () async {
                      setState(() {
                        tinggi+=17;
                      });
                      isLoading(true);

                      SharedPreferences preferences = await SharedPreferences.getInstance();
                      preferences.remove('nohp').whenComplete(() {
                        Navigator.of(context).pushAndRemoveUntil(
                            PageRouteBuilder(
                              opaque: false, // set to false
                              barrierDismissible: true,
                              barrierColor: Colors.black.withOpacity(0.3),
                              pageBuilder: (_, __, ___) => const LoginPage(),
                            ), (route) => false
                        );
                      });
                    },
                  ),
                ],
              )
            ],
          )),
    );
  }
}
