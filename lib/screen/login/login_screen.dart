import 'package:ep_feedmill/bloc/bloc_base.dart';
import 'package:ep_feedmill/bloc/login_bloc.dart';
import 'package:ep_feedmill/res/route.dart';
import 'package:ep_feedmill/res/string.dart';
import 'package:flutter/material.dart';
import 'package:flutter_auth_buttons/flutter_auth_buttons.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    implements LoginDelegate {
  LoginBloc loginBloc;

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
          return AlertDialog(
            title: Text(Strings.error),
            content: Text(message),
            actions: <Widget>[
              FlatButton(
                child: Text(Strings.close),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LoginBloc>(
      bloc: loginBloc,
      child: Scaffold(
        body: Center(
          child: Stack(
            children: [
              Positioned.fill(
                  child: Opacity(
                      opacity: 0.1,
                      child: Image.asset('images/logo_ep_large.png'))),
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
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: PasswordFormField(_passwordController),
            ),
            Row(
              children: <Widget>[
                Expanded(
                    child: Align(
                        alignment: Alignment.centerLeft,
                        child: GoogleSignInBtn())),
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
      },
    );
  }
}

class GoogleSignInBtn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _loginBloc = BlocProvider.of<LoginBloc>(context);
    return StreamBuilder<String>(
      stream: _loginBloc.textBtnGoogle,
      initialData: Strings.msgSignInWithGoogle,
      builder: (context, snapshot) {
        return GoogleSignInButton(
          darkMode: true,
          onPressed: () {
            _loginBloc.onGoogleButtonPressed();
          },
          text: snapshot.data,
        );
      },
    );
  }
}
