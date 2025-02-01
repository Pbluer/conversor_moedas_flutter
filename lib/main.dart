import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:async/async.dart';
import 'dart:convert';

void main() async {
  runApp(
    const MaterialApp(
      home: Home(),
    ),
  );
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final realController = TextEditingController();
  final dollarController = TextEditingController();
  final euroController = TextEditingController();

  void _realChanged(String text) {

    if( !text.isEmpty ){
      double real = double.parse(text);

      dollarController.text = (real/dollar).toStringAsFixed(2);
      euroController.text = (real/euro).toStringAsFixed(2);
    }else{
      dollarController.text = '0.00';
      euroController.text = '0.00';
    }

  }

  void _dollarChaged(String text) {

    if( !text.isEmpty ){
      double dolar = double.parse(text);

      realController.text = ( dolar * dollar).toStringAsFixed(2);
      euroController.text = ( dolar * dollar / euro ).toStringAsFixed(2);
    }else{
      realController.text = '0.00';
      euroController.text = '0.00';
    }

  }

  void _euroChaged(String text) {

    if( !text.isEmpty ){
      double euro = double.parse(text);

      realController.text = ( euro * this.euro).toStringAsFixed(2);
      euroController.text = ( euro * this.euro / dollar ).toStringAsFixed(2);
    }else{
      realController.text = '0.00';
      euroController.text = '0.00';
    }

  }

  double dollar = 0;
  double euro = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Conversor de Moedas',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.w700, fontSize: 25),
        ),
        backgroundColor: Colors.deepPurpleAccent,
        centerTitle: true,
      ),
      body: FutureBuilder<Map>(
        future: getData(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return const Center(
                child: Text(
                  'Carregando...',
                  style: TextStyle(fontSize: 50, fontWeight: FontWeight.w900),
                ),
              );
            default:
              if (snapshot.hasError) {
                return const Center(
                  child: Text('Carregaando...'),
                );
              } else {
                dollar = snapshot.data!['results']['currencies']['USD']['buy'];
                euro = snapshot.data!['results']['currencies']['EUR']['buy'];

                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10.0,
                    horizontal: 15.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Icon(
                        Icons.monetization_on_outlined,
                        size: 150,
                        color: Colors.deepPurpleAccent,
                      ),
                      const SizedBox(height: 20),
                      buildTextField(
                          'Reais', "R\$ ", realController, _realChanged),
                      const SizedBox(height: 20),
                      buildTextField(
                          'Dollar', "\$ ", dollarController, _dollarChaged),
                      const SizedBox(height: 20),
                      buildTextField('Euro', "€ ", euroController, _euroChaged)
                    ],
                  ),
                );
              }
          }
        },
      ),
    );
  }

  Widget buildTextField(String label, String prefix,
      TextEditingController controller, Function called) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      onChanged: (text) {
        called(text);
      },
      decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            color: Colors.black,
          ),
          prefixText: prefix,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15))),
    );
  }
}

Future<Map> getData() async {
  const request = 'https://api.hgbrasil.com/finance?format=json&key=80267e84';

  http.Response response = await http.get(Uri.parse(request));
  return json.decode(response.body);
}
