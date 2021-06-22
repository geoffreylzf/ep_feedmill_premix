import 'package:ep_feedmill/bloc/bloc_base.dart';
import 'package:ep_feedmill/bloc/local_bloc.dart';
import 'package:ep_feedmill/screen/login/login_bloc.dart';
import 'package:ep_feedmill/res/route.dart';
import 'package:ep_feedmill/res/string.dart';
import 'package:ep_feedmill/widget/local_check_box.dart';
import 'package:ep_feedmill/widget/simple_alert_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_auth_buttons/flutter_auth_buttons.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> implements LoginDelegate {
  LoginBloc loginBloc;
  LocalBloc localBloc = LocalBloc();

  @override
  void initState() {
    super.initState();
    loginBloc = LoginBloc(this);
  }

  @override
  void onSuccess() {
    Navigator.pushReplacementNamed(context, Routes.home);
  }

  @override
  void onError(String message) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleAlertDialog(
            title: Strings.error,
            message: message,
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProviderTree(
      blocProviders: [
        BlocProvider<LoginBloc>(bloc: loginBloc),
        BlocProvider<LocalBloc>(bloc: localBloc),
      ],
      child: Scaffold(
        body: Center(
          child: Stack(
            children: [
              Positioned.fill(
                child: Opacity(
                  opacity: 0.1,
                  child: Image.asset('assets/images/logo_ep_large.png'),
                ),
              ),
              LoginForm(),
            ],
          ),
        ),
      ),
    );
  }
}

class LoginForm extends StatefulWidget {
  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();

  final _usernameController = TextEditingController();

  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final loginBloc = BlocProvider.of<LoginBloc>(context);
    final localBloc = BlocProvider.of<LocalBloc>(context);
    return Form(
      key: _formKey,
      child: Container(
        margin: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                    border: OutlineInputBorder(), labelText: Strings.username),
                validator: (value) {
                  if (value.isEmpty) {
                    return Strings.msgPleaseEnterUsername;
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: PasswordFormField(_passwordController),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                LocalCheckBox(localBloc: localBloc),
                RaisedButton(
                    child: Text(Strings.login.toUpperCase()),
                    onPressed: () {
                      if (_formKey.currentState.validate()) {
                        loginBloc.login(
                            _usernameController.text, _passwordController.text);
                      }
                    }),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class PasswordFormField extends StatefulWidget {
  final passwordController;

  PasswordFormField(this.passwordController);

  @override
  _PasswordFormFieldState createState() => _PasswordFormFieldState();
}

class _PasswordFormFieldState extends State<PasswordFormField> {
  var _visible = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.passwordController,
      obscureText: _visible,
      decoration: InputDecoration(
          border: OutlineInputBorder(),
          labelText: Strings.password,
          suffixIcon: IconButton(
              icon: Icon(_visible ? Icons.visibility_off : Icons.visibility),
              onPressed: () {
                setState(() {
                  _visible = !_visible;
                });
              })),
      validator: (value) {
        if (value.isEmpty) {
          return Strings.msgPleaseEnterPassword;
        }
        return null;
      },
    );
  }
}
