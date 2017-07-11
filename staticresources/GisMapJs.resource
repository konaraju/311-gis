GIS.map = (function () {
  var map,
    geocodeMarker,
    relatedMarkers;

  return {
    init: function () {
      var MAP_OPTIONS = {
          // center over city hall
          center: [39.952388, -75.1658127],
          minZoom: 11,
          zoom: 15,
        };

      // create map
      map = L.map('map', MAP_OPTIONS);

      // move zoom control to bottom-right, a la google
      map.zoomControl.setPosition('bottomright');

      map.attributionControl.addAttribution('City of Philadelphia GIS Services Group');

      // DEBUG but useful and harmless so i'm leaving it on :)
      map.on('zoomend', function (e) {
        console.log('zoomend', e.target.getZoom());
      });

      // add gsg city basemap with labels
      // REVIEW add labels separately?
      L.esri.tiledMapLayer({
        url: '//tiles.arcgis.com/tiles/fLeGjb7u4uXqeF9q/arcgis/rest/services/CityBasemap_Slash/MapServer',
        maxZoom: 22,
      }).addTo(map);

      // listen for relate clicks
      $(document).on('click', '.relate-link', GIS.map.handleRelateClick);
    },

    zoomTo: function (x, y, level) {
      level = level || 18;
      map.setView([y, x], level);
    },

    colorMarker: function (lat, lng, color) {
      var AVAILABLE_COLORS = [
        'blue',
        'red',
        'green',
        'orange',
        'yellow',
        'violet',
        'grey',
        'black',
      ];

      // lower case, just in case
      color = color.toLowerCase();

      if (!AVAILABLE_COLORS.includes(color)) {
        throw 'Leaflet marker not available for color: ' + color;
      }

      var iconUrl = '//cdn.rawgit.com/pointhi/leaflet-color-markers/master/img/marker-icon-2x-' + color + '.png',
          icon = new L.Icon({
          iconUrl: iconUrl,
          shadowUrl: '//cdnjs.cloudflare.com/ajax/libs/leaflet/0.7.7/images/marker-shadow.png',
          iconSize: [25, 41],
          iconAnchor: [12, 41],
          popupAnchor: [1, -34],
          shadowSize: [41, 41],
          }),
          marker = new L.marker([lat, lng], {icon: icon});

      console.log('marker', marker);

      return marker;
    },

    removeMarkers: function () {
      if (geocodeMarker) {
        map.removeLayer(geocodeMarker);
      }

      _.forEach(relatedMarkers, function (relatedMarker) {
        map.removeLayer(relatedMarker);
      });

      geocodeMarker = null;
      relatedMarkers = [];
    },

    addGeocodeMarker: function (x, y, address) {
      console.log('add geocode marker', x, y);

      GIS.map.removeMarkers();

      //geocodeMarker = L.marker([y, x]);

      geocodeMarker = this.colorMarker(y, x, 'yellow');

      var popup = '\
        <div>\
          <strong>' + address + '</strong>' + '\
        </div>\
        <div>\
          <a href="http://atlas.phila.gov/#/' + address + '/" target="_blank">\
            See more in Atlas <span class="fa fa-external-link"></span>\
          </a>\
        </div>\
      ';

      geocodeMarker.bindPopup(popup, {
        minWidth: 130,
      });

      geocodeMarker.addTo(map);

      geocodeMarker.openPopup();
    },

    addRelatedMarkers: function (relateds) {
      console.log('add related markers', relateds);

      _.forEach(relateds, function (related) {
        var lat = related.Centerline__Latitude__s,
            lng = related.Centerline__Longitude__s,
            marker = GIS.map.colorMarker(lat, lng, 'blue'),
            // description = related.description,
            // popup = description + '<br><a href="#" class="related-link">Relate</a>';
            caseId = related.Id,
            caseNumber = related.CaseNumber,
            caseType = related.Subject,
            address = related.Street__c,
            popup = '\
              <div>' +
                '<strong>' + address + ': ' + caseType + '</strong>\
              </div>\
              <div>\
                Case #' + caseNumber +
              '</div>\
              <div>\
                <a class="relate-link"\
                   href="#"\
                   data-case-id="' + caseId + '" \
                   data-case-number="' + caseNumber + '"\
                 >\
                  Relate\
                </a>\
              </div>\
            ';

        marker.bindPopup(popup);
        marker.addTo(map);

        relatedMarkers.push(marker);
      });
    },

    handleRelateClick: function (e) {
      console.log('handle relate click', e);

      // get ids
      var $link = $(this),
          caseId = $link.attr('data-case-id'),
          caseNumber = $link.attr('data-case-number');

      // to "relate" one case to another, we set the parent id to the related's
      // case id.
      GIS.saveGeodata(caseId);

      alert('This case has been related to case #' + caseNumber + '.');
    },
  };
})();

// call initMap on dom ready
$(GIS.map.init);
