package my.com.engpeng.ep_feedmill

import android.os.Bundle
import app.akexorcist.bluetotohspp.library.BluetoothSPP
import io.flutter.app.FlutterActivity
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import my.com.engpeng.ep_feedmill.platformHandler.BluetoothMethodHandler
import my.com.engpeng.ep_feedmill.platformHandler.BluetoothReadHandler
import my.com.engpeng.ep_feedmill.platformHandler.BluetoothStatusHandler
import my.com.engpeng.ep_feedmill.platformHandler.QrMethodHandler

const val QR_METHOD_CHANNEL = "qr.epfeedmill.flutter.io/method"
const val BLUETOOTH_METHOD_CHANNEL = "bluetooth.epfeedmill.flutter.io/method"
const val BLUETOOTH_STATUS_CHANNEL = "bluetooth.epfeedmill.flutter.io/status"
const val BLUETOOTH_READ_CHANNEL = "bluetooth.epfeedmill.flutter.io/read"

class MainActivity : FlutterActivity() {

    private val bluetooth = BluetoothSPP(this)

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        GeneratedPluginRegistrant.registerWith(this)

        MethodChannel(flutterView, QR_METHOD_CHANNEL).setMethodCallHandler(QrMethodHandler())

        MethodChannel(flutterView, BLUETOOTH_METHOD_CHANNEL)
                .setMethodCallHandler(BluetoothMethodHandler(bluetooth))

        EventChannel(flutterView, BLUETOOTH_STATUS_CHANNEL)
                .setStreamHandler(BluetoothStatusHandler(bluetooth))

        EventChannel(flutterView, BLUETOOTH_READ_CHANNEL)
                .setStreamHandler(BluetoothReadHandler(bluetooth))


    }
}
