import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:playground/data/schema_parser.dart';
import 'package:playground/raw/mode.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Map<String, dynamic>> _data = [];

  @override
  void initState() {
    super.initState();
    _loadJsonData();
  }

  Future<void> _loadJsonData() async {
    final String jsonString = await rootBundle.loadString(
      AppMode.developerMode() ? 'assets/raw/dev/schema.json' : 'assets/raw/release/schema.json',
    );
    if (mounted && jsonString.isNotEmpty) {
      setState(() {
        _data = SchemaParser.fetchAppSyncApis(schema: jsonDecode(jsonString));
      });
    }
  }

  Widget _designText({required Map<String, dynamic> api}) => InkWell(
        onTap: () => log(api["api"]),
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 4.0),
          decoration: new BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(15.0)),
            border: Border.all(
              color: Colors.purple,
            ),
            color: Colors.white,
          ),
          child: Column(
            children: [
              Text(
                api["apiName"],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              Text(
                'Input Parameters',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                'Output Parameters:',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: (_data.isEmpty) ? Theme.of(context).colorScheme.inversePrimary : Colors.greenAccent,
        title: Text(widget.title),
        actions: [
          IconButton(
            onPressed: null,
            icon: const Icon(
              Icons.info,
              color: Colors.black,
            ),
          ),
        ],
      ),
      body: Container(
        color: (_data.isEmpty) ? Theme.of(context).colorScheme.inversePrimary : Colors.greenAccent.shade100,
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
                return _designText(api: _data[index]);
              },
            ),
          ],
        ),
      ),
    );
  }
}
