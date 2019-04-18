import 'package:ep_feedmill/model/user.dart';
import 'package:ep_feedmill/module/bluetooth_module.dart';
import 'package:ep_feedmill/res/key.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesModule {
  static final _instance = SharedPreferencesModule._internal();

  factory SharedPreferencesModule() => _instance;

  SharedPreferencesModule._internal();

  static SharedPreferences _sp;

  Future<SharedPreferences> get sp async {
    if (_sp != null) return _sp;
    _sp = await SharedPreferences.getInstance();
    return _sp;
  }

  saveUser(User user) async {
    final prefs = await sp;
    await prefs.setString(Keys.username, user.username);
    await prefs.setString(Keys.password, user.password);
  }

  Future<User> getUser() async {
    final prefs = await sp;
    final username = prefs.getString(Keys.username);
    final password = prefs.getString(Keys.password);

    if (username == null || password == null) {
      return null;
    }

    return User(username, password);
  }

  clearUser() async {
    final prefs = await sp;
    await prefs.setString(Keys.username, null);
    await prefs.setString(Keys.password, null);
  }

  saveBluetoothPrinter(BluetoothDevice device) async {
    final prefs = await sp;
    await prefs.setString(Keys.bluetoothPrinterName, device.name);
    await prefs.setString(Keys.bluetoothPrinterAddress, device.address);
  }

  Future<BluetoothDevice> getBluetoothPrinter() async {
    final prefs = await sp;
    final name = prefs.getString(Keys.bluetoothPrinterName);
    final address = prefs.getString(Keys.bluetoothPrinterAddress);

    if (name == null || address == null) {
      return null;
    }

    return BluetoothDevice(name, address);
  }

  saveBluetoothWeighing(BluetoothDevice device) async {
    final prefs = await sp;
    await prefs.setString(Keys.bluetoothWeighingName, device.name);
    await prefs.setString(Keys.bluetoothWeighingAddress, device.address);
  }

  Future<BluetoothDevice> getBluetoothWeighing() async {
    final prefs = await sp;
    final name = prefs.getString(Keys.bluetoothWeighingName);
    final address = prefs.getString(Keys.bluetoothWeighingAddress);

    if (name == null || address == null) {
      return null;
    }

    return BluetoothDevice(name, address);
  }

  saveGroupNo(int i) async {
    final prefs = await sp;
    await prefs.setInt(Keys.groupNo, i);
  }

  Future<int> getGroupNo() async {
    final prefs = await sp;
    return prefs.getInt(Keys.groupNo);
  }

  saveBroilerCheck(bool b) async{
    final prefs = await sp;
    await prefs.setBool(Keys.broilerChecked, b);
  }

  Future<bool> getBroilerCheck() async {
    final prefs = await sp;
    return prefs.getBool(Keys.broilerChecked);
  }

  saveBreederCheck(bool b) async{
    final prefs = await sp;
    await prefs.setBool(Keys.breederChecked, b);
  }

  Future<bool> getBreederCheck() async {
    final prefs = await sp;
    return prefs.getBool(Keys.breederChecked);
  }

  saveSwineCheck(bool b) async{
    final prefs = await sp;
    await prefs.setBool(Keys.swineChecked, b);
  }

  Future<bool> getSwineCheck() async {
    final prefs = await sp;
    return prefs.getBool(Keys.swineChecked);
  }
}
