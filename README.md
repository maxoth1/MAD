import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() {
runApp(MyApp());
}

class MyApp extends StatelessWidget {
@override
Widget build(BuildContext context) {
return MaterialApp(
title: 'Flutter Demo',
theme: ThemeData(
primarySwatch: Colors.blue,
appBarTheme: AppBarTheme(
color: Colors.orange,
),
),
// Defining the named routes of the application.
routes: {
'/': (context) => const MyHomePage(),
'/second': (context) => const SecondPage(),
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
preferredSize: const Size.fromHeight(150.0),
child: AppBar(
centerTitle: true,
titleSpacing: 0,
title: const Padding(
padding: EdgeInsets.only(top: 75.0),
child: Text(
'Der erste Schritt zur\nEntwicklung ihrer Markenstrategie',
textAlign: TextAlign.center,
style: TextStyle(fontSize: 18),
),
),
flexibleSpace: const Align(
alignment: Alignment(0, 0.2),
child: Icon(
Icons.visibility,
size: 80,
color: Colors.black,
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
DateTime? endDate;
String? countrySelection;

void _showChatBotInfo() {
showDialog(
context: context,
builder: (BuildContext context) {
return AlertDialog(
title: const Text('Chatbot Info'),
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

void _navigateToNextPage() {
Navigator.pushNamed(context, '/second'); // Navigiert zur zweiten Seite
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
Expanded(
child: DateSelector(
labelText: 'Enddatum',
selectedDate: endDate,
onDateSelected: (date) {
setState(() {
endDate = date;
});
},
),
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
onPressed: _showChatBotInfo,
child: const Icon(Icons.message),
backgroundColor: Colors.orange,
),
),
Positioned(
bottom: 50,
right: 5,
child: FloatingActionButton(
onPressed: _navigateToNextPage, // Methode, um zur nächsten Seite zu navigieren
child: const Icon(Icons.arrow_forward),
backgroundColor: Colors.orange,
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

class SecondPage extends StatelessWidget {
const SecondPage({Key? key}) : super(key: key);

@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(
title: const Text('Seite 2'),
),
body: const Center(
child: Text('Willkommen auf Seite 2! Hier werden die Daten verarbeitet.'),
),
);
}
}