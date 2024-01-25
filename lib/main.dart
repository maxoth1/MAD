// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}



class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Markenanmeldung',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        appBarTheme: const AppBarTheme(color: Colors.orange),
      ),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/second':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (context) => SecondPage(
                brandName: args['brandName'],
                language: args['language'],
                applicantId: args['applicantId'],
              ),
            );
          case '/third':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (context) => ThirdPage(
                brandName: args['brandName'],
                language: args['language'],
                applicantId: args['applicantId'],
                // Hier wird angenommen, dass die Suchergebnisse als Teil der Argumente übergeben werden
                data: args['data'],
              ),
            );
          case '/fourth':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (context) => FourthPage(
                brandName: args['brandName'],
                applicantId: args['applicantId'],
              ),
            );
          default:
            return MaterialPageRoute(builder: (context) => const MyHomePage());
        }
      },
    );
  }
}


class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(170.0), // Adjust the height as needed
        child: AppBar(
          centerTitle: true,
          titleSpacing: 0,
          title: const SizedBox.shrink(), // Empty space, the real title is in flexibleSpace
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.red, Colors.orange],
              ),
            ),
            child: const SafeArea( // SafeArea is used to keep content within the viewable area
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center, // Center the column for the icon to be below the text
                children: [
                  Text(
                    'Der erste Schritt zur\nEntwicklung ihrer Markenstrategie',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22, // Increase the font size as needed
                      color: Colors.black, // Change the color to black
                    ),
                  ),
                  SizedBox(height: 8), // Add space between the title and the icon
                  Icon(
                    Icons.visibility,
                    size: 80,
                    color: Colors.black,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: const MyForm(),
    );
  }
}


class MyForm extends StatefulWidget {
  const MyForm({Key? key}) : super(key: key);

  @override
  _MyFormState createState() => _MyFormState();
}


class _MyFormState extends State<MyForm> {
  DateTime? startDate;
  String? countrySelection;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _brandNameController = TextEditingController();
  final TextEditingController _strategyController = TextEditingController();
  final TextEditingController _wordmarkController = TextEditingController();

