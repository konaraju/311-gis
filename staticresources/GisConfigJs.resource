var GIS_CONFIG = {
  // this is the radius within which to search for nearby (aka "related") cases
  // (in feet)
  nearbyRadius: 500,
  // these are the layers that related data get pulled from
  queryLayers: {
    demoPermit: {
      type: 'esri',
        url: '//gis.phila.gov/arcgis/rest/services/PhilaGov/Construction/MapServer/18',
        options: {
            where: function (feature) {
                return 'ADDRKEY = ' + feature.properties.li_address_key + " AND APPLICATION_TYPE = 'BP_DEMO'";
            }
        }
    },
    dumpsterPrivate: {
      type: 'esri',
      url: '//gis.phila.gov/arcgis/rest/services/PhilaGov/Business/MapServer/8',
      options: {
        where: function (feature) {
          return 'ADDRKEY = ' + feature.properties.li_address_key + " AND TYPE = '3230'";
        },
      },
    },
    familyDaycare: {
      type: 'esri',
      url: '//gis.phila.gov/arcgis/rest/services/PhilaGov/Business/MapServer/8',
      options: {
        where: function (feature) {
          return 'ADDRKEY = ' + feature.properties.li_address_key + " AND TYPE = '3397'";
        },
      },
    },
    foodLicense: {
        type: 'esri',
        url: '//gis.phila.gov/arcgis/rest/services/PhilaGov/Business/MapServer/6',
        options: {
            where: function (feature) {
                return 'ADDRKEY = ' + feature.properties.li_address_key;
            }
        }
    },
    healthCenter: {
        type: 'esri',
        url: '//gis.phila.gov/arcgis/rest/services/PhilaGov/Health_Centers/MapServer/0',
        options: {
            where: function (feature) {
              // note: this layer doesn't have standardized addresses, so there's no
              // guarantee this query will work. adding some logic to improve matching.
              return "UPPER(FULL_ADDRESS) LIKE '" + feature.properties.street_address + "%'";
            }
        }
    },
    hospital: {
        type: 'esri',
        url: '//gis.phila.gov/arcgis/rest/services/PhilaGov/Hospitals/MapServer/0',
        options: {
            where: function (feature) {
              return "UPPER(ADDRESS) LIKE '" + feature.properties.street_address + "%'";
            }
        }
    },
    property: {
      type: 'carto',
      url: '//phl.carto.com/api/v2/sql',
      options: {
        q: function (feature) {
          var accountNum = feature.properties.opa_account_num;

          return "SELECT * FROM opa_properties_public WHERE parcel_number = '" + accountNum + "'";
        },
      },
    },
    rentalLicense: {
        type: 'esri',
        url: '//gis.phila.gov/arcgis/rest/services/PhilaGov/RentalLicense/MapServer/2',
        options: {
            where: function (feature) {
                return 'ADDRKEY = ' + feature.properties.li_address_key;
            }
        }
    },
    rentalViolation: {
        type: 'esri',
        url: '//gis.phila.gov/arcgis/rest/services/PhilaGov/RentalLicense/MapServer/0',
        options: {
            where: function (feature) {
                return 'ADDRKEY = ' + feature.properties.li_address_key;
            }
        }
    },
    vacancy: {
        type: 'esri',
        url: '//gis.phila.gov/arcgis/rest/services/PhilaGov/Vacancy/MapServer/2',
        options: {
            where: function (feature) {
                return 'ADDRKEY = ' + feature.properties.li_address_key;
            }
        }
    },
    violationProperty: {
        type: 'esri',
        url: '//gis.phila.gov/arcgis/rest/services/PhilaGov/Violations/MapServer/0',
        options: {
            where: function (feature) {
                return 'ADDRKEY = ' + feature.properties.li_address_key + " and VIOLATION_STATUS <> 'NOT COMPLIED'";
            }
        }
    },
    zoningPermit: {
        type: 'esri',
        url: '//gis.phila.gov/arcgis/rest/services/PhilaGov/Construction/MapServer/12',
        options: {
            where: function (feature) {
                return 'ADDRKEY = ' + feature.properties.li_address_key;
            }
        }
    },
  },
  // this is a mapping of ULRS-style service area names to AIS ones
  serviceAreas: {
    SA_PLANNING_2016Councilmanic: 'council_district_2016',
    SA_PLANNING_Ward: 'political_ward',
    SA_PLANNING_Ward_Divisions: 'political_division',
    SA_STREETS_ZipCode: '',
    SA_POLICE_District: 'police_district',
    SA_POLICE_Division: 'police_division',
    SA_STREETS_Recycling: 'rubbish_recycle_day',
    SA_STREETS_Rubbish: 'rubbish_recycle_day',
    SA_STREETS_Rubbish_Recyc: 'rubbish_recycle_day',
    SA_STREETS_Leaf: 'leaf_collection_area',
    SA_STREETS_HISTORIC: 'historic_street',
    SA_SCHOOLS_Elementary_School_Catchment: 'elementary_school',
    SA_SCHOOLS_Middle_School_Catchment: 'middle_school',
    SA_SCHOOLS_High_School_Catchment: 'high_school',
    SA_STREETS_Highway_District: 'highway_district',
    SA_STREETS_Highway_Section: 'highway_section',
    SA_STREETS_Highway_Subsection: 'highway_subsection',
    SA_PLANNING_Planning_Districts: 'planning_district',
    SA_PWD_CenterCityDistrict: 'pwd_center_city_district',
    SA_CENTER_CITY_DISTRICT: 'center_city_district',
    SA_STREETS_Recycling_Diversion_Rate: 'recycling_diversion_rate',
    SA_STREETS_Sanitation_Area: 'sanitation_area',
    SA_STREETS_Sanitation_Districts: 'sanitation_district',
    SA_STREETS_Street_Lights_Routes: 'street_light_route',
    SA_Streets_Traffic_District: 'traffic_district',
    SA_Streets_Traffic_PM_District: 'traffic_pm_district',
    SA_PHILLYRISING: 'philly_rising_area',
    PWD_MAINT_DIST: 'pwd_maint_district',
    PWD_PRES_DIST: 'pwd_pressure_district',
    PWD_WTPSA: 'pwd_treatment_plant',
    SA_LNI_DISTRICT: 'li_district',
    SA_POLICE_PSA: 'police_service_area',
    SA_WATER_Water_Plate_Index: 'pwd_water_plate',

    // don't think these exist in ais
    // SA_PLANNING_2000CensusTract,
    // SA_PLANNING_2000CensusBlockGroup
    // SA_PLANNING_2000CensusBlock
    // SA_PLANNING_2000CensusBlock
    // SA_PLANNING_2010CensusBlockGroup
    // SA_PLANNING_2010CensusBlockGroup
    // SA_PLANNING_2010CensusBlockGroup
    // SA_RECREATION_Recreation_District
  }
};
