import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'home.dart';
import 'settings.dart';
import 'agenda.dart';

void main() {
  runApp(const Application());
}

class Application extends StatelessWidget {
  // constructeur
  const Application({Key? key}) : super(key: key);

  static const String _title = 'UUS-App';

  // méthode appelée à la création du composant
  @override
  Widget build(BuildContext context) {
    // On créer un widget "MaterialApp" avec le titre définie plus haut et le composant d'acceuil
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: _title,
      localizationsDelegates: [
        // ... app-specific localization delegate[s] here
        GlobalWidgetsLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('fr'),
        // ... other locales the app supports
      ],
      locale: Locale('fr'),
      home: StatefulApplication(),
    );
  }
}

class StatefulApplication extends StatefulWidget {
  // constructeur
  const StatefulApplication({Key? key}) : super(key: key);

  // On défini l'état du composant
  @override
  State<StatefulApplication> createState() => _StatefulApplication();
}

class _StatefulApplication extends State<StatefulApplication> {
  // variable pour récupérer l'index du widget affichée
  int _selectedIndex = 0;

  // constante pour les options de style des différents textes
  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);

  // liste des widgets affichés
  static const List<Widget> _widgetOptions = <Widget>[
    // Premier widget
    HomeWidget(),
    // Deuxième widget
    AgendaWidget(),
    // Troisième widget
    SettingWidget()
  ];

  /// Fonction appelée lorsqu'on clique sur la barre de navigation
  /// Modifie la variable "_selectedIndex" en fonction de l'élement
  /// sélectionner
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Méthode appelée à la création du widget
  @override
  Widget build(BuildContext context) {
    // On créer un scaffold
    return Scaffold(
      // On récupère le contenu du widget à la position indiquée pour le corp
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      // Bar de navigation en bas de l'écran
      bottomNavigationBar: BottomNavigationBar(
        // Différents élement présent dans la bar de navigation
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Acceuil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Agenda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Paramètres',
          ),
        ],
        // Index du widget actuellement affiché
        currentIndex: _selectedIndex,
        // Couleur du widget actuellement sélectionner
        selectedItemColor: Colors.amber[800],
        // Action lorsqu'on clique sur un élement de la bar de navigation
        onTap: _onItemTapped,
      ),
    );
  }
}
