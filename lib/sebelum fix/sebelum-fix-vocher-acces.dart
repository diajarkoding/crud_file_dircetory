// ignore_for_file: file_names

import 'dart:io';
import 'dart:typed_data';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class AccessPhoneStorage {
  static const _rootAppFolder = 'Voucher Hotspot';
  Directory? _directory;
  File? _file;
  String _fullPathAppRootDir = '';

  // singleton
  AccessPhoneStorage._privateConst();
  static final AccessPhoneStorage instance = AccessPhoneStorage._privateConst();

  factory AccessPhoneStorage() {
    return instance;
  }

  File? docFile() => _file;

  Future<void> _createRootAppDirectory() async {
    var androidInfo = await DeviceInfoPlugin().androidInfo;

    var sdkInt = androidInfo.version.sdkInt;

    try {
      _directory = null;
      if (Platform.isAndroid) {
        if (await _requestPermission(Permission.storage)) {
          _directory = await getExternalStorageDirectory();
        }

        _fullPathAppRootDir = "";
        List<String>? folders = _directory?.path.split("/");

        // mencari nama folder android di internal storage
        for (final folderName in folders!) {
          if (folderName != "") {
            if (folderName != "Android") {
              _fullPathAppRootDir = '$_fullPathAppRootDir/$folderName';
            } else {
              break;
            }
          }
        }

        // buat nama folder aplikasi
        _fullPathAppRootDir = '$_fullPathAppRootDir/$_rootAppFolder';

        // atur nama folder aplikasi sebagai directory
        _directory = Directory(_fullPathAppRootDir);

        if (sdkInt >= 30) {
          // request permission untuk membuat folder
          if (await _requestPermission(Permission.manageExternalStorage)) {
            await _directory!.create(recursive: true);
          }
        } else {
          if (await _requestPermission(Permission.storage)) {
            await _directory!.create(recursive: true);
          }
        }
      }
    } catch (e) {
      debugPrint('Gagal membuat direktori aplikasi: $e');
    }
  }

  // Future<void> createSubDirectory({required String folderName}) async {
  //   try {
  //     // create root app  folder
  //     if (_directory == null ||
  //         (_directory != null && !await _directory!.exists())) {
  //       await _createRootAppDirectory();
  //     }

  //     // request permission untuk membuat folder
  //     if (await _requestPermission(Permission.manageExternalStorage)) {
  //       await Directory('$_fullPathAppRootDir/$folderName')
  //           .create(recursive: true);
  //     }

  //     if (await Directory('$_fullPathAppRootDir/$folderName').exists()) {
  //       debugPrint('Sub direktori sukses dibuat');
  //     } else {
  //       debugPrint('Sub direktori gagal dibuat');
  //     }
  //   } catch (e) {
  //     debugPrint('Gagal membuat sub direktori: $e');
  //   }
  // }

  Future<bool> saveIntoStorage({
    required Uint8List data,
    required String fileName,
  }) async {
    bool result = false;

    try {
      // cek variabel _directory, apakah masih null atau tidak
      // jika masih null, maka setting nama folder aplikasi & buat foldernya
      // jika tidak null tetapi folder aplikasi masih belum ada, maka setting nama folder aplikasi & buat foldernya
      if (_directory == null ||
          (_directory != null && !await _directory!.exists())) {
        await _createRootAppDirectory();
      }

      // save file ke folder aplikasi
      if (await _directory!.exists()) {
        _file = File("${_directory!.path}/$fileName.png");
        // debugPrint(_file?.path);

        // simpan data

        await _file?.writeAsBytes(data); // for pdf, image

        // jika _file tidak null dan _file sudah ada / exists
        if (_file != null && _file!.existsSync()) {
          return true;
        } else {
          return false;
        }
      }
    } catch (e) {
      debugPrint('Gagal menyimpan data: $e');
    }

    return result;
  }

  Future<bool> _requestPermission(Permission permission) async {
    if (await permission.isGranted) {
      return true;
    } else {
      var result = await permission.request();
      if (result.isGranted) {
        return true;
      }

      return false;
    }
  }

  Future<bool> getPermissions() async {
    bool gotPermissions = false;

    var androidInfo = await DeviceInfoPlugin().androidInfo;
    var release =
        androidInfo.version.release; // Version number, example: Android 12
    var sdkInt = androidInfo.version.sdkInt; // SDK, example: 31
    var manufacturer = androidInfo.manufacturer;
    var model = androidInfo.model;

    debugPrint('Android $release (SDK $sdkInt), $manufacturer $model');

    if (Platform.isAndroid) {
      var storage = await Permission.storage.status;

      if (storage != PermissionStatus.granted) {
        await Permission.storage.request();
      }

      if (sdkInt >= 30) {
        var storageExternal = await Permission.manageExternalStorage.status;

        if (storageExternal != PermissionStatus.granted) {
          await Permission.manageExternalStorage.request();
        }

        storageExternal = await Permission.manageExternalStorage.status;

        if (storageExternal == PermissionStatus.granted &&
            storage == PermissionStatus.granted) {
          gotPermissions = true;
        }
      } else {
        // (SDK < 30)
        storage = await Permission.storage.status;

        if (storage == PermissionStatus.granted) {
          gotPermissions = true;
        }
      }
    }

    return gotPermissions;
  }
}
