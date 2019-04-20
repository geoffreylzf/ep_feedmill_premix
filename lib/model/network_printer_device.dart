import 'dart:io';
import 'dart:typed_data';

class NetworkPrinterDevice {
  Socket socket;
  final String ip;
  final int port;

  NetworkPrinterDevice(this.ip, this.port);

  testPrint() async {
    socket = await Socket.connect(ip, port);

    socket.write("Print from android device \n\n\n\n\n");
    socket.write("Print from android device \n\n\n\n\n");
    socket.write("Print from android device \n\n\n\n\n");
    Future.delayed(Duration(milliseconds: 500));
    socket.add(_cutPaperCommand());

    await socket.close();
    socket.destroy();
  }

  print(Uint8List byteData, String strText) async {
    socket = await Socket.connect(ip, port);

    socket.add(byteData);
    socket.write(strText);
    Future.delayed(Duration(milliseconds: 500));
    socket.add(_cutPaperCommand());

    await socket.close();
    socket.destroy();
  }

  forceCloseSocket() async {
    await socket.close();
    socket.destroy();
  }

  Uint8List _cutPaperCommand() {
    final message = Uint8List(3);
    final byteData = ByteData.view(message.buffer);

    byteData.setUint8(0, 0x1d);
    byteData.setUint8(1, 0x56);
    byteData.setUint8(2, 0x01);
    return message;
  }
}
