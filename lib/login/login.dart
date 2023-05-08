import 'package:flutter/material.dart';

import '../custom_asset/custom_color.dart';
import 'login_proses.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  //Deklarasi key form
  final _formKey = GlobalKey<FormState>();
  //deklarasi shared preference

  final _nomorController = TextEditingController();
  final _passwordController = TextEditingController();


  @override
  void dispose() {
    _nomorController.dispose();
    _passwordController.dispose();
    super.dispose();

  }
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomLeft,
            colors: <Color>[
              //set gradient background color
              Color(customColorGreen()),
              Color(customColorBlue())
            ]
          )
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.only(top: MediaQuery.of(context).size.height/5),  //set login layout height
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                //back button
                Padding(
                  padding: const EdgeInsets.only(bottom: 36),
                    child: Center(child: Text('LOGIN',style: TextStyle(color: Color(customColorBlack()),fontSize: 24,fontWeight: FontWeight.bold)),)),
                //input field
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 36),
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 6), // jarak antar field
                          decoration: BoxDecoration(
                              color: Color(customColorLayoutBackground()),
                              borderRadius: const BorderRadius.all(Radius.circular(20))
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12,),
                            child: TextFormField(
                              controller: _nomorController,
                              keyboardType: TextInputType.number,
                              cursorColor: Color(customColorGreen()),
                              decoration:  const InputDecoration(
                                hintText: 'No Hp',
                                border: InputBorder.none,
                              ),
                              validator: (value){
                                if (value == null || value.isEmpty) {
                                  return 'Tidak boleh kosong';
                                }
                                else if(value.length>12 || value.length<11){
                                  return 'Nomor HP 11-12 angka';
                                }
                                return null;
                              },
                            ),
                          ),
                        ),
                      ),
                      //password
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 36),
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          decoration: BoxDecoration(
                            color: Color(customColorLayoutBackground()),
                            borderRadius: const BorderRadius.all(Radius.circular(20))
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12,),
                            child: TextFormField(
                              controller: _passwordController,
                              obscureText: true,
                              enableSuggestions: false,
                              autocorrect: false,
                              cursorColor: Color(customColorGreen()),
                              decoration:  const InputDecoration(
                                hintText: 'Password',
                                border: InputBorder.none,
                              ),
                              validator: (value){
                                if (value == null || value.isEmpty) {
                                  return 'Tidak boleh kosong';
                                }
                                else if(value.length<5){
                                  return 'Minimal 5 huruf.';
                                }else{
                                  return null;
                                }

                              },
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12,vertical: 12),
                        child: ElevatedButton(
                          style:  ButtonStyle(
                           backgroundColor: MaterialStateProperty.all(Color(customColorLayoutBackground())),
                           shape: MaterialStateProperty.all( const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))))
                          ),
                          child:   Padding(
                            padding: const EdgeInsets.all(6),
                              child: Text('Login',style: TextStyle(color: Color(customColorGreen()),fontSize: 16))),
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              Navigator.of(context).push(
                                PageRouteBuilder(
                                  opaque: false, // set to false
                                  barrierDismissible: true,
                                  barrierColor: Colors.black.withOpacity(0.3),
                                  pageBuilder: (_, __, ___) => ProsesLogin(nomor: _nomorController.text,password: _passwordController.text),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                  ],
                  )
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

}
