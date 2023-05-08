import 'package:flutter/material.dart';

import 'custom_color.dart';

customAlertDialogUnpage(BuildContext context,String message){
  return showDialog(
      context: context,
      builder: (BuildContext context){
        return  AlertDialog(
          contentPadding: const EdgeInsets.only(top: 12),
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20))),
          content: SizedBox(
              height: 200,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 16.0),
                    child: Text('Error!',style: TextStyle(fontSize: 12),),
                  ),
                  const Divider(height: 24,),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 46,horizontal: 12),
                    child: Text(message),
                  ),
                  InkWell(
                    onTap: (){Navigator.pop(context);},
                    child: Container(
                      padding: const EdgeInsets.only(top: 16, bottom: 16),
                      decoration: BoxDecoration(
                        color: Color(customColorBlue()),
                        borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(20.0),
                            bottomRight: Radius.circular(20.0)),
                      ),
                      child: const Center(child: Text('Ulangi',style: TextStyle(color: Colors.white),)),
                    ),
                  ),
                ],
              )),
        );
      });

}