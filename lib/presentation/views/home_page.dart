import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:playground/data/schema_parser.dart';
import 'package:playground/raw/mode.dart';
import 'package:aws_client/sqs_2012_11_05.dart';

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
          margin: const EdgeInsets.symmetric(vertical: 4.0),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(15.0)),
            border: Border.all(color: Colors.purple),
            color: Colors.white,
          ),
          child: Column(
            children: [
              Text(
                api["apiName"],
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
              ),
              const Text(
                'Input Parameters',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const Text(
                'Output Parameters:',
                style: TextStyle(
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
        actions: const [
          IconButton(
            onPressed: null,
            icon: Icon(
              Icons.info,
              color: Colors.black,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () async {
              AwsClientCredentials(
                accessKey: "",
                secretKey: "",
              );
              final Sqs sqs = Sqs(region: 'eu-west-2');
              SendMessageResult sendMessageResult = await sqs.sendMessage(
                messageBody: 'Hello from Dart client!',
                queueUrl: "",
              );
              log("SendMessageResult: $sendMessageResult");
              sqs.close();
            },
            child: const Text("SQS"),
          ),
          Expanded(
            child: Container(
              color: (_data.isEmpty) ? Theme.of(context).colorScheme.inversePrimary : Colors.greenAccent.shade100,
              child: ListView(
                shrinkWrap: true,
                physics: const ScrollPhysics(),
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
          ),
        ],
      ),
    );
  }
}