  Future<void> _sendDataToBackend() async {
    if (_nameController.text.isEmpty || _brandNameController.text.isEmpty ||
        _strategyController.text.isEmpty || _wordmarkController.text.isEmpty) {
      // Anzeigen einer Snackbar mit einer Fehlermeldung
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bitte füllen Sie alle Felder aus'),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    String backendUrl = 'https://96ab-mad-vscodeproject.azurewebsites.net/api/applicant';
    String apiKey = 'aQ5g1dR5xCm_CfOLaiflY18btFdrw4ma1-nk8ISeX5-mAzFueMquoA==';
    String language = countrySelection == 'Deutschland' ? 'de' : 'en';

    // Erstellen des Payloads
    Map<String, dynamic> payload = {
      "name": _nameController.text,
      "language": language,
      "brand": {
        "name": _brandNameController.text,
        "strategy": _strategyController.text,
        "wordmark": _wordmarkController.text,
        "date": startDate?.toIso8601String(),
      }
    };

    try {
      final response = await http.post(
        Uri.parse(backendUrl),
        headers: {
          'Content-Type': 'application/json',
          'x-functions-key': apiKey,
        },
        body: json.encode(payload),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        String applicantId = responseData['id'];
        _navigateToNextPage(applicantId);
      } else {
        // Fehlerbehandlung für nicht erfolgreiche Antworten...
      }
    } catch (e) {
      // Fehlerbehandlung für Exceptions...
    }
  }


  void _showChatBotInfo() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Kontakt Info'),
          content: const Text('Hier könnte Ihre Information stehen.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Schließen'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _sendDataAndNavigate() async {
    await _sendDataToBackend();  // Empfangen der applicantId
    } // Weitergabe der applicantId, wenn nicht null


  void _navigateToNextPage(String applicantId) {
    Navigator.pushNamed(
      context,
      '/second',
      arguments: {
        'brandName': _brandNameController.text,
        'language': countrySelection == 'Deutschland' ? 'de' : 'en',
        'applicantId': applicantId,
      },
    );
  }



  void _showInfoDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              child: const Text('Schließen'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showCountryPicker() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Länderauswahl'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                title: const Text('Deutschland'),
                onTap: () {
                  setState(() {
                    countrySelection = 'Deutschland';
                    Navigator.of(context).pop();
                  });
                },
              ),
              ListTile(
                title: const Text('Europa'),
                onTap: () {
                  setState(() {
                    countrySelection = 'Europa';
                    Navigator.of(context).pop();
                  });
                },
              ),
            ],
          ),
        );
      },
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(8.0),
        children: [
          Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  controller: _brandNameController, // Verbindung zum entsprechenden Controller
                  decoration: const InputDecoration(
                    hintText: 'Markennamen',
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.info_outline),
                onPressed: () => _showInfoDialog(
                  'Markennamen',
                  'Bitte geben Sie Ihren Markennamen ein. Dies beinhaltet bevorzugte Form der Groß- und Kleinschreibung für Ihren Markennamen.',
                ),
              ),
            ],
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  controller: _wordmarkController,
                  decoration: const InputDecoration(
                    hintText: 'Wortmarke',
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.info_outline),
                onPressed: () => _showInfoDialog(
                  'Wortmarke',
                  'Bitte geben Sie den Namen Ihrer Marke ein. Info: am besten in Großbuchstaben, damit alle Darstellungsformen abgesichert sind.',
                ),
              ),
            ],
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  controller: _strategyController,
                  decoration: const InputDecoration(
                    hintText: 'Markenstrategie',
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.info_outline),
                onPressed: () => _showInfoDialog(
                  'Markenstrategie',
                  'Beschreiben Sie hier kurz welche Tätigkeiten Sie mit Ihrem Unternehmen/Ihrer Marke ausführen.',
                ),
              ),
            ],
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    hintText: 'Anmelder/in / Inhaber/in',
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.info_outline),
                onPressed: () => _showInfoDialog(
                  'Anmelder/in / Inhaber/in',
                  'Geben Sie hier den Namen der Person ein, die als offizieller Repräsentant für die Anmeldung und Verwaltung der Marke fungiert. Dies umfasst die Verantwortung für die Einhaltung aller rechtlichen Anforderungen und die Vertretung der Marke in allen geschäftlichen Angelegenheiten.',
                ),
              ),
            ],
          ),
          ListTile(
            title: const Text('Länderauswahl'),
            subtitle: Text(countrySelection ?? 'Bitte Land auswählen'),
            onTap: _showCountryPicker,
          ),
          Row(
            children: [
              Expanded(
                child: DateSelector(
                  labelText: 'Startdatum',
                  selectedDate: startDate,
                  onDateSelected: (date) {
                    setState(() {
                      startDate = date;
                    });
                  },
                ),
              ),
              const SizedBox(width: 8.0),
            ],
          ),
        ],
      ),
      floatingActionButton: Stack(
        children: [
          Positioned(
            bottom: 50,
            left: 30,
            child: FloatingActionButton(
              onPressed: _showChatBotInfo,
              backgroundColor: Colors.orange,
              child: const Icon(Icons.message),
            ),
          ),
          Positioned(
            bottom: 50,
            right: 5,
            child: FloatingActionButton(
                onPressed: _sendDataAndNavigate,
              backgroundColor: Colors.orange, // Methode, um zur nächsten Seite zu navigieren
              child: const Icon(Icons.arrow_forward),
    ),
    ),
    ],
    ),
    );
  }
}

class DateSelector extends StatelessWidget {
  final String labelText;
  final DateTime? selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  const DateSelector({
    Key? key,
    required this.labelText,
    this.selectedDate,
    required this.onDateSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: selectedDate ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2101),
        );
        if (picked != null) {
          onDateSelected(picked);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: labelText,
          border: const OutlineInputBorder(),
        ),
        child: Text(
          selectedDate == null ? '' : DateFormat('dd.MM.yyyy').format(selectedDate!),
          style: const TextStyle(fontSize: 16, color: Colors.black87),
        ),
      ),
    );
  }
}

class SecondPage extends StatefulWidget {
  final String brandName;
  final String language;
  final String applicantId;

  const SecondPage({
    Key? key,
    required this.brandName,
    required this.language,
    required this.applicantId, // Add this line
  }) : super(key: key);

  @override
  State<SecondPage> createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  final TextEditingController termController = TextEditingController();

