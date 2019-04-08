import 'package:ep_feedmill/bloc/bloc_base.dart';
import 'package:ep_feedmill/model/user.dart';
import 'package:ep_feedmill/module/api_module.dart';
import 'package:ep_feedmill/module/shared_preferences_module.dart';
import 'package:ep_feedmill/res/string.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rxdart/rxdart.dart';

class LoginBloc extends BlocBase {
  final _googleSignIn = new GoogleSignIn(
    scopes: [
      'email',
    ],
  );
  String _email;
  bool _isGoogleLogin = false;
  LoginDelegate _delegate;

  final _isLogin = BehaviorSubject<bool>.seeded(false);
  final _textGoogleBtn =
      BehaviorSubject<String>.seeded(Strings.msgSignInWithGoogle);

  LoginBloc(LoginDelegate delegate) {
    _delegate = delegate;
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount account) {
      if (account != null) {
        _textGoogleBtn.add("${account.email} (${Strings.signOut})");
        _isGoogleLogin = true;
        _email = account.email;
      } else {
        _textGoogleBtn.add(Strings.msgSignInWithGoogle);
        _isGoogleLogin = false;
        _email = null;
      }
    });
  }

  login(String username, String password) async {
    if (_email == null || _email.isEmpty) {
      _delegate.onError("Please login google account");
    } else {
      try {
        await ApiModule().login(username, password, _email);
        await SharedPreferencesModule().saveUser(User(username, password));
        _delegate.onSuccess();
      } catch (e) {
        _delegate.onError(e.toString());
      }
    }
  }

  onGoogleButtonPressed() {
    if (_isGoogleLogin) {
      _googleSignIn.signOut();
    } else {
      _googleSignIn.signIn();
    }
  }

  Stream<bool> get isLogin => _isLogin.stream;

  Stream<String> get textBtnGoogle => _textGoogleBtn.stream;

  @override
  dispose() {
    _isLogin.close();
    _textGoogleBtn.close();
  }
}

abstract class LoginDelegate {
  void onSuccess();

  void onError(String message);
}
