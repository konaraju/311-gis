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
};
