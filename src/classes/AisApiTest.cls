@isTest
private class AisApiTest {
  static testMethod void testAisResponse() {
    system.debug('* AisApiTest.testAisResponse *');

    // TODO put these in global variables
    AisApi aisApi = new AisApi(
      '//api.phila.gov/ais/v1/search/',
      'cb076d7301c315ba0f039b8f7744ac6d'
    );
  }
}