  void _fetchDataAndNavigate(BuildContext context) async {
    String searchTerm = termController.text;
    var data = await fetchGoodsData(widget.language, searchTerm);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ThirdPage(
          brandName: widget.brandName,
          language: widget.language,
          data: data,
          applicantId: widget.applicantId,
        ),
      ),
    );
  }

  Future<List<dynamic>> fetchGoodsData(String language, String searchTerm)
  async {

    String backendUrl = 'https://96ab-mad-vscodeproject.azurewebsites.net/api/good/$language/$searchTerm?code=AB8oFYDurj7iPuH0DPNpm9KcZXHV8w6UJZGNzJ0DerWNAzFu_7-Ogw==';

    try {
      final response = await http.get(
        Uri.parse(backendUrl),
        headers: {'Content-Type': 'application/json'},
      );


      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        // Überprüfen, ob responseData eine Liste oder eine Map ist
        if (responseData is List) {
          return responseData;
        } else if (responseData is Map) {
          return [responseData]; // Einzelne Map in eine Liste umwandeln
        } else {
          throw Exception('Unexpected data format: ${response.body}');
        }
      } else {
        throw Exception('Error fetching data: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

    void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Information'),
          content: const Text('Beispieltext für das Texteingabefeld.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Schließen'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showChatInfo(BuildContext context) {
    // Diese Methode zeigt den Chat-Info-Dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Kontakt Info'),
          content: const Text('Hier könnte Ihre Information stehen.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Schließen'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(170.0), // Set the AppBar height
        child: AppBar(
          centerTitle: true,
          titleSpacing: 0,
          title: const SizedBox.shrink(), // The real title is inside flexibleSpace
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.red, Colors.orange],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Tragen Sie hier alle Arten ein \nmit denen Ihre Firma Umsatz generiert',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22, // Font size
                      color: Colors.black, // Title color
                    ),
                  ),
                  SizedBox(height: 8), // Space between the title and the icon
                  Icon(
                    Icons.laptop_mac, // For a laptop icon
                    size: 100, // Icon size
                    color: Colors.black, // Icon color
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(8.0),
        children: [
          Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  controller: termController,
                  decoration: const InputDecoration(
                    hintText: 'Waren / Dienstleistung',
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.info_outline),
                onPressed: () => _showInfoDialog(context),
              ),
            ],
          ),

        ],
      ),
      floatingActionButton: Stack(
        children: [
          Positioned(
            bottom: 50,
            left: 30,
            child: FloatingActionButton(
              onPressed: () => _showChatInfo(context),
              backgroundColor: Colors.orange,
              child: const Icon(Icons.message),
            ),
          ),
          Positioned(
            bottom: 50,
            right: 5,
            child: FloatingActionButton(
              onPressed: () => _fetchDataAndNavigate(context),
              backgroundColor: Colors.orange,
              child: const Icon(Icons.arrow_forward),
            ),
          ),
        ],
      ),
    );
  }
}

class ThirdPage extends StatelessWidget {
  final String brandName;
  final String language;
  final String applicantId;
  final List<dynamic> data;

  const ThirdPage({Key? key, required this.brandName, required this.language, required this.data, required this.applicantId}) : super(key: key);



  void _showChatInfo(BuildContext context) {
    // Diese Methode zeigt den Chat-Info-Dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Kontakt Info'),
          content: const Text('Hier könnte Ihre Information stehen.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Schließen'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  void _navigateToFourthPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FourthPage(brandName: brandName, applicantId: applicantId,),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    List<dynamic> termsList = data.isNotEmpty ? data[0]['terms'] as List : [];
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(170.0), // Set the AppBar height
        child: AppBar(
          centerTitle: true,
          titleSpacing: 0,
          title: const SizedBox.shrink(), // The real title is inside flexibleSpace
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.red, Colors.orange],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Wählen Sie alle zutreffenden Kategorien aus, die zu Ihrer Marke passen',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22, // Font size
                      color: Colors.black, // Title color
                    ),
                  ),
                  SizedBox(height: 8), // Space between the title and the icon
                  Icon(
                    Icons.list, // Icon for the list
                    size: 100, // Icon size
                    color: Colors.black, // Icon color
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: termsList.isNotEmpty
          ? ListView.builder(
        itemCount: termsList.length,
        itemBuilder: (context, index) {
          var item = termsList[index];
          return ListTile(
            title: Text(item['text'] ?? 'Unbekannter Term'),
            subtitle: Text('Nizza-Klasse: ${item['classNumber'] ?? 'Unbekannt'}'),
          );
        },
      )
          : const Center(
        child: Text('Keine Daten gefunden.'),
      ),
      floatingActionButton: Stack(
        children: [
          Positioned(
            bottom: 50,
            left: 30,
            child: FloatingActionButton(
              heroTag: 'uniqueTag3',
              onPressed: () => _showChatInfo(context),
              backgroundColor: Colors.orange,
              child: const Icon(Icons.message),
            ),
          ),
          Positioned(
            bottom: 50,
            right: 5,
            child: FloatingActionButton(
              onPressed: () => _navigateToFourthPage(context),
              backgroundColor: Colors.orange,
              child: const Icon(Icons.arrow_forward),
            ),
          ),
        ],
      ),
    );
  }
}

class FourthPage extends StatelessWidget {
  final String brandName;
  final String applicantId;

