import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'dart:async';
import 'dart:convert';

import '../utils/utils.dart';
import '../secrets/secret_device_keys.dart';

class BluetoothDeviceService {



  static Future<BluetoothDevice?> scanPreConnectedBleDevice(String productName) async {
    // Bonded Devices 검색
    List<BluetoothDevice> bondedDevices = await FlutterBluePlus.bondedDevices;
    for (BluetoothDevice device in bondedDevices) {
      if (device.advName.contains(productName)) {
        return device;
      }
    }

    // Connected Devices 검색
    List<BluetoothDevice> connectedDevices = FlutterBluePlus.connectedDevices;
    for (BluetoothDevice device in connectedDevices) {
      if (device.advName.contains(productName)) {
        return device;
      }
    }

    // 일치하는 디바이스를 찾지 못했을 경우
    return null;
  }
  static Future<ScanResult?> scanNearBleDevicesByProductName(String productName, int timeoutSeconds) async {
    Completer<ScanResult?> completer = Completer<ScanResult?>();
    StreamSubscription? scanSubscription;

    // 스캔 시작
    FlutterBluePlus.startScan(timeout: Duration(seconds: timeoutSeconds));
    debugLog('Finding BLE Device Name: ${productName}');
    // 스캔 결과 수신 및 조건 검사
    scanSubscription = FlutterBluePlus.scanResults.listen((List<ScanResult> results) {
      for (var result in results) {
        // 디바이스의 advName이 주어진 productName과 정확히 일치하는지 확인
        debugLog('Found BLE Device Name : ${result.device.advName}');
        if (result.device.advName == productName) {
          debugLog('Found matching device: ${result.device.advName}');
          if (!completer.isCompleted) {
            completer.complete(result);  // 첫 번째 일치하는 디바이스를 찾으면 완료
          }
          break;
        }
      }
    });

    // 지정된 시간 동안 디바이스를 찾지 못하면 null 반환
    Future.delayed(Duration(seconds: timeoutSeconds)).then((_) {
      if (!completer.isCompleted) {
        debugLog('Timeout: No device matched the specified name within the given time.');
        completer.complete(null);
      }
    });

    // 스캔 완료 후 구독 해제 및 스캔 중지
    completer.future.then((_) async {
      await scanSubscription?.cancel();
      FlutterBluePlus.stopScan();
    });

    return completer.future;
  }

  static Future<void> writeMsgToBleDevice(BluetoothDevice? bluetoothDevice, String msg) async {
    if(bluetoothDevice == null){
      debugLog("writeMsgToBleDevice :: device is null");
      return;
    }
    debugLog('${bluetoothDevice.advName}, ${bluetoothDevice.remoteId} 로 메세지 전송중');
    if(!bluetoothDevice.isConnected){
      await bluetoothDevice.connect();
    }
    debugLog('${bluetoothDevice.advName}, ${bluetoothDevice.remoteId} 로 연결시도 완료.');
    try {
      // 연결된 기기를 찾고, 쓰기 특성에 메세지를 씁니다.
      List<BluetoothService> services = await bluetoothDevice.discoverServices();
      for (var service in services) {
        debugLog('Found service: ${service.uuid}');
        for (var characteristic in service.characteristics) {
          debugLog('  Characteristic: ${characteristic.uuid}');
        }
      }
      var targetService = services.firstWhere(
            (service) => service.uuid == SERVICE_UUID,
        orElse: () => throw Exception('Service not found'),
      );
      var targetCharacteristic = targetService.characteristics.firstWhere(
            (characteristic) => characteristic.uuid == CHARACTERISTIC_UUID_RX,
        orElse: () => throw Exception('Characteristic not found'),
      );

      await targetCharacteristic.write(utf8.encode(msg), withoutResponse: false, allowLongWrite: false);
      debugLog('메세지 전송 성공');
    } catch (e) {
      debugLog('Write 실패이유: $e');
    }
  }

  static Future<void> connectToDevice(BluetoothDevice? bluetoothDevice) async{
    if(bluetoothDevice == null){
      debugLog("writeMsgToBleDevice :: device is null");
      return;
    }
    try{
      if(bluetoothDevice.isConnected){
        debugLog("이미 연결 상태입니다");
        return;
      }
      await bluetoothDevice.connect();
    }
    catch(e){
      debugLog(e);
    }
  }

  void stopScan() {
    FlutterBluePlus.stopScan();
  }
}