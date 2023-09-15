import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'menu.dart';
import 'home.dart';
import 'token.dart';

class Transaction extends StatefulWidget {
  const Transaction(
      {Key? key,
      required this.userData,
      required this.email,
      required this.token})
      : super(key: key);
  final String email;
  final Token token;
  final Map<String, dynamic> userData;
  @override
  State<Transaction> createState() => _TransactionState();
}

class _TransactionState extends State<Transaction> {
  int exitcode = 0;
  String message = '';
  int? amount;

  List<String> produit = [];
  List<String> quantite = [];
  List<String> prix = [];
  List<String> date = [];
  List<String> nomServeur = [];
  List<String> prenomServeur = [];

  List<String> montantTransac = [];
  List<String> dateTransac = [];
  List<String> nomServeurTransac = [];
  List<String> prenomServeurTransac = [];
  List<String> moyenTransac = [];

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  //get email value from LoginScreen
  @override
  void initState() {
    super.initState();

    // Nothing is displaying on screen initially, since the items are loaded from API on startup.
    // Preferably in this state, the refresh indicator would be shown while the items load.
    // It's not currently possible in this place, since it seems that the Widget hasn't been built yet.

    _refreshIndicatorKey.currentState
        ?.show(); // currentState null at this time, so the app crashes.
    fetchData(widget.email);
  }

