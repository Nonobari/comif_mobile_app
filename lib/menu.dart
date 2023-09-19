import 'package:comif_app/home.dart';
import 'package:comif_app/login.dart';
import 'package:comif_app/token.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert' as convert;
import 'token.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({Key? key}) : super(key: key);
  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class Product {
  final String name;
  final int idCategorie;
  final String categorie;
  final String price;

  Product({
    required this.name,
    required this.idCategorie,
    required this.categorie,
    required this.price,
  });
}

class _MenuScreenState extends State<MenuScreen> {
  DateTime now = DateTime.now();
  int buttonSelected = 0;
  List<int> categoriesGeneral = [1, 2, 3, 4, 5, 6, 7, 9, 11, 12, 14];
  List<int> categoriesTitpause = [2, 3, 4, 9];
  List<int> categoriesTibbar = [1, 3, 5, 6, 11, 12];
  Map<String, dynamic> jsonData = {};
  List<Product> listGeneral = [];
  List<Product> listTitpause = [];
  List<Product> listTibbar = [];

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  //get email value from LoginScreen
  @override
  void initState() {
    super.initState();

    // Nothing is displaying on screen initially, since the items are loaded from api_mobile on startup.
    // Preferably in this state, the refresh indicator would be shown while the items load.
    // It's not currently possible in this place, since it seems that the Widget hasn't been built yet.

    _refreshIndicatorKey.currentState
        ?.show(); // currentState null at this time, so the app crashes.
    fetchMenus();
  }

  Future fetchMenus() async {
    _refreshIndicatorKey.currentState?.show();
    var url = Uri.http('portail.comif.fr', '/comif/api_mobile/get_menu.php',
        {'home_token': home_token});
    //debugPrint('Fetching userData Money');
    var response = await http.get(url);

    final body = response.body;
    final jsonData = convert.jsonDecode(body);
    debugPrint(jsonData.toString());
    for (var i = 0; i < jsonData['nb_datas']; i++) {
      if (categoriesGeneral
          .contains(int.parse(jsonData['datas'][i]['id_categorie']))) {
        listGeneral.add(Product(
            name: jsonData['datas'][i]['nom_produit'],
            idCategorie: int.parse(jsonData['datas'][i]['id_categorie']),
            categorie: jsonData['datas'][i]['nom_categorie'],
            price: (double.parse(jsonData['datas'][i]['prix_produit']) / 100)
                .toStringAsFixed(2)));
      }
      if (categoriesTibbar
          .contains(int.parse(jsonData['datas'][i]['id_categorie']))) {
        listTibbar.add(Product(
            name: jsonData['datas'][i]['nom_produit'],
            idCategorie: int.parse(jsonData['datas'][i]['id_categorie']),
            categorie: jsonData['datas'][i]['nom_categorie'],
            price: (double.parse(jsonData['datas'][i]['prix_produit']) / 100)
                .toStringAsFixed(2)));
      }
      if (categoriesTitpause
          .contains(int.parse(jsonData['datas'][i]['id_categorie']))) {
        listTitpause.add(Product(
            name: jsonData['datas'][i]['nom_produit'],
            idCategorie: int.parse(jsonData['datas'][i]['id_categorie']),
            categorie: jsonData['datas'][i]['nom_categorie'],
            price: (double.parse(jsonData['datas'][i]['prix_produit']) / 100)
                .toStringAsFixed(2)));
      }
    }
    setState(() {
      listGeneral = listGeneral;
      listTibbar = listTibbar;
      listTitpause = listTitpause;
    });
  }

