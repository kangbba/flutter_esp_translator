package com.example.v3bangawer;

import android.annotation.TargetApi;
import android.bluetooth.BluetoothA2dp;
import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.bluetooth.BluetoothProfile;
import android.content.Context;
import android.content.pm.PackageManager;
import android.media.AudioAttributes;
import android.media.AudioDeviceCallback;
import android.media.AudioDeviceInfo;
import android.media.AudioFormat;
import android.media.AudioManager;
import android.media.MicrophoneInfo;
import android.os.Build;
import android.util.Log;

import androidx.annotation.RequiresApi;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;

import java.io.IOException;
import java.lang.annotation.Target;
import java.lang.reflect.Method;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

public class DeviceManager {
    private final AudioManager audioManager;
    private static final String CHANNEL = "samples.flutter.dev/audio";

    @TargetApi(Build.VERSION_CODES.M)
    public DeviceManager(Context context) {
        this.audioManager = (AudioManager) context.getSystemService(Context.AUDIO_SERVICE);
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
    }

    @TargetApi(Build.VERSION_CODES.M)
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
                default:
                    result.notImplemented();
                    break;
            }
        });
    }


    @TargetApi(Build.VERSION_CODES.P)
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

    @TargetApi(Build.VERSION_CODES.M)
    public boolean setAudioRouteMobile() {
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


}
