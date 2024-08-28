import 'package:flutter/services.dart';

import '../devices/audio_device_info.dart';
import '../utils/utils.dart';

enum AudioRoutingMode { mobile, handsFree }

class AudioDeviceService {
  static const MethodChannel _channel = MethodChannel('samples.flutter.dev/audio');

  static Future<void> setAudioRouteMobile() async {
    try {
      await _channel.invokeMethod('setAudioRouteMobile');
  } on PlatformException catch (e) {
      debugLog("Failed to setAudioRouteMobile: '${e.message}'");
      debugLog("Error details: ${e.details}");
    }
  }
  static Future<void> setAudioRouteESPHFP(String deviceName) async {
    try {
      debugLog("setAudioRouteESPHFP $deviceName");
      await _channel.invokeMethod('setAudioRouteESPHFP', {'deviceName': deviceName});
    } on PlatformException catch (e) {
      debugLog("Failed to set audio route: '${e.message}'");
      debugLog("Error details: ${e.details}");
    }
  }

  static Future<void> setAudioRouteESPStreaming(String deviceName) async {
    try {
      debugLog("setAudioRouteESPStreaming $deviceName");
      _channel.invokeMethod('setAudioRouteESPStreaming', {'deviceName': deviceName});
      await Future.delayed(const Duration(seconds: 2));
    } on PlatformException catch (e) {
      debugLog("Failed to set audio route: '${e.message}'");
      debugLog("Error details: ${e.details}");
    }
  }

  static String getModeString(AudioRoutingMode mode) {
    switch (mode) {
      case AudioRoutingMode.mobile:
        return "Mobile";
      case AudioRoutingMode.handsFree:
        return "Handsfree";
      default:
        throw ArgumentError('Unknown AudioRoutingMode: $mode');
    }
  }
  static Future<List<AudioDevice>> getAllConnectedAudioDevices() async {
    final List<dynamic> devicesJson = await _channel.invokeMethod('getConnectedAudioDevices');
    return devicesJson.map((deviceJson) => AudioDevice.fromJson(Map<String, dynamic>.from(deviceJson))).toList();
  }
  static Future<List<AudioDevice>> getConnectedAudioDevicesByPrefix(String productPrefix) async {
    List<AudioDevice> rslts = [];
    final List<dynamic> devicesJson = await _channel.invokeMethod('getConnectedAudioDevices');
    List<AudioDevice> devices = devicesJson.map((deviceJson) => AudioDevice.fromJson(Map<String, dynamic>.from(deviceJson))).toList();
    for (AudioDevice device in devices) {
      if (device.name.contains(productPrefix)) {
        rslts.add(device);
      }
    }
    return rslts;
  }
  static Future<List<AudioDevice>> getConnectedAudioDevicesByPrefixAndType(String productPrefix, int targetType) async {
    List<AudioDevice> rslts = [];
    final List<dynamic> devicesJson = await _channel.invokeMethod('getConnectedAudioDevices');
    List<AudioDevice> devices = devicesJson.map((deviceJson) => AudioDevice.fromJson(Map<String, dynamic>.from(deviceJson))).toList();
    for (AudioDevice device in devices) {
      if (device.name.contains(productPrefix) && device.type == targetType) {
        rslts.add(device);
      }
    }
    return rslts;
  }
  static Future<bool> isCurrentRouteESPHFP(String deviceName) async {
    try {
      final bool result = await _channel.invokeMethod('isCurrentRouteESPHFP', {'deviceName': deviceName});
      return result;
    } on PlatformException catch (e) {
      print("Failed to check audio routing: '${e.message}'.");
      return false;
    }
  }
}
