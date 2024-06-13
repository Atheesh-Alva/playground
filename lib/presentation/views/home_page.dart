import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Map<String, dynamic> _data = {};

  @override
  void initState() {
    super.initState();
    _loadJsonData();
  }

  Future<void> _loadJsonData() async {
    final String jsonString = await rootBundle.loadString(
      'assets/raw_json/user_data.json',
    );
    if (mounted) {
      setState(() {
        _data = jsonDecode(jsonString);
      });
    }
  }

  Widget _designText({required String str}) => ListTile(
        title: Text(
          str,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: (_data.isEmpty)
            ? Theme.of(context).colorScheme.inversePrimary
            : _data["colour"]
                ? Colors.greenAccent
                : Colors.redAccent,
        title: Text(widget.title),
      ),
      body: Container(
        color: (_data.isEmpty)
            ? Theme.of(context).colorScheme.inversePrimary
            : _data["colour"]
                ? Colors.greenAccent.shade100
                : Colors.redAccent.shade100,
        child: ListView(
          children: [
            const Center(
              child: Image(image: AssetImage('assets/images/playground.jpeg')),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const ScrollPhysics(),
              itemCount: _data.length,
              itemBuilder: (_, int index) {
                var first = _data[_data.keys.toList()[index]];
                return (first.runtimeType == String)
                    ? _designText(str: first)
                    : (first.runtimeType == List)
                        ? ListView.builder(
                            shrinkWrap: true,
                            physics: const ScrollPhysics(),
                            itemCount: first.length,
                            itemBuilder: (_, int nextIndex) {
                              return _designText(
                                  str: first[nextIndex].toString());
                            },
                          )
                        : _designText(str: first.toString());
              },
            ),
          ],
        ),
      ),
    );
  }
}
