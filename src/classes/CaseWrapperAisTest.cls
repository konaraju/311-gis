@isTest
private class CaseWrapperAisTest {
  static testMethod void testConvertCenterlineTo2272() {
    // create mock case id list
    String[] caseIdList =  new String[]{
                             '500q0000006qTjDAAU',
                             '500q0000006qTjIAAU'
                           };

    // test
    CaseWrapperAis.regeocode(caseIdList);
  }
}
