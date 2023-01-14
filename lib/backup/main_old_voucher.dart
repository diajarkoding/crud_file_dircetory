import 'dart:io';
import 'dart:typed_data';
import 'package:convert_widget/certificate.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:widgets_to_image/widgets_to_image.dart';

void main() {
  HttpOverrides.global = MyHttpOverrides();
  return runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Widgets To Image',
        theme: ThemeData(primarySwatch: Colors.green),
        home: const MainPage(),
        debugShowCheckedModeBanner: false,
      );
}

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  MainPageState createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  // WidgetsToImageController to access widget
  WidgetsToImageController controller = WidgetsToImageController();
  // to save image bytes of widget
  Uint8List? imageFile;

  Future saveImage(Uint8List bytes) async {
    final appStorage = await getApplicationDocumentsDirectory();
    final file = File('${appStorage.path}/image.png');
    file.create(recursive: true);
  }

  Future saveImage2(Uint8List bytes) async {
    final extDir = await getExternalStorageDirectory();

// Path of file
    final myImagePath = '${extDir!.path}/voucher.png';

// Create directory inside where file will be saved
    await Directory(myImagePath).create();

    final file = File('${extDir.path}/voucher.png');

    debugPrint(file.toString());
  }

  Future saveImage3(Uint8List bytes) async {
    final appStorage = await getExternalStorageDirectory();
    final file = File('${appStorage!.path}/voucher-smn.jpeg');
    file.writeAsBytes(bytes);
    debugPrint(file.path);
  }

  Future saveImage4(Uint8List bytes) async {
    const rootAppFolder = 'test-app';
    String fullPathAppRootDir = '';

    await Permission.storage.request();

    Directory? directory = await getExternalStorageDirectory();
    fullPathAppRootDir = "";
    List<String>? folders = directory?.path.split("/");
    for (final folderName in folders!) {
      if (folderName != "") {
        if (folderName != "Android") {
          fullPathAppRootDir = '$fullPathAppRootDir/$folderName';
        } else {
          break;
        }
      }
    }

    fullPathAppRootDir = '$fullPathAppRootDir/$rootAppFolder';

    directory = Directory(fullPathAppRootDir);

    await directory.create(recursive: true);

    final file = File('${directory.path}/voucher-smn.jpeg');

    file.writeAsBytes(bytes);

    debugPrint(file.path);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Widgets To Image'),
          centerTitle: true,
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              "Widgets",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            WidgetsToImage(
              controller: controller,
              child: cardWidget(),
            ),
            const Text(
              "Images",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            if (imageFile != null) buildImage(imageFile!),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.image_outlined),
          onPressed: () async {
            // String fileName = 'voucher';
            await controller.capture().then((Uint8List? image) {
              setState(() {
                imageFile = image;
              });
              saveImage4(imageFile!);
              debugPrint('Screenshot done');
            }).catchError((onError) {
              debugPrint(onError);
            });

            // if (fileName == 'voucher') {
            //   bool isOk = await AccessPhoneStorage.instance
            //       .saveIntoStorage(fileName: fileName, data: imageFile);
            //   if (isOk) {
            //     debugPrint('$fileName berhasil dibuat');
            //   }
            // } else {
            //   bool isOk = await AccessPhoneStorage.instance
            //       .saveIntoStorage(fileName: '$fileName-1', data: imageFile);
            //   if (isOk) {
            //     debugPrint('$fileName-1 berhasil dibuat');
            //   }
            // }
          },
        ),
      );

  Widget cardWidget() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 4,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(
              left: Radius.circular(16),
            ),
            child: Image.network(
              'https://mhtwyat.com/wp-content/uploads/2022/02/%D8%A7%D8%AC%D9%85%D9%84-%D8%A7%D9%84%D8%B5%D9%88%D8%B1-%D8%B9%D9%86-%D8%A7%D9%84%D8%B1%D8%B3%D9%88%D9%84-%D8%B5%D9%84%D9%89-%D8%A7%D9%84%D9%84%D9%87-%D8%B9%D9%84%D9%8A%D9%87-%D9%88%D8%B3%D9%84%D9%85-1-1.jpg',
              width: 100,
              height: 100,
              fit: BoxFit.cover,
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "voucher",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  "Description",
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget buildImage(Uint8List image) => Image.memory(image);
}
