class BluetoothDeviceInfo {
  final String id;
  final String name;

  BluetoothDeviceInfo({required this.id, required this.name});

  @override
  String toString() {
    return 'Device ID: $id, Device Name: $name';
  }
}
