package my.com.engpeng.ep_feedmill.platformHandler

import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import my.com.engpeng.ep_feedmill.module.QrModule

class QrMethodHandler : MethodChannel.MethodCallHandler {

    companion object {
        private const val method_getBytes = "getBytes"
        private const val param_text = "text"
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        if (call.method == method_getBytes) {

            val text: String = call.argument(param_text)!!
            val qrCode = QrModule(text).convertToQrByteArray()

            result.success(qrCode)
        } else {
            result.notImplemented()
        }
    }

}