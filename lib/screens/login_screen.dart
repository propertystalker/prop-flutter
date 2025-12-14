import 'package:flutter/material.dart';
import 'package:myapp/screens/email_login_screen.dart';
import 'package:sign_in_button/sign_in_button.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign In'),
      ),
      body: ListView(
        children: <Widget>[
          SignInButton(
            Buttons.email,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const EmailLoginScreen()),
              );
            },
          ),
          SignInButton(
            Buttons.google,
            onPressed: () {},
          ),
          SignInButton(
            Buttons.googleDark,
            onPressed: () {},
          ),
          SignInButton(
            Buttons.facebook,
            onPressed: () {},
          ),
          SignInButton(
            Buttons.facebookNew,
            onPressed: () {},
          ),
          SignInButton(
            Buttons.gitHub,
            onPressed: () {},
          ),
          SignInButton(
            Buttons.apple,
            onPressed: () {},
          ),
          SignInButton(
            Buttons.appleDark,
            onPressed: () {},
          ),
          SignInButton(
            Buttons.linkedIn,
            onPressed: () {},
          ),
          SignInButton(
            Buttons.pinterest,
            onPressed: () {},
          ),
          SignInButton(
            Buttons.tumblr,
            onPressed: () {},
          ),
          SignInButton(
            Buttons.twitter,
            onPressed: () {},
          ),
          SignInButton(
            Buttons.reddit,
            onPressed: () {},
          ),
          SignInButton(
            Buttons.quora,
            onPressed: () {},
          ),
          SignInButton(
            Buttons.yahoo,
            onPressed: () {},
          ),
          SignInButton(
            Buttons.hotmail,
            onPressed: () {},
          ),
          SignInButton(
            Buttons.xbox,
            onPressed: () {},
          ),
          SignInButton(
            Buttons.microsoft,
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