  const FourthPage({
    Key? key,
    required this.brandName,
    required this.applicantId
  }) : super(key: key);

  void _navigateToFifthPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FifthPage(brandName: brandName, applicantId: applicantId,),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.remove_red_eye, size: 100, color: Colors.black),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20.0),
              child: Text(
                'Bereit, Ihre Marke auf mögliche Überschneidungen zu prüfen?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            ElevatedButton(
              onPressed: () => _navigateToFifthPage(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(20),
              ), // Änderung hier
              child: const Icon(Icons.check, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class FifthPage extends StatelessWidget {
  final String brandName;
  final String applicantId;

  const FifthPage({
    Key? key,
    required this.brandName,
    required this.applicantId
  }) : super(key: key);

  Future<List<dynamic>> _fetchTrademarkCollisionData(String brandName, String applicationId) async {
    String backendUrl = 'https://96ab-mad-vscodeproject.azurewebsites.net/api/trademarkCollision/$brandName/$applicationId?code=blH2zo6RHeHFELPTErTllAKKbnLPITfZ-3CxVNM4uITIAzFuDrtL1A==';

    try {
      final response = await http.get(
        Uri.parse(backendUrl),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedData = json.decode(response.body);
        // Check if 'trademarks' is not null before casting
        if (decodedData['trademarks'] != null) {
          // Use List.from to safely convert to a list if it's not null
          return List<Map<String, dynamic>>.from(decodedData['trademarks']);
        } else {
          // Return an empty list if 'trademarks' is null
          return [];
        }
      } else {
        throw Exception('Fehler beim Laden der Daten: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Fehler beim HTTP-Request: $e');
    }
  }





  void _showChatInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Kontakt Info'),
          content: const Text('Hier könnte Ihre Information stehen.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Schließen'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  void _onActionButtonPress(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SixthPage()),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(170.0),
        child: AppBar(
          centerTitle: true,
          titleSpacing: 0,
          title: const SizedBox.shrink(),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.red, Colors.orange],
              ),
            ),
            child: const SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Ihr Kollisions-Check',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22, // Adjust the font size as per your design
                      color: Colors.black, // Color for the title
                    ),
                  ),
                  SizedBox(height: 8), // Space between title and icon
                  Icon(
                    Icons.list, // Icon for the list or any other appropriate icon
                    size: 80,
                    color: Colors.black,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _fetchTrademarkCollisionData(brandName, applicantId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Fehler: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            // Extract the trademarks list from the snapshot data
            List<dynamic> trademarks = snapshot.data!; // This is already the list you need
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Nice Classes')),
                  DataColumn(label: Text('Name')),
                  DataColumn(label: Text('Anmeldedatum')),
                  DataColumn(label: Text('Ablaufdatum')),
                  DataColumn(label: Text('Status')),
                ],
                rows: trademarks.map<DataRow>((trademark) {
                  Map<String, dynamic> trademarkMap = trademark as Map<String, dynamic>;
                  return DataRow(
                    cells: [
                      DataCell(Text((trademarkMap['niceClasses'] as List<dynamic>).join(', '))),
                      DataCell(Text(trademarkMap['wordMarkSpecification']['verbalElement'] ?? '')),
                      DataCell(Text(trademarkMap['applicationDate'] ?? '')),
                      DataCell(Text(trademarkMap['expiryDate'] ?? '-')),
                      DataCell(Text(trademarkMap['status'] ?? '')),
                    ],
                  );
                }).toList(),
              ),
            );
          } else {
            return const Center(child: Text('Keine Daten verfügbar'));
          }
        },
      ),


      floatingActionButton: Stack(
        children: [
          Positioned(
            bottom: 50,
            left: 30,
            child: FloatingActionButton(
              onPressed: () => _showChatInfo(context),
              backgroundColor: Colors.orange,
              child: const Icon(Icons.message),
            ),
          ),
          Positioned(
            bottom: 50,
            right: 5,
            child: FloatingActionButton(
              onPressed: () => _onActionButtonPress(context),
              backgroundColor: Colors.orange,
              child: const Icon(Icons.check),
            ),
          ),
        ],
      ),
    );
  }
}

class SixthPage extends StatelessWidget {
  const SixthPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(170.0),
        child: AppBar(
          centerTitle: true,
          titleSpacing: 0,
          title: const SizedBox.shrink(),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.red, Colors.orange],
              ),
            ),
            child: const SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    ' ',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 8),
                  // Icon removed as per your request
                ],
              ),
            ),
          ),
        ),
      ),
      body: const Center(
        child: Text(
          'Vielen Dank, dass Sie unsere App genutzt haben!',
          style: TextStyle(fontSize: 22),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

