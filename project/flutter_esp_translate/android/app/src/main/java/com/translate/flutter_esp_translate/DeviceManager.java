package com.translate.flutter_esp_translate;

import static android.content.Context.AUDIO_SERVICE;
import android.content.Context;
import android.media.AudioDeviceCallback;
import android.media.AudioDeviceInfo;
import android.media.AudioFocusRequest;
import android.media.AudioManager;
import android.os.Build;
import android.util.Log;

import androidx.annotation.RequiresApi;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

public class DeviceManager {
    private final AudioManager audioManager;
    private static final String CHANNEL = "samples.flutter.dev/audio";
    private Context context;
    private AudioManager.OnAudioFocusChangeListener audioFocusChangeListener;


    @RequiresApi(Build.VERSION_CODES.S)
    public DeviceManager(Context context) {
        this.context = context;
        this.audioManager = (AudioManager) context.getSystemService(AUDIO_SERVICE);

        // AudioDeviceCallback 설정
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            audioManager.registerAudioDeviceCallback(new AudioDeviceCallback() {
                @Override
                public void onAudioDevicesAdded(AudioDeviceInfo[] addedDevices) {
                    for (AudioDeviceInfo device : addedDevices) {
                        Log.d("AudioDeviceCallback", "Audio device added: " + device.getProductName());
                    }
                }

                @Override
                public void onAudioDevicesRemoved(AudioDeviceInfo[] removedDevices) {
                    for (AudioDeviceInfo device : removedDevices) {
                        Log.d("AudioDeviceCallback", "Audio device removed: " + device.getProductName());
                    }
                }
            }, null);
        }

        // OnCommunicationDeviceChangedListener 설정
        audioManager.addOnCommunicationDeviceChangedListener(Runnable::run, device -> {
            Log.d("DeviceManager", "Communication device changed: " + (device != null ? device.getProductName() : "None"));
//            if(isModeHFP){
//
//                Log.d("DeviceManager", "강제로 유지 시도");
//                audioManager.startBluetoothSco();
//                audioManager.setMode(AudioManager.MODE_IN_COMMUNICATION);
//                audioManager.setSpeakerphoneOn(false); // call AFTER setMode
//            }
        });

