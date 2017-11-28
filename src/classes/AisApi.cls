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
  public AisResponse addresses(string searchAddress) {
    // make request
  }
}
