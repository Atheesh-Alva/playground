// Copyright 2024 ostrumtech
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'dart:convert';
import 'dart:developer';
import 'package:flutter/services.dart';

class SchemaParser {
  static List<Map<String, dynamic>> fetchAppSyncApis({
    required Map<String, dynamic> schema,
  }) {
    List<Map<String, dynamic>> apis = [];
    final List allTypes = schema["data"]["__schema"]["types"] ?? [];
    final String queryType = schema["data"]["__schema"]["queryType"]["name"];
    final String mutationType =
        schema["data"]["__schema"]["mutationType"]["name"];
    final String subscriptionType =
        schema["data"]["__schema"]["subscriptionType"]["name"];

    final List<dynamic> queries = allTypes.firstWhere(
          (e) => e['name'] == queryType,
          orElse: () => {},
        )["fields"] ??
        [];
    final List<dynamic> mutations = allTypes.firstWhere(
          (e) => e['name'] == mutationType,
          orElse: () => {},
        )["fields"] ??
        [];
    final List<dynamic> subscriptions = allTypes.firstWhere(
          (e) => e['name'] == subscriptionType,
          orElse: () => {},
        )["fields"] ??
        [];
    final List<dynamic> types = allTypes
        .where((e) =>
            (e['name'] != queryType) &&
            (e['name'] != mutationType) &&
            (e['name'] != subscriptionType))
        .toList();
    for (dynamic item in queries + mutations + subscriptions) {
      final String responseType =
          item["type"]["name"] ?? item["type"]["ofType"]["name"];
      String inputDef = '', inputConts = '', outputDef = '';

      List<dynamic> inputs = [], outputs = [];
      for (var item in item["args"]) {
        String dataType =
            (item["type"]["name"] ?? item["type"]["ofType"]["name"]) +
                (item["type"]["kind"] == "NON_NULL" ? "!" : "");
        inputs.add({"dataType": dataType, "fieldName": item["name"]});
        inputDef = inputDef.isEmpty
            ? '\$${item["name"]}: $dataType'
            : '$inputDef, \$${item["name"]}: $dataType';
        inputConts = inputConts.isEmpty
            ? '${item["name"]}: \$${item["name"]}'
            : '$inputConts, ${item["name"]}: \$${item["name"]}';
      }
      final List<dynamic> responseFileds = types.firstWhere(
            (e) => e['name'] == responseType,
            orElse: () => {},
          )["fields"] ??
          [];

      for (var item in responseFileds) {
        outputs.add(item["name"]);
        outputDef = outputDef.isEmpty
            ? '${item["name"]}'
            : '$outputDef ${item["name"]}';
      }
      String apiName = (queries.firstWhere(
                (e) => e['name'] == item["name"],
                orElse: () => null,
              ) !=
              null)
          ? queryType
          : (mutations.firstWhere(
                    (e) => e['name'] == item["name"],
                    orElse: () => null,
                  ) !=
                  null)
              ? mutationType
              : (subscriptions.firstWhere(
                        (e) => e['name'] == item["name"],
                        orElse: () => null,
                      ) !=
                      null)
                  ? subscriptionType
                  : '';
      apis.add({
        "apiName": item["name"],
        "inputParameters": inputs,
        "outputParameters": outputs,
        "api":
            '${apiName.toLowerCase()} ${item["name"]}($inputDef) {${item["name"]}($inputConts) {$outputDef}}'
      });
    }
    return apis;
  }

  static String buildQuery({
    required String queryName,
    required List inputs,
    required Map output,
    required List<dynamic> apiTypes,
  }) {
    String inputParameterDef = '', constructor = '', outputs = '';
    for (var input in inputs) {
      String dataType =
          (input["type"]["name"] ?? input["type"]["ofType"]["name"]) +
              (input["type"]["kind"] == "NON_NULL" ? "!" : "");
      inputParameterDef = inputParameterDef.isEmpty
          ? '\$${input["name"]}: $dataType'
          : '$inputParameterDef, \$${input["name"]}: $dataType';
      constructor = constructor.isEmpty
          ? '${input["name"]}: \$${input["name"]}'
          : '$constructor, ${input["name"]}: \$${input["name"]}';
    }
    for (dynamic item in apiTypes) {
      if (item['name'] == (output["name"] ?? output["ofType"]["name"])) {
        for (dynamic field in item['fields']) {
          outputs = outputs.isEmpty
              ? '${field["name"]}'
              : '$outputs ${field["name"]}';
        }
      }
    }
    return '${queryName.toLowerCase()} $queryName($inputParameterDef) {$queryName($constructor) {$outputs}}';
  }

  static Future<String> _fetchGraphqlApi({required String apiName}) async {
    Map<String, dynamic> schema = jsonDecode(await rootBundle.loadString(
      'assets/raw/schema.json',
    ));
    for (dynamic item in schema["data"]["__schema"]["types"] ?? []) {
      switch (item['name']) {
        case 'Query':
          {
            for (dynamic query in item['fields']) {
              (query['name']);
            }
            break;
          }
        case 'Mutation':
          {
            for (dynamic mutation in item['fields']) {
              (mutation['name']);
            }
            break;
          }
        case 'Subscription':
          {
            for (dynamic subscription in item['fields']) {
              (subscription['name']);
            }
            break;
          }
        default:
          {
            (item['name']);
            break;
          }
      }
    }
    return '';
  }

  static String _getResponse({
    required Map<String, dynamic> schema,
    required Map<String, dynamic> responseType,
  }) {
    String responseFields = '';
    for (dynamic item in schema["data"]["__schema"]["types"] ?? []) {
      switch (!['Query', 'Mutation', 'Subscription'].contains(item['name'])) {
        case true:
          {
            if (item['name'] ==
                (responseType["name"] ?? responseType["ofType"]["name"])) {
              for (dynamic field in item['fields']) {
                responseFields = responseFields.isEmpty
                    ? '${field["name"]}'
                    : '$responseFields ${field["name"]}';
              }
            }
            break;
          }
        default:
          break;
      }
    }
    return responseFields;
  }
}
