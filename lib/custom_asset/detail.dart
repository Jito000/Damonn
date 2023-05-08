import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'custom_color.dart';


//card title
final List<String> _title   =['Tesa', 'Celana','Ami', 'Jumbo', 'Tanggung / ¾'];
//firebase key so the value same with title above
final List<String> _titleKey=['tesa', 'celana','ami', 'jumbo', 'tanggung'];

String convertTanggal(String date) {
  final DateFormat inputFormat = DateFormat('d MMMM y HH:mm:ss','id');
  final DateFormat displayFormat = DateFormat('d MMMM y','id');
  final DateTime displayDate = inputFormat.parse(date);
  final String formatted = displayFormat.format(displayDate);
  return formatted;
}
String convertJam(String date) {
  final DateFormat inputFormat = DateFormat('d MMMM y HH:mm:ss','id');
  final DateFormat displayFormat = DateFormat('Hm');
  final DateTime displayDate = inputFormat.parse(date);
  final String formatted = displayFormat.format(displayDate);
  return formatted;
}
showCustomDetail(BuildContext context, MapEntry<dynamic, dynamic> data){
  return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20))),
          //title / heading
          titlePadding: EdgeInsets.zero,
          title: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Color(customColorBlue()),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20))
            ),

            child: Column(
              children: [
                Text(convertTanggal(data.key),style: const TextStyle(fontSize: 16,color: Colors.white)),
                Text('Pukul ${convertJam(data.key)}',style: const TextStyle(fontSize: 12,color: Colors.white)),
              ],
            ),
          ),
          //body section
          contentPadding: const EdgeInsets.only(top: 12.0,),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Status',style: TextStyle(fontSize: 14,color: Color(customColorAccentFont()))),
              Text(data.value['status'],style: const TextStyle(fontSize: 16,fontWeight: FontWeight.bold)),
              const Divider(),
              SizedBox(
                height: 320,
                child: GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: (1 / .75),
                        ),
                        itemCount: _titleKey.length,
                        itemBuilder: (BuildContext contex, int index) {
                          //separating widget so can easily read the code
                          return itemShowMode(data, index);
                        }
                ),
              ),
            ],
          ),
          // bottom section
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            Column(
              children: [
                const Divider(),
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
            ),
          ],
        );
      }

  );
}
Widget itemShowMode(MapEntry<dynamic, dynamic> data,int index){

  return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.fromLTRB(36, 0, 0, 0),
          //title card
          child:  Text(_title[index], style:  TextStyle(fontSize: 14,color: Color(customColorPrimaryFont()))),
        ),
        Card(
          color: Color(customColorLayoutBackground()),
          margin: const EdgeInsets.all(12),
          elevation: 0,
          child: Padding(
            padding:
            const EdgeInsets.symmetric(horizontal: 30, vertical: 17),
            child: AutoSizeText(
              //value card
              data.value[_titleKey[index]],
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