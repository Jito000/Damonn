
import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../../custom_asset/custom_circular_progress.dart';
import '../../custom_asset/custom_color.dart';
import 'detail_kodi.dart';

class BerandaPage extends StatefulWidget {
  const BerandaPage({Key? key}) : super(key: key);

  @override
  _BerandaPageState createState() => _BerandaPageState();
}

class _BerandaPageState extends State<BerandaPage> {

  final _ref = FirebaseDatabase.instance.ref();

  //check shared preferences value

  final int _jumlahController = 5;
  final List<TextEditingController> _controllerAll = [];
  //card title
  final List<String> _title   =['Tesa', 'Celana','Ami', 'Jumbo', 'Tanggung / ¾'];
  //firebase key so the value same with title above
  final List<String> _titleKey=['tesa', 'celana','ami', 'jumbo', 'tanggung'];

  bool isSwitched = false;


 void changeSwitch(bool value){
   if(value == true){
     setState(() {
       isSwitched = false;
     });
   }
   else if(value == false){
     setState(() {
       isSwitched = true;
     });
   }
 }
  @override
  void initState() {
    for (int i = 1; i <= _jumlahController; i++) {
      _controllerAll.add(TextEditingController());
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
        return Scaffold(
          body: showMode(),
        );
  }

  //------------------- Separator ---------------

  //layout show mode
  Widget showMode(){
    //future builder to get shared preference : nohp
    return StreamBuilder(
      //get nohp value from sharedpreferene
      stream: _ref.child('data/admin/total').onValue,
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData) {
          //show
          return GridView.builder(
              padding: const EdgeInsets.only(top: 24),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: (1 / .75),
              ),
              itemCount: _titleKey.length + 1,
              itemBuilder: (BuildContext contex, int index) {
                //separating widget so can easily read the code
                return itemShowMode(snapshot.data.snapshot, index);
              });
        }
        else{return const Center(child: CustomCircularProgressIndicator());}
      },
    );
  }

  Widget itemShowMode(DataSnapshot snapshot,int index){
    // menyimpan data total yang akan diubah ke kodi
    if(index <= 4) {
      _controllerAll[index].text = snapshot
          .child(_titleKey[index])
          .value
          .toString();
      return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.fromLTRB(36, 6, 0, 0),
              //title card
              child: Text(_title[index], style: TextStyle(
                  fontSize: 14, color: Color(customColorBlack()))),
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
                  snapshot
                      .child(_titleKey[index])
                      .value
                      .toString(),
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
      else{
        return // button switch jumlah
          Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.fromLTRB(36, 6, 0, 0),
                  //title card
                  child: Text("", style:  TextStyle(fontSize: 14,color: Color(customColorBlack()))),
                ),
                Card(
                  color: Color(customColorLayoutBackground()),
                  margin: const EdgeInsets.all(12),
                  elevation: 0,
                  child: Padding(
                      padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12,horizontal: 12),
                        decoration: BoxDecoration(
                          // border: Border.all(width: 1,color: Color(customColorBlue())),
                            color: Color(customColorBlue()),
                            borderRadius: BorderRadius.circular(10)
                        ),
                        child: InkWell(
                          child: const Center(child: Text('Jumlah Kodi',style: TextStyle(color: Colors.white),)),
                          onTap: (){
                            // print(_controllerAll.length);
                            showDetailKodi(context, _controllerAll.asMap());
                          },
                        ),
                      )
                  ),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                )
              ]);
    }

  }

}
