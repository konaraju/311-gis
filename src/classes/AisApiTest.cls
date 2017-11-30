@isTest
private class AisApiTest {
  static testMethod void testAisApi() {
    system.debug('* AisApiTest.testAisSuccess *');

    // create mock api
    StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
    mock.setStaticResource('AisApiTestMockJson');
    mock.setStatusCode(200);
    mock.setHeader('Content-Type', 'application/json');

    // use mock api
    Test.setMock(HttpCalloutMock.class, mock);

    // TODO put following args into global variables
    AisApi aisApi = new AisApi(
      'https://api.phila.gov/ais/v1/addresses/',
      'cb076d7301c315ba0f039b8f7744ac6d'
    );

    // get address results
    Map<String, Object> aisResponse = aisApi.addresses('1234 market st');

    system.debug('response');
    system.debug(aisResponse);
  }

  static testMethod void testAisApiError() {
    system.debug('* AisApiTest.testAisError *');

    // create mock api
    StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
    mock.setStaticResource('AisApiTestMockErrorJson');
    mock.setStatusCode(404);
    mock.setHeader('Content-Type', 'application/json');

    // use mock api
    Test.setMock(HttpCalloutMock.class, mock);

    // TODO put following args into global variables
    AisApi aisApi = new AisApi(
      'https://api.phila.gov/ais/v1/addresses/',
      'cb076d7301c315ba0f039b8f7744ac6d'
    );

    // get address results
    Map<String, Object> aisResponse = aisApi.addresses('12345 market st');

    system.debug('response');
    system.debug(aisResponse);
  }
}