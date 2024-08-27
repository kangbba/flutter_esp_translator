package com.translate.flutter_esp_translate;

import android.os.Build;
import android.os.Bundle;
import androidx.annotation.NonNull;
import androidx.annotation.RequiresApi;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity {
    private DeviceManager deviceManager;

    @RequiresApi(api = Build.VERSION_CODES.S)
    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        deviceManager = new DeviceManager(this);
        deviceManager.configureFlutterEngine(flutterEngine);
    }
}
