var GIS = (function () {

  return {
    config: GIS_CONFIG,
    init: function () {
      // configure proj4 to use local state plane projection
      proj4.defs('EPSG:2272', '+proj=lcc +lat_1=40.96666666666667 +lat_2=39.93333333333333 +lat_0=39.33333333333334 +lon_0=-77.75 +x_0=600000 +y_0=0 +ellps=GRS80 +datum=NAD83 +to_meter=0.3048006096012192 +no_defs ');

      // listen for 'enter' key on address input
  		$('#search-input').on('keyup', function (e) {
  		    if (e.keyCode == 13) {
  		        GIS.handleSearchButtonClick();
  		    }
  		});

      $('#search-button').click(GIS.handleSearchButtonClick);
    },

    updateSearchAction: function (action) {
      $('#search-action').text(action);
    },

    toCamelCase: function (s) {
			return s.replace(
				/\w+/g,
	        	function (w) { return w[0].toUpperCase() + w.slice(1).toLowerCase(); }
	        );
		},

		// handle clicks to the locate button
		handleSearchButtonClick: function (e) {
			GIS.updateSearchAction('Validating address...');
			// $('#multiple').css('display','none');
			var inputAddress = $('#search-input').val();
			GIS.fetchAis(inputAddress);
		},

		// handle clicks to the locate button in the multiple result selector
		handleSearchButtonClickMultiple: function (e) {
			var selected = $('#selectAddress').val();

			console.log('did select from multiple:', selected);

			this.fetchAis(selected);
		},

		// this function gets user input and queries the Address Information System. this is
		// intended to replace the Address Candidate function.
		fetchAis: function (inputAddress) {
            console.log("fetch ais:", inputAddress);

            var url = 'https://api.phila.gov/ais/v1/addresses/' + encodeURIComponent(inputAddress);

            $.ajax({
            	url: url,
            	data: {
            		include_units: true,
            		opa_only: true,
            		gatekeeperKey: 'cb076d7301c315ba0f039b8f7744ac6d',
            	},
            	success: GIS.didFetchAis,
            	error: GIS.didNotFetchAis,
            });
		},

		// on successful ais fetch
		didFetchAis: function (data) {
			console.log('did fetch ais', data);

			GIS.updateSearchAction(null);

			// check number of results
			var features = data.features,
				resultCount = Array.isArray(features) ? features.length : 0;

			if (resultCount === 1) {
				var feature = features[0];
				GIS.didGetValidAddress(feature);

			// if we got multiple results
			} else if (resultCount > 1) {
				// show dropdown
				populateMultipleResultDropdown(features);

			// if we got no results
			} else {
				console.log('ais successful but no features');
				alert('Could not locate that address. Please try another search.');
			}
		},

		// on unsuccessful ais fetch
		didNotFetchAis: function (jqXHR, textStatus, errorThrown) {
			console.log('error fetching ais:', errorThrown, jqXHR);

			GIS.updateSearchAction(null);

			alert('Error while validating address: ' + errorThrown);
		},

		populateMultipleResultDropdown: function (features) {
			var $select = $('#selectAddress');

			$select.empty();

			_.each(features, function (feature) {
				console.log('feature', feature);
				var address = feature.properties.street_address;
				var $opt = $('<option>')
								.text(address)
								.val(address);
				$select.append($opt);
			});

			$('#multiple').show();
		},

		didGetValidAddress: function (feature) {
			console.log('did get valid address', feature);

			var coords = feature.geometry.coordinates,
				x = coords[0],
				y = coords[1],
				address = feature.properties.street_address;

			// add marker and zoom
			GIS.map.addGeocodeMarker(x, y, address);
			GIS.map.zoomTo(x, y);

			// get "related" cases (recent, nearby cases with the same record type)
			var recordTypeId = window.opener && window.opener.RECORD_TYPE_ID;

			// DEBUG: if no parent window, use record type id for Dangerous Sidewalk
			if (!recordTypeId) recordTypeId = '012G00000014Gt6IAE';

			GIS.fetchRelated(recordTypeId, x, y);

			// fetch layer info
			var layerInfo = GIS.fetchLayerInfo(feature, null);
		},

		fetchLayerInfo: function (feature, caseType) {
			console.log('fetch layer info', feature, caseType);

			GIS.updateSearchAction('Querying layers...');

			//var GIS_BASE_URL = '{!$Setup.GIS__c.ESRIServices__c}' + '/',
			var queryLayers = GIS.config.queryLayers,
          queryLayerFns = {};

			// build up an array of query fns for each layer
			_.forOwn(queryLayers, function (queryLayerDef, queryLayerName) {
				//console.log('query layer', queryLayerName, queryLayerDef);

				var queryLayerFn = function (callback) {
					//var endpoint = queryLayerDef.endpoint,
					var url = queryLayerDef.url,
						type = queryLayerDef.type,
						options = queryLayerDef.options;

					switch(type) {
						case 'esri':
							// form params
							var params = {
									outFields: '*',
									returnGeometry: 'true',
									f: 'json'
								},
								whereFn = options.where,
								where = whereFn(feature);
							params.where = where;

							$.ajax({
								url: url + '/query',
								data: params,
								success: function (dataStr) {
									// parse json string
									var data = $.parseJSON(dataStr);

									// check for error
									if (data.error) {
										console.log('did get error for where query', queryLayerName, data);

										callback(true);

										return;
									}

									//console.log('did get data for where query', queryLayerName, data, url);

									// unpack attributes object
									var features = data.features,
										feature = Array.isArray(features) && features.length > 0 ? features[0] : null,
										result;

									if (feature)  {
										result = feature.attributes;

										console.log('set', queryLayerName, result);
									}

									callback(null, result);
								},
								error: function () {
									console.log('did get esri error');

									callback(queryLayerName + ' had error');
								}
							});

							break;

						case 'carto':
							var qFn = options.q,
								q = qFn(feature),
								params = {
									q: q,
								};

							$.ajax({
								url: url,
								data: params,
								success: function (data) {
									// unpack attributes
									var rows = data.rows,
										row = Array.isArray(rows) && rows.length > 0 ? rows[0] : null;

									callback(null, row);
								},
								error: function () {
									console.warn('did get carto error');

									callback(queryLayerName + ' had error');
								},
							});

							break;

						default:
							console.warn('unhandled query type: ' + type);
							callback("unhandled query type '" + type + "'", null);

							break;
					}
				};

				queryLayerFns[queryLayerName] = queryLayerFn;
			});

			// execute query fns in parallel
			async.parallel(
				queryLayerFns,
				// then do this
				function (err, results) {
					GIS.updateSearchAction(null);

					// check for an error
					if (err) {
						console.log('async parallel error:', err);
						return;
					}

					console.log('async parallel finished', results);

					GIS.saveGeodata(feature, results);
				}
			);
		},

		saveGeodata: function (feature, layerInfo) {
			console.log('save geodata', feature, layerInfo);

			// pass data back to parent window
			var geodata = GIS.createGeodataObject(feature, layerInfo);
			console.log('geodata', geodata);

			// DEBUG: if window.opener isn't defined, we're probably just testing this
			// from the X311GISMap page directly. don't try to call saveGeodata on the parent.
			if (!window.opener) {
				console.warn('window.opener not defined. geodata will not be saved.');
				return;
			}

			window.opener.saveGeodata(geodata);
		},

		// takes an ais feature and formats it as a "geodata" object which the parent window can understand.
		createGeodataObject: function (feature, layerInfo) {
			console.log('create geodata object', feature, layerInfo);

			var props = feature.properties,
				coords = feature.geometry.coordinates,
				coordsStatePlane = proj4('EPSG:2272', coords),
				// parent page checks for the token `Intersection`, so camel case this
				matchType = GIS.toCamelCase(feature.ais_feature_type),
				addressKey = (props.li_address_key || '').split('|')[0];

			// we're now getting the L&I district from AIS, so update layer info
			layerInfo.district = props.li_district;

			var geodata = {
					gisData: {
						standardizedAddress: props.street_address,
						matchType: matchType,
						// address keys are pipe-delimited, so take the first one
						addressKey: addressKey,
						// REVIEW is it ok to use the opa address here?
						liAddress: props.opa_address,
						zoning: props.zoning,
					},

					// this doesn't seem to be used
					description: null,

					// this doesn't seem to be used
					featureData: null,

					// TODO populate this based on if there's a related case
					parentId: null,
					// this seems to be related to the parent case
					label: null,

					x: coords[0],
					y: coords[1],
					x2272: coordsStatePlane[0],
					y2272: coordsStatePlane[1],

					layerInfo: layerInfo,

					// this seems to be where service area values go
					attributes: {
						SA_STREETS_ZipCode: props.zip_code,
						SA_PHILLYRISING: props.philly_rising_area,
						SA_POLICE_District: props.police_district,
						SA_STREETS_Rubbish: props.rubbish_recycle_day,
						SA_PLANNING_2016Councilmanic: props.council_district_2016,
						SA_STREETS_Sanitation_Districts: props.sanitation_district,
					}
				};

			return geodata;
		},

		fetchRelated: function (recordTypeId, x, y, callback) {
			console.log('fetch related');

			X311GISConnectorClr.QueryByRadius(recordTypeId, x, y, 500, GIS.didFetchRelated);
		},

		didFetchRelated: function (results, event) {
			console.log('did fetch related', results, event);

			// put markers on map
			GIS.map.addRelatedMarkers(results);

			// TODO populate list on right-hand side
		},
  };
})();

$(GIS.init);
