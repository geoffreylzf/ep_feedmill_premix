import 'package:ep_feedmill/bloc/bloc_base.dart';
import 'package:ep_feedmill/model/user.dart';
import 'package:ep_feedmill/module/api_module.dart';
import 'package:ep_feedmill/module/shared_preferences_module.dart';
import 'package:rxdart/rxdart.dart';

class LoginBloc extends BlocBase {
  LoginDelegate _delegate;

  final _isLogin = BehaviorSubject<bool>.seeded(false);

  LoginBloc(LoginDelegate delegate) {
    _delegate = delegate;
  }

  login(String username, String password) async {
    try {
      await ApiModule().login(username, password);
      await SharedPreferencesModule().saveUser(User(username, password));
      _delegate.onSuccess();
    } catch (e) {
      _delegate.onError(e.toString());
    }
  }

  Stream<bool> get isLogin => _isLogin.stream;

  @override
  dispose() {
    _isLogin.close();
  }
}

abstract class LoginDelegate {
  void onSuccess();

  void onError(String message);
}