  Future fetchData(String email) async {
    _refreshIndicatorKey.currentState?.show();
    var url = Uri.http('portail.comif.fr', '/comif/api_mobile/get_money.php',
        {'email': email, 'token': widget.token.token});
    //debugPrint('Fetching userData Money');
    var response = await http.get(url);
    //debugPrint('Fetching userData Money Completed');

    final body = response.body;
    final jsonMoney = convert.jsonDecode(body);
    var urlCommands = Uri.http(
        'portail.comif.fr',
        '/comif/api_mobile/get_commands.php',
        {'email': email, 'token': widget.token.token});
    var responseCommands = await http.get(urlCommands);
    final bodycommands = responseCommands.body;
    final jsonCommands = convert.jsonDecode(bodycommands);

    var urlTransactions = Uri.http(
        'portail.comif.fr',
        '/comif/api_mobile/get_transactions.php',
        {'email': email, 'token': widget.token.token});
    var responseTransactions = await http.get(urlTransactions);
    final bodyTransactions = responseTransactions.body;
    final jsonTransactions = convert.jsonDecode(bodyTransactions);
    List<String> produitTemp = [];
    List<String> quantiteTemp = [];
    List<String> prixTemp = [];
    List<String> dateTemp = [];
    List<String> nomTerveurTemp = [];
    List<String> prenomTerveurTemp = [];

// {"id_transaction","id_moyen_de_paiement","id_personne_serveur","id_personne_client","montant_transaction","date_operation","nom_client","prenom_client","nom_serveur","prenom_serveur","moyen_de_paiement"}
    List<String> montantTransacTemp = [];
    List<String> dateTransacTemp = [];
    List<String> nomServeurTransacTemp = [];
    List<String> prenomServeurTransacTemp = [];
    List<String> moyenTransacTemp = [];

    for (var i = 0; i < jsonCommands['nb_datas'] - 1; i++) {
      produitTemp.add(jsonCommands['datas'][i]['nom_produit'].toString());
      quantiteTemp
          .add(jsonCommands['datas'][i]['quantite_commande'].toString());
      prixTemp.add(
          ((double.parse(jsonCommands['datas'][i]['prix_produit']) / 100.0))
              .toStringAsFixed(2));
      dateTemp.add(jsonCommands['datas'][i]['date_commande'].toString());
      nomTerveurTemp.add(jsonCommands['datas'][i]['nom_serveur'].toString());
      prenomTerveurTemp
          .add(jsonCommands['datas'][i]['prenom_serveur'].toString());
      // calculer la somme des commandes avec le prix
      jsonCommands['datas'][i]['quantite_commande'];
    }

    for (var i = 0; i < jsonTransactions['nb_datas'] - 1; i++) {
      dateTransacTemp
          .add(jsonTransactions['datas'][i]['date_operation'].toString());
      moyenTransacTemp
          .add(jsonTransactions['datas'][i]['moyen_de_paiement'].toString());
      montantTransacTemp.add(
          ((double.parse(jsonTransactions['datas'][i]['montant_transaction']) /
                  100.0))
              .toStringAsFixed(2));
      nomServeurTransacTemp
          .add(jsonTransactions['datas'][i]['nom_serveur'].toString());
      prenomServeurTransacTemp
          .add(jsonTransactions['datas'][i]['prenom_serveur'].toString());
    }

    setState(() {
      exitcode = jsonMoney['exitcode'];
      message = jsonMoney['message'];
      amount = int.parse(jsonMoney['amount']);
      // separer les transactions en liste
      produit = produitTemp;
      quantite = quantiteTemp;
      prix = prixTemp;
      date = dateTemp;
      nomServeur = nomTerveurTemp;
      prenomServeur = prenomTerveurTemp;

      montantTransac = montantTransacTemp;
      dateTransac = dateTransacTemp;
      nomServeurTransac = nomServeurTransacTemp;
      prenomServeurTransac = prenomServeurTransacTemp;
      moyenTransac = moyenTransacTemp;
    });
    debugPrint('Fetch userData Money complete');
    debugPrint(email);
    debugPrint('Fetch userData Commands complete');
    if (exitcode == 200) {
      return null;
    } else {
      throw Exception('Request failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return amount == null
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            key: _refreshIndicatorKey,
            onRefresh: () async {
              debugPrint('Refreshing...');
              await fetchData(widget.email);
            },
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 20, top: 12),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 64,
                        height: 64,
                        child: Image.asset('assets/logo_comif.png'),
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Bonjour',
                            style: TextStyle(
                                fontSize: 32,
                                color: Color.fromARGB(255, 92, 1, 31),
                                fontFamily: 'bonbon'),
                          ),
                          Text(
                            '${widget.userData['prenom_personne']} ${widget.userData['nom_personne']}',
                            style: const TextStyle(
                                fontSize: 24,
                                color: Colors.black,
                                fontWeight: FontWeight.w200),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  width: 30,
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 20, top: 5, right: 20, bottom: 20),
                  child: Container(
                    height: 120,
                    decoration: const BoxDecoration(
                      gradient: RadialGradient(colors: [
                        Color.fromARGB(255, 246, 221, 166),
                        Color.fromARGB(255, 250, 200, 93)
                      ], radius: 2),
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Solde de votre compte',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                fontSize: 24),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Text(
                            (amount! / 100).toString() + ('€'),
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: amount! <= 0 ? Colors.red : Colors.black,
                                fontSize: 40),
                          ),
                          if (amount! <= 0)
                            const Text(
                              'Rechargez votre compte',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                const Text(
                  'Historique des commandes',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontSize: 18),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: produit.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Padding(
                        padding:
                            const EdgeInsets.only(left: 20, right: 20, top: 10),
                        child: Container(
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            color: Color.fromARGB(255, 246, 221, 166),
                          ),
                          child: ListTile(
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${quantite[index]} ${produit[index]}',
                                  style: const TextStyle(
                                      fontFamily: 'San Fransisco',
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black),
                                ),
                                Text(
                                  '${(double.parse(prix[index]) * double.parse(quantite[index])).toStringAsFixed(2)}€',
                                  style: const TextStyle(
                                      fontFamily: 'San Fransisco',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                      color: Colors.black),
                                )
                              ],
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${nomServeur[index]} ${prenomServeur[index]}\ndate: ${date[index]}',
                                      style: const TextStyle(
                                          color: Colors.black, fontSize: 14),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            contentPadding: const EdgeInsets.only(
                                left: 18, right: 18, bottom: 12),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                const Text(
                  'Historique des transactions',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontSize: 18),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(
                        bottom: kBottomNavigationBarHeight + 16),
                    itemCount: montantTransac.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Padding(
                        padding:
                            const EdgeInsets.only(left: 20, right: 20, top: 10),
                        child: Container(
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            color: Color.fromARGB(255, 246, 221, 166),
                          ),
                          child: ListTile(
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  moyenTransac[index],
                                  style: const TextStyle(
                                      fontFamily: 'San Fransisco',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.black),
                                ),
                                Text(
                                  '${montantTransac[index]}€',
                                  style: const TextStyle(
                                      fontFamily: 'San Fransisco',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                      color: Colors.black),
                                ),
                              ],
                            ),
                            subtitle: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Effectué par : ${nomServeurTransac[index]} ${prenomServeurTransac[index]}\ndate: ${dateTransac[index]}',
                                  style: const TextStyle(
                                      color: Colors.black, fontSize: 14),
                                ),
                              ],
                            ),
                            contentPadding: const EdgeInsets.only(
                                left: 18, right: 18, bottom: 12),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
  }
}

class TransactionScreen extends StatelessWidget {
  final String email;
  final Token token;
  final Map<String, dynamic> userData;
  const TransactionScreen(
      {Key? key,
      required this.userData,
      required this.email,
      required this.token})
      : super(key: key);

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
        case 2:
          break;
      }
    }

    return MaterialApp(
      title: 'COMIF Mobile App',
      theme: Theme.of(context),
      home: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Scaffold(
          floatingActionButton: BottomNavigationBar(
            items: const [
              BottomNavigationBarItem(
                  icon: Icon(Icons.menu_book), label: 'Menu'),
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.person), label: 'Profil'),
            ],
            currentIndex: 2,
            onTap: (value) => onItemTapped(value),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          appBar: AppBar(
            title: const Text(
              'Profil',
              // style: TextStyle(color: Color.fromARGB(255, 254, 249, 235)),
            ),
            centerTitle: true,
            backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
          ),
          body: Transaction(userData: userData, email: email, token: token),
        ),
      ),
    );
  }
}
