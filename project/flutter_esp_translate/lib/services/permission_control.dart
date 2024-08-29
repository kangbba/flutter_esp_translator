import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../utils/utils.dart';

class PermissionControl {

  static Future<bool> checkAndRequestPermissions() async {
    // 권한 요청
    var status = await [
      Permission.location,
      Permission.microphone,
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
    ].request();

    // 모든 권한이 승인되었는지 확인
    bool allGranted = status.values.every((v) => v == PermissionStatus.granted);

    if (!allGranted) {
      // 자세한 권한 상태 로그 출력
      status.forEach((permission, permissionStatus) {
        if (permissionStatus != PermissionStatus.granted) {
          debugLog("${permission.toString()} 권한이 승인되지 않았습니다.");
        }
      });
    }
    return allGranted;
  }
  // 특정 권한의 상태 확인
  static Future<PermissionStatus> checkPermissionStatus(Permission permission) async {
    return permission.status;
  }

  // 권한 상태에 따른 알림 메시지 표시
  static void showPermissionStatus(BuildContext context, Permission permission) {
    checkPermissionStatus(permission).then((status) {
      String message = '';
      if (status.isGranted) {
        message = '권한이 허용되었습니다.';
      } else if (status.isDenied) {
        message = '권한이 거부되었습니다.';
      } else if (status.isPermanentlyDenied) {
        message = '권한이 영구적으로 거부되었습니다. 설정에서 변경하세요.';
      } else if (status.isLimited) {
        message = '권한이 제한적으로 허용되었습니다.';
      } else {
        message = '알 수 없는 상태입니다.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    });
  }
}
