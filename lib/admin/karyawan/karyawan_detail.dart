import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import '../../custom_asset/custom_color.dart';

final List _datadiriKey = ['nama', 'nohp','password','kategori'];
final List _datadiriValue = ['Nama', 'No. HP','Password','Kategori'];

karyawanDetail(BuildContext context, Map<dynamic, dynamic> data){
  return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20))),
          contentPadding: const EdgeInsets.only(top: 48.0),
          content: SizedBox(
            height: 360,
            child: ListView.builder(
                itemCount: _datadiriKey.length,
                itemBuilder: (BuildContext contex, int index) {
                  //separating widget so can easily read the code
                  return itemShowMode(data, index);
                }
            ),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            InkWell(
                borderRadius: BorderRadius.circular(50),
                onTap: (){Navigator.pop(context);},
                child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 96,vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Color(customColorBlue())),
                      borderRadius: const BorderRadius.all(Radius.circular(20.0)),
                    ),
                    child: Text('Tutup',style: TextStyle(color: Color(customColorBlue())))
                )
            ),
          ],
        );
      }

  );
}
Widget itemShowMode(Map<dynamic, dynamic> data,int index){
  return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.fromLTRB(24, 12, 0, 0),
          //title card
          child:  Text(_datadiriValue[index], style:  TextStyle(fontSize: 14,color: Color(customColorPrimaryFont()))),
        ),
        Card(
          color: Color(customColorLayoutBackground()),
          margin: const EdgeInsets.all(12),
          elevation: 0,
          child: Padding(
            padding:
            const EdgeInsets.all(16),
            child: AutoSizeText(
              //value card
              data.entries.elementAt(index).value,
              textAlign: TextAlign.left,
              maxLines: 1,
              style: TextStyle(
                  fontSize: 16, color: Color(customColorGreen())),
            ),
          ),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)),
        )
      ]);
}