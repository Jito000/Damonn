import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import '../../custom_asset/custom_color.dart';


//card title
final List<String> _title   =['Tesa', 'Celana','Ami', 'Jumbo', 'Tanggung / ¾'];
//firebase key so the value same with title above
final List<String> _titleKey=['tesa', 'celana','ami', 'jumbo', 'tanggung'];

showDetailKodi(BuildContext context, Map<int, TextEditingController> data){
  return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20))),
          contentPadding: const EdgeInsets.only(top: 48.0),
          content: SizedBox(
            height: 360,
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
Widget itemShowMode(Map<int, TextEditingController> data,int index){
  // mengkonversi satuan menjadi kodi
  final double kodi = int.parse(data.entries.elementAt(index).value.text) / 20;
  final double satuan = int.parse(data.entries.elementAt(index).value.text) % 20;

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
            const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
            child: AutoSizeText(
              //value card
              kodi.toInt().toString() + ' Kodi \n' + satuan.toInt().toString() + ' Satuan',
              textAlign: TextAlign.center,
              maxLines: 2,
              style: TextStyle(
                  fontSize: 24, color: Color(customColorGreen())),
            ),
          ),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)),
        )
      ]);
}