(function() {
	'use strict';
	angular.module('theHiveFilters').filter('scdecoder', function() {
		return function(str){
			return str.replace(/&amp;/g, '&').replace(/&lt;/g, '<').replace(/&gt;/g, '>').replace(/&quot;/g, '"').replace(/&#x27;/g, '\'').replace(/&#x2F;/g, '/');
	};
    });
})();
