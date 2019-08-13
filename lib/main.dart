import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

void main() => runApp(MaterialApp(
    home: Home(),
    theme: ThemeData(
        hintColor: Colors.amber,
        primaryColor: Colors.white,
        inputDecorationTheme: InputDecorationTheme(
            enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.amber))
        )
    )
));

Future<Map> getData() async {
  http.Response response = await http.get("https://api.hgbrasil.com/finance");
  return json.decode(response.body);
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();

  double dolar;
  double euro;

  void _realChanged(String text) {
    if(text.isEmpty) {
      _clearAll();
      return;
    }
    double real = double.parse(text);
    dolarController.text = (real/dolar).toStringAsPrecision(3);
    euroController.text = (real/euro).toStringAsPrecision(3);
  }
  void _dolarChanged(String text) {
    if(text.isEmpty) {
      _clearAll();
      return;
    }
    double dol = double.parse(text);
    realController.text = (dol * this.dolar).toStringAsPrecision(3);
    euroController.text = (dol * this.dolar / euro).toStringAsPrecision(3);
  }
  void _euroChanged(String text) {
    if(text.isEmpty) {
      _clearAll();
      return;
    }
    double eur = double.parse(text);
    realController.text = (eur * this.euro).toStringAsPrecision(3);
    dolarController.text = (eur * this.euro / dolar).toStringAsPrecision(3);
  }

  void _clearAll(){
    realController.text = "";
    dolarController.text = "";
    euroController.text = "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("\$ Conversor \$", style: TextStyle(color: Colors.white),),
        centerTitle: true,
        backgroundColor: Colors.amber,
      ),
      body: FutureBuilder<Map>(
          future: getData(),
          builder: (context, snapshot) {
            switch(snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
                return Center(
                  // ignore: missing_return, missing_return
                  child: Text("Carregando Dados...", style: TextStyle(color: Colors.amber, fontSize: 25.0), textAlign: TextAlign.center),
                );
              default:
                if(snapshot.hasError) {
                  return Center(
                    child: Text("Erro ao Carregar os Dados :(", style: TextStyle(color: Colors.amber, fontSize: 25.0), textAlign: TextAlign.center),
                  );
                } else {
                  dolar = snapshot.data["results"]["currencies"]["USD"]["buy"];
                  euro = snapshot.data["results"]["currencies"]["EUR"]["buy"];
                  return SingleChildScrollView(
                    padding: EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Icon(Icons.monetization_on, size: 150.0, color: Colors.amber),
                        Divider(),
                        buildTextField("Reais", "R\$", realController, _realChanged),
                        Divider(),
                      buildTextField("USD","US\$", dolarController, _dolarChanged),
                        Divider(),
                        buildTextField("EURO","€", euroController, _euroChanged)
                      ],
                    ),
                  );
                }
            }
          }
      ),
    );
  }

  Widget buildTextField(String label, String prefix, TextEditingController contrl, Function f) {
    return TextField(decoration: InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.amber),
      border: OutlineInputBorder(gapPadding: 10.0),
      prefixText: prefix,
    ),
      style: TextStyle(color: Colors.amber, fontSize: 25.0),
      controller: contrl,
      onChanged: f,
      keyboardType: TextInputType.number,
    );
  }
}


