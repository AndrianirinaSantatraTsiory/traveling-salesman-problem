import 'package:flutter/material.dart';

import 'Pages/Data_Page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Poblème de voyageur de commerce',
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController dimensionController = TextEditingController();
  String dimensionError = "";
  final formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          title: Center(child: Text("Problème de voyageur de commerce")),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: TextFormField(
                  key: formKey,
                  controller: dimensionController,
                  decoration: InputDecoration(
                      errorText: dimensionError != "" ? dimensionError : null,
                      border: OutlineInputBorder(),
                      labelText: "Dimension"),
                  keyboardType: TextInputType.numberWithOptions(
                    decimal: false,
                    signed: true,
                  ),
                  validator: (value) {
                    if (value == null || int.tryParse(value) == null) {
                      return "Le nombre doit être et un entier";
                    } else {
                      return null;
                    }
                  },
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  if (int.tryParse(dimensionController.text) != null &&
                      int.parse(dimensionController.text) > 1) {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => DataPage(
                            dimension: int.parse(dimensionController.text))));
                  } else {
                    setState(() {
                      dimensionError = "Veuillez verifier ce champ";
                    });
                  }
                },
                child: Text("Commencer"),
              )
            ],
          ),
        ));
  }
}
