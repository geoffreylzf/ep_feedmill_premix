package my.com.engpeng.ep_feedmill

import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import app.akexorcist.bluetotohspp.library.BluetoothSPP
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import my.com.engpeng.ep_feedmill.platformHandler.BluetoothMethodHandler
import my.com.engpeng.ep_feedmill.platformHandler.BluetoothReadHandler
import my.com.engpeng.ep_feedmill.platformHandler.BluetoothStatusHandler
import my.com.engpeng.ep_feedmill.platformHandler.BarcodeMethodHandler
import io.flutter.plugins.GeneratedPluginRegistrant;


const val BARCODE_METHOD_CHANNEL = "barcode.epfeedmill.flutter.io/method"
const val BLUETOOTH_METHOD_CHANNEL = "bluetooth.epfeedmill.flutter.io/method"
const val BLUETOOTH_STATUS_CHANNEL = "bluetooth.epfeedmill.flutter.io/status"
const val BLUETOOTH_READ_CHANNEL = "bluetooth.epfeedmill.flutter.io/read"

class MainActivity : FlutterActivity() {

    private val bluetooth = BluetoothSPP(this)

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine);

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, BARCODE_METHOD_CHANNEL)
                .setMethodCallHandler(BarcodeMethodHandler())

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, BLUETOOTH_METHOD_CHANNEL)
                .setMethodCallHandler(BluetoothMethodHandler(bluetooth))

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, BLUETOOTH_STATUS_CHANNEL)
                .setStreamHandler(BluetoothStatusHandler(bluetooth))

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, BLUETOOTH_READ_CHANNEL)
                .setStreamHandler(BluetoothReadHandler(bluetooth))
    }
}
