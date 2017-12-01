/*
CaseWrapperAis is version of the original CaseWrapper that has been modified to
use the Address Information System (AIS) instead of ULRS for geocoding. This
class is really only used to process cases from the mobile and web PublicStuff
apps which are geocoded initially using the Google Maps API. For various
reasons, we need to augment the Google geocode using metadata about the address
from AIS, such as standardized address, State Plane coordinates, and service
areas.
*/

public with sharing class CaseWrapperAis {
  // static final Map<String, String> FIELD_MAPPING = new Map<String, String>{
  //   'a' => 'b',
  //   'c' => 'd'.toUpperCase()
  // };

  // these help us manage sync vs. async workflows; both seem to be possible
  // depending on some unknown circumstance in salesforce.
  static Boolean hasFutureFired = false;
  static Boolean hasAfterUpdateFired = false;

  // heper method to return a set of request type ids that require geocoding
  static Set<id> getRecordTypesRequiringGeocode() {
    // query request type ids
    X311RequestType__c[] requestTypeIds = [
      select
        id
      from
        X311RequestType__c
      where
        // that require a geocode
        requiresGeocode__c = true and
        // and have a case record type id
        Case_recordtypeid__c != null
    ];

    Set<Id> idSet = new Set<Id>();

    for (X311RequestType__c requestTypeId : requestTypeIds) {
      idSet.add(requestTypeId.Case_RecordTypeId__c);
    }

    return idSet;
  }

  // helper method to add address verification failure comments to cases that
  // still can't be geocoded
  static void addFailureComment(Case aCase, CaseComment[] caseComments) {
    aCase.Description = '*ADDRESS VERIFICATION NOT DONE*  \r\n' + aCase.Description;

    caseComments.add(new CaseComment(
      CommentBody = 'ADDRESS VERIFICATION FAILED',
      IsPublished = false,
      ParentId = aCase.id
    ));
  }

  // this is the entry point for regeocoding cases that came in without
  // valid state plane coordinates, usually because they were submitted via
  // the public stuff web and mobile apps that use the google maps api.
  // (google probably returns lat/lon or web mercator.)
  public static void regeocode(String[] caseIds) {
    system.debug('** CaseWrapperAis.regeocode **');

    if (caseIds.isEmpty()) {
      return;
    }

    if (system.isFuture()) {
      system.debug('is future');

      regeocodeNow(caseIds);
    } else {
      // we want to avoid re-running in the present
      // as well as the future. since the static variable
      // has a different context both now and in the future
      // we must check it in two places.

      // system.debug('has after update fired? ' + hasAfterUpdateFired);

      if (hasAfterUpdateFired) {
        return;
      }

      hasAfterUpdateFired = true;
      regeocodeFuture(caseIds);
    }
  }

  @future (callout=true)
  static void regeocodeFuture(String[] caseIds) {
    regeocodeNow(caseIds);
  }

  // exception to be thrown when we don't get a 200 back from ais
  private class AisNotFoundException extends Exception {}

  // helper method for getting an ais response and making sure there's a valid
  // result
  static Map<String, Object> fetchAis(AisApi aisApi, String searchAddress) {
    // system.debug('fetch ais: ' + searchAddress);

    Map<String, Object> response = aisApi.addresses(searchAddress);
    return validateAisResponse(response);
  }

  static Map<String, Object> fetchAis(AisApi aisApi,
                                      String searchAddress,
                                      Integer srid) {
    Map<String, Object> response = aisApi.addresses(searchAddress, srid);
    return validateAisResponse(response);
  }

  static Map<String, Object> validateAisResponse (Map<String, Object> response)
  {
    // check for a good response
    Integer status = (Integer)response.get('status');
    Object[] features = (Object[])response.get('features');

    // if we didn't get one
    if (status != 200 || features.size() < 1) {
      throw new AisNotFoundException();
    }

    return response;
  }

  /*
  this is the main function where regeocoding happens.

  input: a String[] of case ids
  */
  static void regeocodeNow(String[] caseIds) {
    system.debug('** CaseWrapperAis.regeocodeNow **');
    // system.debug('case ids: ' + caseIds);
    // system.debug('has future fired: ' + hasFutureFired);

    if (hasFutureFired) {
      return;
    }
    hasFutureFired = true;

    if (caseIds == null || caseIds.size() == 0) {
      return;
    }

    Group citiworksRejectGroup = [
      select id from group where developerName = 'CitiWorks_Reject' limit 1
    ];
    Group mobileReviewGroup = [
      select id
      from group
      where developerName = 'Mobile_and_Web_Address_Review'
      limit 1
    ];

    // query cases
    Case[] cases = [
      select
        id,
        RecordTypeId,
        description,
        street__c,
        centerline_match_type__c,
        centerline__latitude__s,
        centerline__longitude__s,
        centerline_2272x__c,
        centerline_2272y__c
      from Case
      where id in :caseIds
    ];

    // system.debug('cases: ' + cases);

    // get record type ids that require a geocode; i.e., if geoocoding fails,
    // we have to add a failure comment.
    Set<Id> recordTypesRequiringGeocode = getRecordTypesRequiringGeocode();

    // this is used to accumulate geocoding failure comments
    CaseComment[] caseComments = new CaseComment[]{};

    // instantiate ais api
    AisApi aisApi = new AisApi(
      // TODO make these global vars
      'https://api.phila.gov/ais/v1/addresses/',
      'cb076d7301c315ba0f039b8f7744ac6d'
    );

    // loop over cases
    for (Case aCase : cases) {
      String caseAddress = aCase.street__c;

      // wrap this in a try so in case something goes wrong, we add a failure
      // comment
      try {
        // fetch ais
        Map<String, Object> response = fetchAis(aisApi, caseAddress);
        Object[] features = (Object[])response.get('features');

        // pick first address feature.
        // note: not sure that it always makes sense to just pick the first
        // feature, but this is what the old case wrapper was doing.
        Map<String, Object> feature = (Map<String, Object>)features[0];

        // unpack address props and geometry
        String streetAddress = (String)feature.get('street_address');
        Map<String, Object> geom = (Map<String, Object>)feature.get('geometry');
        Decimal[] coords = (Decimal[])geom.get('coordinates');
        Decimal lon = coords[0];
        Decimal lat = coords[1];
        String matchType = (String)geom.get('geocode_type');
        Map<String, Object> props = (Map<String, Object>)feature
                                      .get('properties');

        // populate fields in case
        aCase.Street__c = streetAddress;
        aCase.Centerline__Longitude__s = lon;
        aCase.Centerline__Latitude__s = lat;
        aCase.Centerline_Match_Type__c = matchType;
        aCase.HansenAddressKey__c = (String)props.get('li_address_key');
        // REVIEW ais doesn't have "l&i" addresses -- ok to use opa?
        aCase.L_I_Address__c = (String)props.get('opa_address');

        // populate service areas
        aCase.Pickup_Day__c = (String)props.get('SA_STREETS_Rubbish');
        aCase.Center_City_District__c = (String)props.get('SA_CENTER_CITY_DISTRICT');
        aCase.Council_District__c = (String)props.get('SA_PLANNING_2016Councilmanic');
        aCase.Council_District_No__c = (String)props.get('SA_PLANNING_2016Councilmanic');
        aCase.ZipCode__c = (String)props.get('SA_STREETS_ZipCode');
        aCase.Police_District__c = (String)props.get('SA_POLICE_District');

        // get state plane geometry -- we could use an arcgis server geometry
        // service for this, but it's easier to just query ais again, passing
        // in an arg for the spatial reference id.
        Map<String, Object> responseSP = fetchAis(aisApi, caseAddress, 2272);
        Object[] featuresSP = (Object[])responseSP.get('features');

        // pick first address feature.
        // note: not sure that it always makes sense to just pick the first
        // feature, but this is what the old case wrapper was doing.
        Map<String, Object> featureSP = (Map<String, Object>)featuresSP[0];

        // unpack state plane geom
        Map<String, Object> geomSP = (Map<String, Object>)featureSP
                                        .get('geometry');
        Decimal[] coordsSP = (Decimal[])geomSP.get('coordinates');
        Decimal xSP = coordsSP[0];
        Decimal ySP = coordsSP[1];

        // save to case
        aCase.centerline_2272x__c = xSP;
        aCase.centerline_2272y__c = ySP;

      // handle exceptions
      } catch (Exception e) {
        system.debug('EXCEPTION');
        system.debug('case: ' + aCase);
        system.debug('e: ' + e);

        // determine which owner id to give the case before we reject it
        if (recordTypesRequiringGeocode.contains(aCase.RecordTypeId)) {
          aCase.OwnerId = citiworksRejectGroup.id;
        } else {
          aCase.OwnerId = mobileReviewGroup.id;
        }

        // leave comment
        addFailureComment(aCase, caseComments);
      }
    } // end cases loop

    // update cases if necessary
    if (cases.isEmpty() == false) {
      update cases;
    }

    // insert comments if necessary
    if (caseComments.isEmpty() == false) {
      insert caseComments;
    }
  }
}
