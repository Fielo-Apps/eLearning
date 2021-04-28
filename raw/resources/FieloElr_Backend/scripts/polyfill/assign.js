// adds compability for IE 11
if (typeof Object.assign !== 'function') {
  Object.assign = function(target, varArgs) {
    'use strict';
    // TypeError if undefined or null
    if (target === null) {
      throw new TypeError('Cannot convert undefined or null to object');
    }

    var to = Object(target);

    for (var index = 1; index < arguments.length; index++) {
      var nextSource = arguments[index];
      // pasamos si es undefined o null
      if (nextSource !== null) {
        for (var nextKey in nextSource) {
          // Evita un error cuando 'hasOwnProperty' ha sido sobrescrito
          if (Object.prototype.hasOwnProperty.call(nextSource, nextKey)) {
            to[nextKey] = nextSource[nextKey];
          }
        }
      }
    }
    return to;
  };
}
