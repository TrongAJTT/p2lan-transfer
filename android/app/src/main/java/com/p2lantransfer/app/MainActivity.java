package dev.trongajtt.p2lan;

import android.Manifest;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.os.Build;
import android.os.Bundle;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "dev.trongajtt.p2lan/screen_sharing";
    private static final String SCREEN_SHARING_SERVICE_CLASS = "dev.trongajtt.p2lan.ScreenSharingService";
    private static final int PERMISSION_REQUEST_CODE = 1001;

    @Override
    public void configureFlutterEngine(FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
            .setMethodCallHandler((call, result) -> {
                if (call.method.equals("startScreenSharingService")) {
                    startScreenSharingService();
                    result.success(null);
                } else if (call.method.equals("stopScreenSharingService")) {
                    stopScreenSharingService();
                    result.success(null);
                } else {
                    result.notImplemented();
                }
            });
    }

    private void startScreenSharingService() {
        // Check if we have the required permission for Android 14+ (API 34+)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            if (ContextCompat.checkSelfPermission(this, 
                    Manifest.permission.FOREGROUND_SERVICE_MEDIA_PROJECTION) 
                    != PackageManager.PERMISSION_GRANTED) {
                // Permission is already declared in manifest, so this should typically be granted automatically
                // But we'll check anyway for safety
                ActivityCompat.requestPermissions(this,
                    new String[]{Manifest.permission.FOREGROUND_SERVICE_MEDIA_PROJECTION},
                    PERMISSION_REQUEST_CODE);
                return;
            }
        }
        
        Intent serviceIntent = new Intent(this, ScreenSharingService.class);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            startForegroundService(serviceIntent);
        } else {
            startService(serviceIntent);
        }
    }

    private void stopScreenSharingService() {
        Intent serviceIntent = new Intent(this, ScreenSharingService.class);
        stopService(serviceIntent);
    }
}
