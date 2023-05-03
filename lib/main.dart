import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// main() Funktion sagt Flutter, dass die App definiert in MyApp ausgeführt werden soll
void main() {
  runApp(MyApp());
}

// MyApp Klasse erweitert StatelessWidget.
// Widget sind quasi UI Element woraus du jede Flutter App zusammenbaust.
// Der Code von MyApp setzt die ganze App zusammen.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static const String _title = 'Namer App';

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      // erstellt State und bietet es der gesamten App an
      // Ermöglich jeden Widget den Zustand zu haben.
      create: (context) => MyAppState(), // erstellt App weiten Zustand.
      child: MaterialApp(
          // Titel der App
          title: _title,
          // definiert das Theme der App
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.deepOrange), // Farbschema der App ändern hier
          ),
          // setzt das Home Widget (Der Startpunkt der Anwendung)
          home: Scaffold(
            /*appBar: AppBar(
                title: const Text(_title),
                backgroundColor: Theme.of(context).primaryColor),*/
            body: MyHomePage(),
          )),
    );
  }
}

/*
  MyAppState definiert den Zustand der App
  definiert im Grunde die Daten welches die App benötigt um zu funktionieren
*/
class MyAppState extends ChangeNotifier {
  // erweitert ChangeNotifier, d.h. es kann andere Informieren über Änderungen
  var current = WordPair.random();
  var favorites = <WordPair>[];

  void getNext() {
    current = WordPair.random(); // weist current erneut zu
    notifyListeners(); // notifyListeners() benachrichtigt alle Widgets die MyAppState beabochten
  }

  void toggleFavorite() {
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    notifyListeners();
  }

  void removeFavorite(WordPair favorite) {
    favorites.remove(favorite);
    notifyListeners();
  }
}

// MyHomePage our defined start Widget.
class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  var selectedIndex = 0;

  // Jedes Widget hat eine Build Methode die immer aufgerufen wird, wenn sich das Widget verhändert.
  @override
  Widget build(BuildContext context) {

    Widget page;
    
    switch(selectedIndex) {
      case 0:
        page = GeneratorPage();
        break;
      case 1:
        page = FavoritesPage();
        break;
      default:
        throw UnimplementedError('No widget for $selectedIndex');
    }

    return LayoutBuilder( 
      // LayoutBuilders builder callback wird immer dann  ausgeführt wenn sich die constraints ändern
      // z.B. wenn der User das Fenster skaliert, smartphone rotiert etc.
      builder: (context, constraints) { 
        return Scaffold(
          body: Row(
            children: [
              SafeArea(
                // definiert eine Navigation (Rail = Schiene)
                child: NavigationRail(  // umhüllen mit NavigationRail verhindert dass die Navigation Buttons von der StatusBar umhüllt werden. 
                  extended: constraints.maxWidth >= 600,  // true würde die labels neben Buttons zeigen
                  destinations: [
                    // NavigationsRailDestination definiert einen Eintrag mit Icon und Text in einer Schiene
                    NavigationRailDestination(
                      icon: Icon(Icons.home), 
                      label: Text('Home')
                    ),
                    // Navigations Eintrag für Favouriten.
                    NavigationRailDestination(
                      icon: Icon(Icons.favorite), 
                      label: Text('Favorites'))
                  ],
                  selectedIndex: selectedIndex, // selectIndex sagt welcher Eintrag vorausgewählt ist. 0 für erstes Element
                  // Methode definiert was passieren soll, wenn eine Navigation ausgewählt wurde.
                  onDestinationSelected: (value) {
                      // setState ist ähnlich zu notifyListener es benachrichtigt User wenn Updates erfolgt sind.
                      setState(() {
                        selectedIndex = value;
                      });

                  },
                )
              ),
              Expanded(
                child: Container(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: page,
                ),
              )
            ],
          ),
        );
      }
    );
  }
}

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    if (appState.favorites.isEmpty) {
      return Center(child: Text('No favorites yet.'));
    }

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text('You have ${appState.favorites.length} favorites:'),
        ),
        for(var favorite in appState.favorites) 
          ListTile(
            leading: ElevatedButton(child: Icon(Icons.delete, color: Colors.red), onPressed: () => appState.removeFavorite(favorite)),
            title: Text('$favorite'),
          )
      ],
      
    );
  }
}

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Mithilfe der watch Methode verfolgt MyHomePage Änderungen des aktuellen App Zustandes
    var appState = context.watch<MyAppState>();
    // Extracting current variable to own variable
    var pair = appState.current;
    var favorites = appState.favorites;

    // Definition von Icons
    IconData icon =
        (favorites.contains(pair) ? Icons.favorite : Icons.favorite_border);

    // Jede build Methode muss ein Widget oder ein verschachtelten Baum von Widgets zurückgeben
    // hier verschachtelt, nutzt Scaffold(dt. Getüst) nützliches Widget verwendet in zahlreichen Flutter Apps
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        // Columm  widget nimmt beliebige Anzahl an Kinder Widget und legt sie in eine Spalte von oben nach unten ab.
        children: [
          BigCard(pair: pair),
          SizedBox(
              height:
                  10), // um die beiden Widget mit einem Abstand zu trennen.
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ElevatedButton.icon() Für Buttons mit Icon
              ElevatedButton.icon(
                onPressed: () => appState.toggleFavorite(),
                icon: Icon(icon), // required Icon
                label: Text('Like'), // required Text
              ),
              ElevatedButton(
                  onPressed: () => appState.getNext(), child: Text('Next')),
            ],
          ),
        ],
      ),
    );
   
  }
}

// Eigenes Widget BigCard Stelle markieren -> Rechtklick -> Extract Widget
class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Fragt vom App das Standard Theme an

    // theme.textTheme gibt dir Zugriff auf die Schrift(Font) Theme

    final style = theme.textTheme.displayMedium!.copyWith(
        color: theme.colorScheme.onPrimary,
        backgroundColor: Color(0xFF00FF00),
        fontWeight: FontWeight.bold
        // Viele andere styles möglich. Um mehr zu erfahren hover über FontWeight
        ); // mit copyWith kopiert man displayMedium textStyle und ändert nur die Farbe anders.

    // Gibt Text mit WordPair zurück
    return Card(
      color: theme
          .colorScheme.primary, // Gibt Card das Color vom Theme colorScheme

      // Rechtklick -> wrap with Widget um das ganze vom einem anderen Widget zu umhüllen
      child: Padding(
        // Rechtsklick -> wrap with padding um das Text Element nach außen zu befüllen
        padding: const EdgeInsets.all(20),
        child: Text(
          pair.asLowerCase,
          style:
              style, // Mit dem benannten parameter style kann man einen style
          semanticsLabel:
              "${pair.first} ${pair.second}", // für Screenreader damit die wissen zwei getrennte Wörter
        ),
      ),
    );
  }
}
