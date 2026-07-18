import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Clima + ISS',
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final String apiKey = 'ac2ad430095ea273aea02fbb4903c2b9';

  Map<String, dynamic>? weatherData;
  Map<String, dynamic>? issData;

  @override
  void initState() {
    super.initState();
    cargarDatos();

    Timer.periodic(
      const Duration(seconds: 10),
      (timer) => cargarDatos(),
    );
  }

  Future<void> cargarDatos() async {
    await Future.wait([
      obtenerClima(),
      obtenerISS(),
    ]);
  }

  Future<void> obtenerClima() async {
    final url =
        'https://api.openweathermap.org/data/2.5/weather?q=Barrancabermeja,CO&units=metric&lang=es&appid=$apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      setState(() {
        weatherData = jsonDecode(response.body);
      });
    }
  }

  Future<void> obtenerISS() async {
    final response = await http.get(
      Uri.parse('https://api.wheretheiss.at/v1/satellites/25544'),
    );

    if (response.statusCode == 200) {
      setState(() {
        issData = jsonDecode(response.body);
      });
    }
  }

  Widget dato(String titulo, String valor) {
    return Card(
      child: ListTile(
        title: Text(titulo),
        trailing: Text(
          valor,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (weatherData == null || issData == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Barrancabermeja + ISS',
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          const Text(
            'CLIMA BARRANCABERMEJA',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          dato(
            'Temperatura',
            '${weatherData!['main']['temp']} °C',
          ),
          dato(
            'Sensación térmica',
            '${weatherData!['main']['feels_like']} °C',
          ),
          dato(
            'Humedad',
            '${weatherData!['main']['humidity']} %',
          ),
          dato(
            'Presión',
            '${weatherData!['main']['pressure']} hPa',
          ),
          dato(
            'Velocidad del viento',
            '${weatherData!['wind']['speed']} m/s',
          ),
          dato(
            'Latitud ciudad',
            '${weatherData!['coord']['lat']}',
          ),
          dato(
            'Longitud ciudad',
            '${weatherData!['coord']['lon']}',
          ),
          const SizedBox(height: 20),
          const Text(
            'ESTACIÓN ESPACIAL INTERNACIONAL',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          dato(
            'Latitud ISS',
            '${issData!['latitude']}',
          ),
          dato(
            'Longitud ISS',
            '${issData!['longitude']}',
          ),
          dato(
            'Altitud',
            '${issData!['altitude'].toStringAsFixed(2)} km',
          ),
          dato(
            'Velocidad',
            '${issData!['velocity'].toStringAsFixed(2)} km/h',
          ),
          dato(
            'Visibilidad',
            issData!['visibility'],
          ),
        ],
      ),
    );
  }
}
