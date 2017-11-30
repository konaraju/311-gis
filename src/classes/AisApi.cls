public with sharing class AisApi {
  public String baseUrl;
  public String gatekeeperKey;

  public AisApi(String aBaseUrl, String aGatekeeperKey) {
    // system.debug('* new AisApi *');
    // system.debug(aBaseUrl);
    // system.debug(aGatekeeperKey);

    this.baseUrl = aBaseUrl;
    this.gatekeeperKey = aGatekeeperKey;
  }

  // addresses endpoint

  public Map<String, Object> addresses(String searchAddress) {
    return this.addresses(searchAddress, 4326);
  }

  public Map<String, Object> addresses(String searchAddress, Integer srid) {
    system.debug('* AisApi.addresses *');

    // create http client
    Http http = new Http();

    // form url
    String url = this.baseUrl + '?srid=' + String.valueOf(srid);

    // make request
    HttpRequest req = new HttpRequest();
    req.setEndpoint(url);
    req.setMethod('GET');

    // send and get response body
    HttpResponse res = http.send(req);
    String body = res.getBody();

    // return parsed ais response obj
    return (Map<String, Object>) Json.deserializeUntyped(body);
  }
}
