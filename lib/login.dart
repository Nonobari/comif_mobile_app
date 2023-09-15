import 'dart:async';
import 'dart:convert' as convert;
import 'package:comif_app/menu.dart';
import 'package:comif_app/profile.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'home.dart';
import 'token.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      resizeToAvoidBottomInset: false,
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
      body: const LoginFrame(),
    );
  }
}

class LoginFrame extends StatefulWidget {
  const LoginFrame({Key? key}) : super(key: key);
  @override
  State<LoginFrame> createState() => _LoginFrame();
}

class _LoginFrame extends State<LoginFrame> {
  int exitcode = 0;
  String message = '';
  String email = '';
  bool isLoggingIn = false;
  Map<String, dynamic> userData = {};
  Token token = Token(exp: 0, iat: 0, token: '');
  Duration get loginTime => const Duration(milliseconds: 2250);
  Future<String?> _authUser(String data) {
    return Future.delayed(loginTime).then((_) async {
      var url = Uri.http(
          'portail.comif.fr', '/comif/api_mobile/login.php', {'email': data});
      try {
        var response = await http.get(url).catchError((e) {
          debugPrint('Error: $e');
          throw Exception('Request failed');
        }).timeout(const Duration(seconds: 5), onTimeout: () {
          throw TimeoutException('Request timeout');
        });

        final body = response.body;
        final json = convert.jsonDecode(body);
        setState(() {
          exitcode = json['exitcode'];
          message = json['message'];
          email = data;
          debugPrint('message: $message');
          if (exitcode == 200) {
            debugPrint('Login success');
            token = Token(
                exp: json['token']['exp'],
                iat: json['token']['iat'],
                token: json['token']['id'].toString());
            userData = json['data'];
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

  @override
  void initState() {
    super.initState();
    loadSavedCredentials();
  }

  TextEditingController txtController = TextEditingController();
  bool rememberMe = false;

  void loadSavedCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      txtController.text = prefs.getString('email') ?? '';
      rememberMe = prefs.containsKey('email');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 120,
            height: 120,
            child: Image.asset('assets/logo_comif.png'),
          ),
          const SizedBox(height: 10),
          Text("Comif", style: Theme.of(context).textTheme.displayLarge),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(left: 50.0, right: 50),
            child: Container(
                decoration: BoxDecoration(
                    border: Border.all(
                        color: Theme.of(context).primaryColor, width: 2),
                    color: Theme.of(context).colorScheme.secondary,
                    borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: txtController,
                        style: Theme.of(context).textTheme.labelLarge,
                        autofocus: true,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          prefixIcon: const Icon(Icons.email),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30)),
                          labelText: 'Email',
                          labelStyle: TextStyle(fontSize: 20),
                          hintText: 'prenom.nom@etu.emse.fr',
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: <Widget>[
                          Checkbox(
                            checkColor: Theme.of(context).colorScheme.primary,
                            value: rememberMe,
                            onChanged: (value) {
                              setState(() {
                                rememberMe = value!;
                                debugPrint(rememberMe.toString());
                              });
                            },
                          ),
                          Text('Remember Me'),
                        ],
                      ),
                      TextButton(
                          onPressed: () => {
                                // Inside the onPressed handler of the "Login" button
                                FocusScope.of(context).unfocus(),
                                debugPrint(txtController.text),
                                debugPrint(exitcode.toString()),
                                setState(() {
                                  isLoggingIn = true;
                                }),
                                _authUser(txtController.text).then((value) {
                                  debugPrint(value);
                                  setState(() {
                                    isLoggingIn = false;
                                  });
                                  if (exitcode == 200) {
                                    // Define a custom page route for a smoother transition
                                    Navigator.push(
                                      context,
                                      PageRouteBuilder(
                                        pageBuilder:
                                            (context, animation1, animation2) =>
                                                TransactionScreen(
                                          userData: userData,
                                          email: email,
                                          token: token,
                                        ),
                                        transitionsBuilder: (context,
                                            animation1, animation2, child) {
                                          const begin = Offset(1.0, 0.0);
                                          const end = Offset.zero;
                                          const curve = Curves.easeInOut;
                                          var tween =
                                              Tween(begin: begin, end: end)
                                                  .chain(
                                            CurveTween(curve: curve),
                                          );
                                          var offsetAnimation =
                                              animation1.drive(tween);
                                          return SlideTransition(
                                            position: offsetAnimation,
                                            child: child,
                                          );
                                        },
                                      ),
                                    );

                                    // Save credentials if needed
                                    saveCredentials();
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(message),
                                        backgroundColor: Colors.red,
                                        duration: const Duration(seconds: 2),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  }
                                })
                              },
                          style: TextButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: isLoggingIn
                                ? CircularProgressIndicator(
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                  ) // Show CircularProgressIndicator while logging in
                                : Text(
                                    "Se connecter",
                                    style: Theme.of(context)
                                        .textTheme
                                        .displayMedium,
                                  ),
                          ))
                    ],
                  ),
                )),
          ),
        ],
      ),
    );
  }

  void saveCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (rememberMe) {
      prefs.setString('email', txtController.text);
    } else {
      prefs.remove('email');
    }
  }
}
