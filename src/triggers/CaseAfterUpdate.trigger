Trigger CaseAfterUpdate on Case (after insert, after update) {
  String[] caseIds = new String[]{};

  for (Case aCase : Trigger.new) {
    if (
      String.IsNotBlank(aCase.street__c) &&
      (
        aCase.Centerline_2272x__c == 0 ||
        aCase.Centerline_2272y__c == 0 ||
        aCase.Centerline_2272x__c == null ||
        aCase.Centerline_2272y__c == null
      ) &&
      // exclude l&i escalations
      aCase.Case_Record_Type__c != 'LI Escalation' &&
      // exclude cases created via email
      aCase.Origin != 'Email'
    ) {
      caseIds.add(aCase.id);
    }
  }

  // system.debug(caseIds);

  CaseWrapperAis.regeocode(caseIds);
}
