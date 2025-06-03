// Playground App for test platform!

class ApiParser {
  dynamic ostrumApiCall({required OstrumApi ostrumApi}) {
    switch (ostrumApi.apiType) {
      case OstrumApiType.appSync:
        {
          break;
        }
      case OstrumApiType.restFul:
        {
          break;
        }
      default:
        {
          break;
        }
    }
  }
}

enum OstrumApiType {
  appSync,
  restFul;
}

enum OstrumAppSyncType {
  query,
  mutation,
  subscription;
}

enum OstrumRestFulType {
  get,
  post,
  put;
}

class OstrumApi {
  OstrumApiType apiType;
  Map<String, dynamic> inputs;
  String endPoint;

  OstrumApi({required this.apiType, required this.inputs, required this.endPoint});
}

class OstrumAppSyncApi extends OstrumApi {
  OstrumAppSyncType appSyncType;
  List<String> outputs;
  OstrumAppSyncApi({required super.apiType, required super.inputs, required this.outputs, required this.appSyncType, required super.endPoint});
}

class OstrumRestFulApi extends OstrumApi {
  OstrumRestFulType restFulType;
  OstrumRestFulApi({required super.apiType, required super.inputs, required this.restFulType, required super.endPoint});
}
