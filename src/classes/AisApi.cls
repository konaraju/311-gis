public with sharing class AisApi {
  public string baseUrl;
  public string gatekeeperKey;

  public AisApi(string aBaseUrl, string aGatekeeperKey) {
    // system.debug('* new AisApi *');
    // system.debug(aBaseUrl);
    // system.debug(aGatekeeperKey);

    this.baseUrl = aBaseUrl;
    this.gatekeeperKey = aGatekeeperKey;
  }

  /*
    API METHODS
  */

  // fetch a response from the api
  public Map<String, Object> addresses(string searchAddress) {
    system.debug('* AisApi.addresses *');

    // create http client
    Http http = new Http();

    // make request
    HttpRequest req = new HttpRequest();
    req.setEndpoint(this.baseUrl);
    req.setMethod('GET');

    // send and get response body
    HttpResponse res = http.send(req);
    string body = res.getBody();

    // return parsed ais response obj
    return (Map<String, Object>) Json.deserializeUntyped(body);
  }
}
