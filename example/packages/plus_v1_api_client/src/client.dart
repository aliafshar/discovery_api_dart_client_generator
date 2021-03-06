part of plus;

abstract class Client {
  String _apiKey;
  OAuth2 _auth;
  String _baseUrl;
  bool makeAuthRequests = false;

  Client([String this._apiKey, OAuth2 this._auth]);

  Future _request(String requestUrl, String method, {String body, String contentType:"application/json", Map urlParams, Map queryParams}) {
    var request = new HttpRequest();
    var completer = new Completer();

    if (urlParams == null) urlParams = {};
    if (queryParams == null) queryParams = {};

    if (_apiKey != null) {
      queryParams["key"] = _apiKey;
    }

    final url = new UrlPattern("$_baseUrl$requestUrl").generate(urlParams, queryParams);

    request.on.loadEnd.add((Event e) {
      if (request.status == 200) {
        var data = JSON.parse(request.responseText);
        completer.complete(data);
      } else {
        completer.complete({"error": "Error ${request.status}: ${request.statusText}"});
      }
    });

    request.open(method, url);
    request.setRequestHeader("Content-Type", contentType);
    if (makeAuthRequests && _auth != null) {
      _auth.authenticate(request).then((request) => request.send(body));
    } else {
      request.send(body);
    }

    return completer.future;
  }
}


abstract class Resource {
  Client _client;

  Resource(Client this._client);
}
