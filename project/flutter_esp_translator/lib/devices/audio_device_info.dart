class AudioDevice {
  final String name;
  final int id;
  final int type;
  final bool isSource;
  final bool isSink;
  final String address;
  final List<int> channelCounts;
  final List<int> sampleRates;
  final List<int> channelMasks;

  AudioDevice({
    required this.name,
    required this.id,
    required this.type,
    required this.isSource,
    required this.isSink,
    required this.address,
    required this.channelCounts,
    required this.sampleRates,
    required this.channelMasks,
  });

  factory AudioDevice.fromJson(Map<String, dynamic> json) {
    return AudioDevice(
      name: json['name'],
      id: json['id'],
      type: json['type'],
      isSource: json['isSource'],
      isSink: json['isSink'],
      address: json['address'],
      channelCounts: List<int>.from(json['channelCounts']),
      sampleRates: List<int>.from(json['sampleRates']),
      channelMasks: List<int>.from(json['channelMasks']),
    );
  }

  @override
  String toString() {
    return 'Device Name: $name, Device ID: $id, Type: $type, Is Source: $isSource, '
        'Is Sink: $isSink, Address: $address, Channel Counts: $channelCounts, '
        'Sample Rates: $sampleRates, Channel Masks: $channelMasks';
  }
}
