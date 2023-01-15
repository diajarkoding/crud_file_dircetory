import 'dart:io';
import 'dart:typed_data';
import 'package:convert_widget/certificate.dart';
import 'package:convert_widget/sebelum%20fix/sebelum-fix-vocher-acces.dart';
import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';

import 'utils/widget_to_image_controller.dart';
import 'widgets/widget_to_image.dart';

// import 'package:widgets_to_image/widgets_to_image.dart';

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
  WidgetsToImageController controller = WidgetsToImageController();

  ScreenshotController screenshot = ScreenshotController();

  Uint8List? imageFile;

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
              child: Material(color: Colors.transparent, child: cardWidget()),
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
            String fileName = 'voucher';
            await controller.capture().then((Uint8List? image) {
              setState(() {
                imageFile = image;
              });

              debugPrint('Screenshot done');
            }).catchError((onError) {
              debugPrint(onError);
            });

            if (fileName == 'voucher') {
              bool isOk = await AccessPhoneStorage.instance
                  .saveIntoStorage(fileName: fileName, data: imageFile!);
              if (isOk) {
                debugPrint('$fileName berhasil dibuat');
              }
            } else {
              bool isOk = await AccessPhoneStorage.instance
                  .saveIntoStorage(fileName: '$fileName-1', data: imageFile!);
              if (isOk) {
                debugPrint('$fileName-1 berhasil dibuat');
              }
            }
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
