import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main(){
  HttpOverrides.global = new MyHttpOverrides();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({key});

  static const appTitle = 'Protfi';

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: appTitle,
      home: MyHomePage(title: appTitle),
    );
  }
}

Future<Stock> getDailyOpenClose() async {
  final response = await http.get(Uri.parse('https://localhost:7104/api/stock/GetDailyOpenClose/GOOGL'));
  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    var result = Stock.fromJson(jsonDecode(response.body));
    return result;
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load stock');
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({key, required this.title});

  final String title;

  get listOfColumns => [
    {"ID": "1", "Name": "Avi", "Location": "Tel-Aviv", "Action": "Test"},
    {"ID": "2", "Name": "Yossi", "Location": "Tel-Aviv", "Action": "Test"},
    {"ID": "3", "Name": "David", "Location": "Tel-Aviv", "Action": "Test"}
  ];

  @override
  Widget build(BuildContext context) {
    var test = getDailyOpenClose().then((news) { print(news);});
    return Scaffold(
      appBar: AppBar(title: Text(title), backgroundColor: Colors.amber),
      body: DataTable(
        columns: const [
          DataColumn(label: Text('ID')),
          DataColumn(label: Text('Name')),
          DataColumn(label: Text('Location')),
          DataColumn(label: Text('Action')),
        ],
        rows:
        listOfColumns.map<DataRow>(
        ((element) => DataRow(
        cells: <DataCell>[
          DataCell(Text(element["ID"] ?? "")), //Extracting from Map element the value
          DataCell(Text(element["Name"] ?? "")),
          DataCell(Text(element["Location"] ?? "")),
          DataCell(Text(element["Action"] ?? "")),
  ],
  )),
  ).toList(),
        ),
      drawer: Drawer(
        // Add a ListView to the drawer. This ensures the user can scroll
        // through the options in the drawer if there isn't enough vertical
        // space to fit everything.
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.amber,
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
              ),
              child: Text('Menu', textAlign: TextAlign.center),
            ),
            ListTile(
              title: const Text('Item 1'),
              textColor: Colors.red,
              hoverColor: Colors.purple,
              onTap: () {
                // Update the state of the app
                // ...
                // Then close the drawer
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Item 2'),
              onTap: () {
                // Update the state of the app
                // ...
                // Then close the drawer
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class Stock {
  final String symbol;
  final double open;
  final double close;
  final double high;
  final double low;

  const Stock({
    required this.symbol,
    required this.open,
    required this.close,
    required this.high,
    required this.low,
  });

  factory Stock.fromJson(Map<String, dynamic> json) {
    return Stock(
      symbol: json['symbol'],
      open: json['open'],
      close: json['close'],
      high: json['high'],
      low: json['low'],
    );
  }
}

class MyHttpOverrides extends HttpOverrides{
  @override
  HttpClient createHttpClient(SecurityContext? context){
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port)=> true;
  }
}