  @override
  Widget build(BuildContext context) {
    void onItemTapped(int index) {
      switch (index) {
        case 1:
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const HomeScreen()));
          break;
        case 2:
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const LoginScreen()));
          break;
      }
    }

    return Scaffold(
      floatingActionButton: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'Menu'),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
        currentIndex: 0,
        onTap: (value) => onItemTapped(value),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      appBar: AppBar(
        title: const Text('Menu'),
        centerTitle: true,
      ),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.only(left: 20, top: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 64,
                    height: 64,
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
        Text('Notre carte', style: Theme.of(context).textTheme.displayLarge),
        Text('Produits sélectionnés avec coeur par la COMIF',
            style: Theme.of(context).textTheme.headlineSmall),
        Padding(
          padding: const EdgeInsets.only(left: 25, top: 5, right: 25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                height: 20,
              ),
              Container(
                alignment: Alignment.center,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Theme.of(context).colorScheme.primary,
                ),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      TextButton(
                        onPressed: () {
                          setState(() {
                            buttonSelected = 0;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: buttonSelected == 0
                                ? Theme.of(context).colorScheme.secondary
                                : Theme.of(context).colorScheme.primary,
                          ),
                          child: Text(
                            'GÉNÉRAL',
                            style: TextStyle(
                                fontSize: 24,
                                fontFamily: 'HouseScript',
                                color: buttonSelected == 0
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context).colorScheme.secondary),
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            buttonSelected = 1;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: buttonSelected == 1
                                ? Theme.of(context).colorScheme.secondary
                                : Theme.of(context).colorScheme.primary,
                          ),
                          child: Text(
                            "TITPAUSE",
                            style: TextStyle(
                                fontSize: 24,
                                fontFamily: 'HouseScript',
                                color: buttonSelected == 1
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context).colorScheme.secondary),
                          ),
                        ),
                      ),
                      TextButton(
                          onPressed: () {
                            setState(() {
                              buttonSelected = 2;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: buttonSelected == 2
                                  ? Theme.of(context).colorScheme.secondary
                                  : Theme.of(context).colorScheme.primary,
                            ),
                            child: Text(
                              "TIBBAR",
                              style: TextStyle(
                                  fontSize: 24,
                                  fontFamily: 'HouseScript',
                                  color: buttonSelected == 2
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context)
                                          .colorScheme
                                          .secondary),
                            ),
                          )),
                    ]),
              ),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 40, left: 40),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
              ),
              child: ListView.builder(
                padding: const EdgeInsets.only(
                    bottom: kBottomNavigationBarHeight + 16),
                itemCount: buttonSelected == 0
                    ? listGeneral.length
                    : buttonSelected == 1
                        ? listTitpause.length
                        : listTibbar.length,
                itemBuilder: (BuildContext context, int index) {
                  if (buttonSelected == 0) {
                    // ajouter condition pour afficher le nom de la catégorie: si index == 0 ou si idCategorie != idCategorie[index-1]
                    if (index == 0 ||
                        listGeneral[index].idCategorie !=
                            listGeneral[index - 1].idCategorie) {
                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              // take all the place
                              alignment: Alignment.center,
                              width: double.infinity,
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                listGeneral[index].categorie,
                                style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                    fontFamily: 'HouseScript',
                                    fontSize: 32),
                              ),
                            ),
                          ),
                          ListTile(
                            title: Text(
                              listGeneral[index].name,
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            trailing: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '${listGeneral[index].price} €',
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary),
                                )),
                          ),
                        ],
                      );
                    }
                    return ListTile(
                      title: Text(
                        listGeneral[index].name,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      trailing: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${listGeneral[index].price} €',
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.secondary),
                          )),
                    );
                  } else if (buttonSelected == 1) {
                    // ajouter condition pour afficher le nom de la catégorie: si index == 0 ou si idCategorie != idCategorie[index-1]
                    if (index == 0 ||
                        listTitpause[index].idCategorie !=
                            listTitpause[index - 1].idCategorie) {
                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              // take all the place
                              alignment: Alignment.center,
                              width: double.infinity,
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                listTitpause[index].categorie,
                                style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                    fontFamily: 'HouseScript',
                                    fontSize: 32),
                              ),
                            ),
                          ),
                          ListTile(
                            title: Text(
                              listTitpause[index].name,
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            trailing: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '${listTitpause[index].price} €',
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary),
                                )),
                          ),
                        ],
                      );
                    }
                    return ListTile(
                      title: Text(
                        listTitpause[index].name,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      trailing: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${listTitpause[index].price} €',
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.secondary),
                          )),
                    );
                  } else {
                    // ajouter condition pour afficher le nom de la catégorie: si index == 0 ou si idCategorie != idCategorie[index-1]
                    if (index == 0 ||
                        listTibbar[index].idCategorie !=
                            listTibbar[index - 1].idCategorie) {
                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              // take all the place
                              alignment: Alignment.center,
                              width: double.infinity,
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                listTibbar[index].categorie,
                                style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                    fontFamily: 'HouseScript',
                                    fontSize: 32),
                              ),
                            ),
                          ),
                          ListTile(
                            title: Text(
                              listTibbar[index].name,
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            trailing: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '${listTibbar[index].price} €',
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary),
                                )),
                          ),
                        ],
                      );
                    }
                    return ListTile(
                      title: Text(
                        listTibbar[index].name,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      trailing: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${listTibbar[index].price} €',
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.secondary),
                          )),
                    );
                  }
                },
              ),
            ),
          ),
        ),
      ]),
    );
  }
}
