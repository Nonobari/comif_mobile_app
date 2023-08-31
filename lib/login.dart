import 'dart:async';
import 'dart:convert' as convert;
import 'package:comif_app/menu.dart';
import 'package:crypto/crypto.dart';
import 'package:comif_app/profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:http/http.dart' as http;
import 'home.dart';
import 'token.dart';
import 'package:flutter/services.dart';

class LoginScreen extends StatefulWidget {
  Duration get loginTime => const Duration(milliseconds: 2250);
  const LoginScreen({Key? key}) : super(key: key);
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  int exitcode = 0;
  String message = '';
  String email = '';
  Map<String, dynamic> userData = {};
  Token token = Token(exp: 0, iat: 0, token: '');
  Duration get loginTime => const Duration(milliseconds: 2250);
  Future<String?> _authUser(LoginData data) {
    debugPrint('Name: ${data.name}, Password: ${data.password}');
    return Future.delayed(loginTime).then((_) async {
      var passwordBytes = convert.utf8.encode(data.password);
      String passwordHash = sha256.convert(passwordBytes).toString();
      var url = Uri.http('localhost:3000', '/comif/api/login.php',
          {'email': data.name, 'pwd': passwordHash});
      try {
        debugPrint('requet: $url');
        var response = await http.get(url).catchError((e) {
          debugPrint('Error: $e');
          throw Exception('Request failed');
        }).timeout(const Duration(seconds: 5), onTimeout: () {
          throw TimeoutException('Request timeout');
        });

        final body = response.body;
        final json = convert.jsonDecode(body);
        debugPrint('Response: $json');
        setState(() {
          exitcode = json['exitcode'];
          message = json['message'];
          email = data.name;
          debugPrint('message: $message');
          if (exitcode == 200) {
            debugPrint('Login success');
            token = Token(
                exp: json['token']['exp'],
                iat: json['token']['iat'],
                token: json['token']['id'].toString());
            userData = json['data'];
            debugPrint('token: $token');
          }
        });
        debugPrint('Fetch user complete');
        if (exitcode == 500) {
          return 'Accès refusé, erreur interne';
        } else if (exitcode == 402) {
          return 'Mot de passe incorrect';
        } else if (exitcode == 401) {
          return 'Aucun email correspondant';
        }
      } on TimeoutException catch (e) {
        debugPrint('Timeout: $e');
        return 'Délai de connexion dépassé';
      } on Exception catch (e) {
        debugPrint('Exception: $e');
        return 'Connexion perdue';
      }
    });
  }

  Future<String> _recoverPassword(String name) {
    debugPrint('Name: $name');
    return Future.delayed(loginTime).then((_) {
      //if (!users.containsKey(name)) {
      //return 'User not exists';
      //}
      return '';
    });
  }

  @override
  Widget build(BuildContext context) {
    void onItemTapped(int index) {
      switch (index) {
        case 0:
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const MenuScreen()));
          break;
        case 1:
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const HomeScreen()));
          break;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        centerTitle: true,
      ),
      floatingActionButton: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'Menu'),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
        currentIndex: 2,
        onTap: (value) => onItemTapped(value),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: FlutterLogin(
        logo: "assets/logo_comif.png",
        loginAfterSignUp: false,
        userType: LoginUserType.email,
        messages: LoginMessages(
          flushbarTitleError: 'Erreur',
          loginButton: 'Se connecter',
          signupButton: 'S\'inscrire',
          goBackButton: 'Retour',
          confirmPasswordError: 'Les mots de passe ne correspondent pas',
          recoverPasswordDescription:
              'Un lien de récupération sera envoyé à votre adresse email',
          recoverPasswordIntro: 'Entrez votre email',
          recoverPasswordSuccess: 'Mot de passe récupéré avec succès',
        ),
        theme: LoginTheme(
          // change backgroundColor to lightTheme
          primaryColor: Theme.of(context).colorScheme.secondary,
          titleStyle: Theme.of(context).textTheme.displayLarge,
          textFieldStyle: Theme.of(context).textTheme.bodyMedium,
          bodyStyle: Theme.of(context).textTheme.bodyMedium,
          buttonTheme: const LoginButtonTheme(
            splashColor: Color.fromARGB(255, 0, 0, 0),
            backgroundColor: Color.fromARGB(255, 92, 1, 31),
            highlightColor: Color.fromARGB(255, 92, 1, 31),
            elevation: 9.0,
            highlightElevation: 6.0,
          ),
        ),
        title: 'Comif',
        onLogin: _authUser,
        savedEmail: email,
        hideForgotPasswordButton: true,
        onSubmitAnimationCompleted: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TransactionScreen(
                    userData: userData, email: email, token: token),
              ));
        },
        onRecoverPassword: _recoverPassword,
      ),
    );
  }
}
