import 'dart:async';

import 'package:flutter/services.dart';


const GetBatteryLevel = "GetBatteryLevel";
const GetContactPerm = "GetContactPerm";
const GetWriteExternalStoragePerms = "GetWriteExternalStoragePerms";

class Platform {
  static const _platformChannel = const MethodChannel('samples.flutter.io/platform');

  Future<int> getBatteryLevel() async {
    print(GetBatteryLevel);
    try {
      return await _platformChannel.invokeMethod(GetBatteryLevel);
    } on PlatformException catch (e) {
      print("Error fetching from _platformChannel $e");
      return -1;
    }
  }

  Future<bool> getContactPerms() async {
    print(GetContactPerm);
    try {
      return await _platformChannel.invokeMethod(GetContactPerm);
    } on PlatformException catch (e) {
      print("Error fetching from _platformChannel $e");
      return false;
    }
  }

  Future<bool> getWriteExternalStoragePerms() async {
      print(GetWriteExternalStoragePerms);
      try {
        return await _platformChannel.invokeMethod(GetWriteExternalStoragePerms);
      } on PlatformException catch (e) {
        print("Error fetching from _platformChannel $e");
        return false;
      }
    }
}