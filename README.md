# 311-gis

This repo contains code for the geolocation popup window in the 311 Salesforce app, reflecting changes made by GSG in Summer 2017:

 - Uses the Address Information System (AIS) for geocoding
 - Leaflet-based mapping
 - Performance enhancements and code cleanup

## Project Structure

 - `GisPopup.page`: the main body of the GIS popup window
 - `GisAppJs.resource`: JavaScript for main app functionality (geocoding, querying layers, UI events, etc.)
 - `GisMapJs.resource`: JavaScript for map functionality
 - `GisConfigJs.resource`: config file
 - `GisClient.cls`: an Apex class used to query Salesforce for existing cases

## Testing

To test that the triggers (especially `CaseAfterUpdate.trigger`) are working properly, this Apex code can be run anonymously in the Salesforce Developer Console to create a minimal `Case`:

```
Case c = new Case(
	Origin='Test',
    Customer_Declined__c=true,
    Street__c='1234 MARKET ST',
    Subject='Test',
    Translator_Required__c='No'
);
insert c;
```
