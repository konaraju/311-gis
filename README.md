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
