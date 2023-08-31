import 'package:comif_app/login.dart';
import 'package:comif_app/menu.dart';
import 'package:flutter/material.dart';
import 'countdown.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'token.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int exitcode = 0;
  String message = '';
  List<String> noms = [];
  List<String> prenoms = [];
  List<String> totalConsos = [];
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();

    // Nothing is displaying on screen initially, since the items are loaded from API on startup.
    // Preferably in this state, the refresh indicator would be shown while the items load.
    // It's not currently possible in this place, since it seems that the Widget hasn't been built yet.

    _refreshIndicatorKey.currentState
        ?.show(); // currentState null at this time, so the app crashes.
    getBestConsos();
  }

  Future<String?> getBestConsos() async {
    _refreshIndicatorKey.currentState?.show();
    return Future.delayed(const Duration(milliseconds: 2250)).then((_) async {
      var url = Uri.http('localhost:3000', '/comif/api/get_best_consos.php',
          {'home_token': home_token});
      var response = await http.get(url);
      final body = response.body;
      final json = convert.jsonDecode(body);
      setState(() {
        if (json['best_consos'].length == 0) {
          noms = [];
          prenoms = [];
          totalConsos = [];
        } else {
          for (var i = 0; i < 10; i++) {
            noms.add(json['best_consos'][i]['nom_personne'].toString());
            prenoms.add(json['best_consos'][i]['prenom_personne'].toString());
            totalConsos.add((json['best_consos'][i]['total_annee'])
                .toString()
                .padLeft(2, '0'));
          }
        }
        exitcode = json['exitcode'];
      });
      if (exitcode == 403) {
        return 'Request Failed';
      } else if (exitcode == 200) {
        return null;
      } else {
        throw Exception('Request failed');
      }
    });
  }

  DateTime now = DateTime.now();
  @override
  Widget build(BuildContext context) {
    void onItemTapped(int index) {
      switch (index) {
        case 0:
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const MenuScreen()));
          break;

        case 2:
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const LoginScreen()));
          break;
      }
    }

    return RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: () async {
          debugPrint('Refreshing...');
          getBestConsos();
        },
        child: GestureDetector(
            onPanUpdate: (details) {
              // Swiping in right direction.
              if (details.delta.dx > 20) {
                onItemTapped(0);
              }

              // Swiping in left direction.
              if (details.delta.dx < -20) {
                onItemTapped(2);
              }
            },
            child: Scaffold(
              floatingActionButton: BottomNavigationBar(
                items: const [
                  BottomNavigationBarItem(
                      icon: Icon(Icons.menu_book), label: 'Menu'),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.home), label: 'Accueil'),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.person), label: 'Profil'),
                ],
                currentIndex: 1,
                onTap: (value) => onItemTapped(value),
              ),
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.centerDocked,
              appBar: AppBar(
                title: const Text('Accueil'),
                centerTitle: true,
              ),
              body: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 20, top: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              width: 100,
                              height: 100,
                              child: Image.asset('assets/logo_comif.png'),
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                            const Text(
                              'Bonjour',
                              style: TextStyle(
                                  fontSize: 32,
                                  color: Color.fromARGB(255, 92, 1, 31),
                                  fontFamily: 'bonbon'),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 30,
                  ),
                  const Text(
                    'Bienvenue à la ',
                    style: TextStyle(
                        fontSize: 28,
                        color: Color.fromARGB(255, 92, 1, 31),
                        fontWeight: FontWeight.w300,
                        fontFamily: 'bonbon'),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  const Text(
                    'Comif',
                    style: TextStyle(
                        fontSize: 54,
                        color: Color.fromARGB(255, 92, 1, 31),
                        fontWeight: FontWeight.bold,
                        fontFamily: 'bonbon'),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(
                        left: 20, top: 5, right: 20, bottom: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 20,
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'Prochain Tibbar... 🍺',
                            style: TextStyle(
                                fontSize: 48,
                                color: Colors.black,
                                fontFamily: 'HouseScript'),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        CountdownTimer(),
                        SizedBox(
                          height: 20,
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Top 10 consommateurs du mois',
                              style: TextStyle(
                                  fontSize: 48,
                                  color: Colors.black,
                                  fontFamily: 'HouseScript')),
                        ),
                      ],
                    ),
                  ),
                  if (noms.isEmpty)
                    const Expanded(
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.only(
                            bottom: kBottomNavigationBarHeight + 16),
                        itemCount: noms.length,
                        itemBuilder: (BuildContext context, int index) {
                          if (noms.isNotEmpty) {
                            return Padding(
                                padding: const EdgeInsets.only(
                                    left: 20, right: 20, top: 10),
                                child: Container(
                                  decoration: const BoxDecoration(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(10)),
                                      color:
                                          Color.fromARGB(255, 246, 221, 166)),
                                  child: ListTile(
                                    title: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Text(
                                              '${(index + 1)}',
                                              style: const TextStyle(
                                                  fontFamily: 'San Fransisco',
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black),
                                            ),
                                            const SizedBox(
                                              width: 50,
                                            ),
                                            SizedBox(
                                              width: 50,
                                              height: 50,
                                              child: ClipOval(
                                                child: FadeInImage.assetNetwork(
                                                  image:
                                                      'http://localhost:3000/comif/img/pdp_cotisants/${noms[index]}_${prenoms[index]}.png',
                                                  placeholder:
                                                      'assets/logo_comif.png',
                                                  fit: BoxFit.cover,
                                                  imageErrorBuilder: (context,
                                                      error, stackTrace) {
                                                    // En cas d'erreur lors du chargement de l'image réseau, affichez l'image de remplacement
                                                    return Image.asset(
                                                      'assets/logo_comif.png',
                                                      fit: BoxFit.cover,
                                                    );
                                                  },
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 20,
                                            ),
                                            Text(
                                              '${noms[index]} ${prenoms[index]}',
                                              style: const TextStyle(
                                                  fontFamily: 'San Fransisco',
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black),
                                            ),
                                          ],
                                        ),
                                        Text(
                                          '${double.parse(totalConsos[index]).toStringAsFixed(0)}€',
                                          style: const TextStyle(
                                              fontFamily: 'San Fransisco',
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black),
                                        ),
                                      ],
                                    ),
                                  ),
                                ));
                          } else {
                            return const Expanded(
                                child:
                                    Center(child: CircularProgressIndicator()));
                          }
                        },
                      ),
                    )
                ],
              ),
            )));
  }
}
