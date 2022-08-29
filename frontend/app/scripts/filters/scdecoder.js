(function() {
    'use strict';
    angular.module('theHiveFilters').filter('scdecoder', function() {
	return function(value){
	    if(!value) {
		return '';
	    }
	    var txt = document.createElement("textarea");
	    txt.innerHTML = value;
	    return txt.value;
	    //return value.replace(/&amp;/g, '&').replace(/&lt;/g, '<').replace(/&gt;/g, '>').replace(/&quot;/g, '"').replace(/&#x27;/g, '\'').replace(/&#x2F;/g, '/');
	};
    });
})();
