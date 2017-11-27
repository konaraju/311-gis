/*
fb-02222 need to geocode long/lat when 2272 doesn't exist
fb-02241 geocode & project for web (publicstuff) requests
*/

trigger CaseAfterUpdate on Case (after insert, after update) {
    list<Case> caseList = new list<Case>();
    list<string> caseIdList = new list<string>();
    for (Case each : Trigger.new) {
        if (
          // it has an address
          String.IsNotBlank(each.street__c) &&
          // it's not an l&i escalation
          each.Case_Record_Type__c != 'LI Escalation' &&
          // it wasn't created via email
          each.Origin != 'Email' &&
          // it doesn't have a state plane geometry
          (
            each.Centerline_2272x__c == 0 ||
            each.Centerline_2272y__c == 0 ||
            each.Centerline_2272x__c == null ||
            each.Centerline_2272y__c == null
          )
        ) {
            caseList.add(each);
            caseIdList.add(each.id);
        }
    }

    system.debug(caseIdList);

    CaseWrapper.ConvertCenterlineTo2272(caseIdList);
}
