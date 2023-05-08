
import 'dart:io' show Directory, File;

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';

import '../custom_asset/custom_circular_progress.dart';
import '../custom_asset/custom_color.dart';
import '../custom_asset/show_snackbar.dart';
import 'item_list.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({
    Key? key,
  }) : super(key: key);

  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final storage = FirebaseStorage.instance.ref();
  //get file in memory
  final _localFile = File('/storage/emulated/0/Android/data/com.example.damonn/files/avatar/users/user.jpg');
  late final localDirectory ;


  getLocalPath() async {
    localDirectory = await getApplicationDocumentsDirectory();
  }
  @override
    void initState() {
      getLocalPath();
      super.initState();
    }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
          child: Stack(
            alignment: AlignmentDirectional.topCenter,
            clipBehavior: Clip.antiAliasWithSaveLayer,
            children: [
              //background layout
              Container(
                height: 236 ,
                width: MediaQuery.of(context).size.width,
                // decoration: BoxDecoration(
                //   color: Color(customColorGreen()),
                //   borderRadius: const BorderRadius.vertical(bottom: Radius.circular(50))
                // ),
                decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(50)),
                    gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomLeft,
                        colors: <Color>[
                          Color(customColorGreen()),
                          Color(customColorBlue())
                        ]
                    )
                ),
              ),
              Column(
                children: [
                  AppBar(
                    elevation: 0,
                    backgroundColor: Colors.transparent,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 36),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.all(Radius.circular(20)),
                        color: Color(customColorWhite()),
                        boxShadow: const <BoxShadow>[
                          BoxShadow(
                            color: Colors.black54,
                            blurRadius: 3,
                            offset: Offset(0, 2), // 0 is right 3 is bottom
                          )
                        ],
                        image: DecorationImage(
                            fit: BoxFit.cover,
                            image:
                            AssetImage('assets/images/avatar_male.jpg')
                        ),
                      ),
                    ),
                    // child: StreamBuilder(
                    //   // check is file exist
                    //     stream: _localFile.exists().asStream(),
                    //     builder: (BuildContext context, AsyncSnapshot<bool> snapshot){
                    //       if(snapshot.data == false ){
                    //         return StreamBuilder(
                    //             stream: storage.child('wallpaper.jpg').getDownloadURL().asStream(),
                    //             builder: (BuildContext context, AsyncSnapshot<String> imageUrl) {
                    //
                    //               // try {
                    //               // final localDirectory = getApplicationDocumentsDirectory();
                    //               // print(localDirectory.path);
                    //               // print(imageUrl.data.toString());
                    //               // final taskId = FlutterDownloader.enqueue(
                    //               //   url: imageUrl.data.toString(),
                    //               //   fileName: 'user.jpg',
                    //               //   savedDir: localDirectory.path,
                    //               //   showNotification: true, // show download progress in status bar (for Android)
                    //               //   openFileFromNotification: false, // click on notification to open downloaded file (for Android)
                    //               // );
                    //               //   //download image from firebase url
                    //               //   ImageDownloader.downloadImage(
                    //               //     snapshot1.data.toString(),
                    //               //     destination: AndroidDestinationType.custom(
                    //               //         directory: 'avatar')
                    //               //       ..inExternalFilesDir()
                    //               //       ..subDirectory("users/user.jpg"),
                    //               //     // save  to android/com.damon.../avatar/users with name file user.jpg
                    //               //   ).then((value){
                    //               //     customSnackBar(context,'Download berhasil...');});
                    //               // } on PlatformException catch (error){
                    //               //   return Center(child: Text(error.message.toString()));
                    //               // }
                    //               return avatar('downloading');
                    //             });
                    //       }
                    //       else if(snapshot.data == true){
                    //         return avatar('success');
                    //       }
                    //       else {
                    //         return avatar('Gagal memuat data');
                    //       }
                    //     }
                    // ),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: ItemList(),
                  ),
                ],
              ),
            ],
          ),
        ),

    );
  }
  Widget avatar(String status){
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      width: 200,
      height: 200,
      decoration: status == 'downloading' ?
        const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(20)),
          color: Colors.white,
        ):
        BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(20)),
          color: Color(customColorWhite()),
          boxShadow: const <BoxShadow>[
            BoxShadow(
              color: Colors.black54,
              blurRadius: 2,
              offset: Offset(0, 2), // 0 is right 3 is bottom
            )
          ],
          image: DecorationImage(
            fit: BoxFit.cover,
            image:
            FileImage(_localFile)
          ),
        ),
      child: status == 'downloading' ?
        const CustomCircularProgressIndicator():
        Text(status == 'success' ? '' : status)
      ,
    );
  }
}