        // AudioFocusChangeListener 설정
        audioFocusChangeListener = focusChange -> {
            switch (focusChange) {
                case AudioManager.AUDIOFOCUS_GAIN:
                    Log.d("AudioFocus", "Audio focus gained");
                    break;
                case AudioManager.AUDIOFOCUS_LOSS:
                    Log.d("AudioFocus", "Audio focus lost");
                    break;
                case AudioManager.AUDIOFOCUS_LOSS_TRANSIENT:
                    Log.d("AudioFocus", "Audio focus temporarily lost");
                    break;
                case AudioManager.AUDIOFOCUS_LOSS_TRANSIENT_CAN_DUCK:
                    Log.d("AudioFocus", "Audio focus lost, can duck");
                    break;
            }
        };
        audioManager.requestAudioFocus(new AudioFocusRequest.Builder(AudioManager.AUDIOFOCUS_GAIN)
                .setOnAudioFocusChangeListener(audioFocusChangeListener)
                .build());
    }

    @RequiresApi(Build.VERSION_CODES.S)
    public void configureFlutterEngine(FlutterEngine flutterEngine) {
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL).setMethodCallHandler((call, result) -> {
            switch (call.method) {
                case "setAudioRouteMobile":
                    setAudioRouteMobile();
                    break;
                case "setAudioRouteESPHFP":
                    String hfpDeviceName = call.argument("deviceName");
                    Log.d("AudioRouting", "HFP Device name: " + hfpDeviceName);

                    if (hfpDeviceName != null) {
                        setAudioRouteESPHFP(hfpDeviceName);
                    } else {
                        result.error("ERROR", "받은 핸즈프리 장치 이름이 없습니다.", null);
                    }
                    break;
                case "getConnectedAudioDevices":
                    List<Map<String, Object>> connectedDevices = getConnectedAudioDevices();
                    result.success(connectedDevices);
                    break;
                case "isCurrentRouteESPHFP":
                    String deviceName = call.argument("deviceName");
                    if (deviceName != null) {
                        boolean isCurrentRouteESPHFP = isCurrentRouteESPHFP(deviceName);
                        result.success(isCurrentRouteESPHFP);
                    } else {
                        result.error("ERROR", "Device name is required.", null);
                    }
                    break;
                default:
                    result.notImplemented();
                    break;
            }
        });
    }


    @RequiresApi(Build.VERSION_CODES.S)
    private List<Map<String, Object>> getConnectedAudioDevices() {
        AudioDeviceInfo[] devices = audioManager.getDevices(AudioManager.GET_DEVICES_OUTPUTS);
        List<Map<String, Object>> deviceList = new ArrayList<>();

        for (AudioDeviceInfo device : devices) {
            Map<String, Object> deviceInfo = new HashMap<>();
            deviceInfo.put("name", device.getProductName().toString());
            deviceInfo.put("id", device.getId());
            deviceInfo.put("type", device.getType());
            deviceInfo.put("isSource", device.isSource());
            deviceInfo.put("isSink", device.isSink());
            deviceInfo.put("address", device.getAddress() != null ? device.getAddress() : "N/A");
            deviceInfo.put("channelCounts", device.getChannelCounts());
            deviceInfo.put("sampleRates", device.getSampleRates());
            deviceInfo.put("channelMasks", device.getChannelMasks());

            deviceList.add(deviceInfo);
        }

        return deviceList;
    }

    @RequiresApi(Build.VERSION_CODES.S)
    public boolean setAudioRouteMobile() {
        isModeHFP = false;
        AudioDeviceInfo[] outputDevices = audioManager.getDevices(AudioManager.GET_DEVICES_OUTPUTS);

        for (AudioDeviceInfo device : outputDevices) {
            System.out.println("Device type: " + device.getType() + ", Product name: " + device.getProductName() + ", ID: " + device.getId() + ", Address: " + device.getAddress());
        }
        AudioDeviceInfo selectedDevice = null;
        for (AudioDeviceInfo device : outputDevices) {
            if (device.getType() == AudioDeviceInfo.TYPE_BUILTIN_SPEAKER) { // Example type 7
                selectedDevice = device;
                break;
            }
        }

        if (selectedDevice != null) {
            System.out.println("Attempting to set audio route to built-in speaker: Device ID: " + selectedDevice.getId());
            audioManager.stopBluetoothSco();
            audioManager.setMode(AudioManager.MODE_NORMAL);
            audioManager.setSpeakerphoneOn(true);
            audioManager.setCommunicationDevice(selectedDevice);
            System.out.println("Audio route successfully set to " + selectedDevice.getProductName());
            return true;
        } else {
            System.out.println("Failed to find the mobile device.");
            return false;
        }
    }


    @RequiresApi(Build.VERSION_CODES.S)
    public boolean setAudioRouteESPHFP(String deviceName) {
        isModeHFP = true;
        AudioDeviceInfo[] outputDevices = audioManager.getDevices(AudioManager.GET_DEVICES_OUTPUTS);

        for (AudioDeviceInfo device : outputDevices) {
            System.out.println("Device type: " + device.getType() + ", Product name: " + device.getProductName() + ", ID: " + device.getId() + ", Address: " + device.getAddress());
        }

        AudioDeviceInfo selectedDevice = null;
        for (AudioDeviceInfo device : outputDevices) {
            if (device.getProductName().equals(deviceName) && device.getType() == AudioDeviceInfo.TYPE_BLUETOOTH_SCO) { // Example type 7
                selectedDevice = device;
                break;
            }
        }

        if (selectedDevice != null) {
            System.out.println("Attempting to set audio route to device " + deviceName + ": Device ID: " + selectedDevice.getId());
            audioManager.startBluetoothSco();
            audioManager.setMode(AudioManager.MODE_IN_COMMUNICATION);

            audioManager.setSpeakerphoneOn(false); // call AFTER setMode
            audioManager.setCommunicationDevice(selectedDevice);
            System.out.println("Audio route successfully set to " + selectedDevice.getProductName());
            return true;
        } else {
            System.out.println("Failed to find a type 7 device with model name '" + deviceName + "'.");
            return false;
        }
    }

    @RequiresApi(Build.VERSION_CODES.S)
    private boolean isCurrentRouteESPHFP(String deviceName) {
        AudioManager audioManager = (AudioManager) context.getSystemService(Context.AUDIO_SERVICE);
        AudioDeviceInfo currentDevice = audioManager.getCommunicationDevice();

        if (currentDevice != null && currentDevice.getProductName().equals(deviceName)
                && currentDevice.getType() == AudioDeviceInfo.TYPE_BLUETOOTH_SCO) {
            Log.d("AudioRouting", "Current communication device is ESPHFP: " + deviceName);
            return true;
        } else {
            Log.d("AudioRouting", "Current communication device is not ESPHFP or no device set.");
            return false;
        }
    }

}
