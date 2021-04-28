// Inits momen locale
if (BackEndJSSettings.LOCALE.indexOf(BackEndJSSettings.LANGUAGE + '_') === 0) {
  moment.locale([BackEndJSSettings.LOCALE, BackEndJSSettings.LANGUAGE, 'en']);
} else {
  moment.locale([BackEndJSSettings.LANGUAGE, 'en']);
}

// Inicializa appiphony
if (typeof $.aljsInit === 'function') {
  $.aljsInit({
    assetsLocation: BackEndJSSettings.RESOURCE.BACKEND + '/lightning',
    scoped: true
  });
}

/**
 * @description Librería de utilidades de Fielo
 *
 * @author Hugo Gómez Mac Gregor <hugo.gomez@fielo.com>
 * @author Sebastian Claros <sebastian.claros@fielo.com>
 * @version 2
  */

var fielo = (function() {
  'use strict';

  // Return an object exposed to the public
  return {

    util: {
      /**
       * @method
       * @summary Devuelve el elemento padre<br>
       *
       * Obtenido de {@link http://gomakethings.com/climbing-up-and-down-the-dom-tree-with-vanilla-javascript/}
       * @param {DOMelement} element  Elemento HTML al cual se busca el padre
       * @param {string} selector Selector CSS que indica cuál tiene que ser su padre
       * @return {DOMelement} Retorna el elemento padre
       */

      /**
       * @method
       * @summary loop recursivly witih an object to get the final value
       *
       * @param {object} object object with the data
       * @param {array} dataFields Array with properties set in the correc order
       *
       * @return {object} Value of the obect
       */
      getObjectValue: function(object, dataFields) {
        if (object.hasOwnProperty(dataFields[0])) {
          if (dataFields.length > 1) {
            if (typeof object[dataFields[0]] === 'object') {
              return this.getObjectValue(
                object[dataFields.shift()],
                dataFields
              );
            }
          } else {
            return object[dataFields[0]];
          }
        } else {
          return '';
        }
      },

      // TODO: Remover este metodo. se usa en filters
      getParentUntil: function(element, selector) {
        var firstChar = selector.charAt(0);
        var search;
        switch (firstChar) {
          case '.':
            // Si el selector es .XXXX => Busca si hay un ancestro que contenga la clase XXX
            for (
              search = selector.substr(1); element && element !==
              document; element = element.parentNode
            ) {
              if (element.classList.contains(search)) {
                return element;
              }
            }
            break;
          case '#':
            // Si el selector es #XXXX => Busca si hay un ancestro con ID=XXX
            for (
              search = selector.substr(1); element && element !==
              document; element = element.parentNode
            ) {
              if (element.id === search) {
                return element;
              }
            }
            break;
          case '[':
            // Si el selector es [XXXX] => Busca si hay un ancestro con un atributo XXX
            // Si el selector es [XXXX=YYY] => Busca si hay un ancestro con un atributo XXX=YYY
            // Si el selector es [XXXX~=YYY] => Busca si hay un ancestro con un atributo XXX que contengYYY
            search = selector.substr(1, selector.length - 2).split('=');
            var attribute = search[0].trim();
            if (search.length === 1) {
              for (; element && element !== document; element = element
                .parentNode) {
                if (element.hasAttribute(attribute)) {
                  return element;
                }
              }
            } else if (search.length === 2) {
              var contains = false;
              var value = search[1].trim();
              if (attribute.substr(attribute.length - 1, 1) === '~') {
                attribute = attribute.substr(0, attribute.length - 1);
                contains = true;
              }
              for (; element && element !== document; element = element
                .parentNode) {
                if (element.hasAttribute(attribute)) {
                  var attributeValue = element.getAttribute(attribute);
                  if (
                    attributeValue === value ||
                    (contains === true && attributeValue.indexOf(value) >=
                      0)
                  ) {
                    return element;
                  }
                }
              }
            } else {
              console.log('Invalid selector:' + selector);
            }
            break;
          default:
            // Si el selector es XXXX => Busca si hay un ancestro con el Tag XXX
            for (
              ; element && element !== document;
              element = element.parentNode
            ) {
              if (element.tagName.toLowerCase() === selector) {
                return element;
              }
            }
            break;
        }
        return false;
      },
      // listado de componentes registrados
      registered_: [],
      unescapeJsInHtml: function(string) {
        string && string.replace && (string = string.replace(/\\\\/g, '\\'), // eslint-disable-line no-unused-expressions
        string = string.replace(/\\'/g, '\''),
        string = string.replace(/\\n/g, '\n'),
        string = string.replace(/\\&#39;/g, '\''),
        string = string.replace(/&#39;/g, '\''),
        string = string.replace(/&quot;/g, '"'),
        string = string.replace(/&amp;/g, '&'));
        return string;
      },
      parseDateFromSF: function(date) {
        var isNegativeDate = false;
        if (date && date !== '') {
          // las fechas de SF ya vienen en GMT 0
          // Proceso los tipos de cechas posibles
          // Si es una fecha unix
          // para convertir a UTC
          if (typeof date === 'number') {
            if (date < 0) {
              isNegativeDate = true;
              date *= -1;
            }
            date = date.toString();
          }
          if (date.match('[0-9]{10,13}') && date.match('^[0-9]*$')) {
            // si es numero viene por remote y ya esta en UTC
            date = Number(date);
            if (isNegativeDate) {
              date = '-' + date;
            }
          } else if (date.indexOf('GMT') === -1) {
            // Si es un literal
            // Parseo y genero un UTC que es un GMT en 0

            // Separo la fecha (dd) y la hora (tt)
            var dd = date.split(' ')[0];
            var tt = [];
            var utcArguments = [];
            // Separo la fecha (dd) y la hora (tt)
            if (typeof date.split(' ')[1] !== 'undefined') {
              tt = date.split(' ')[1].split(':');
            }

            if (date.indexOf('/') === -1) {
              // no tiene GMT ej: 2017-10-26 20:01:40
              dd = dd.split('-');
              utcArguments.push(Number(dd[0]));
              utcArguments.push(Number(dd[1] - 1));
              utcArguments.push(Number(dd[2]));
              if (tt) {
                utcArguments.push(Number(tt[0]));
                utcArguments.push(Number(tt[1]));
                utcArguments.push(Number(tt[2]));
              }
            } else {
              // ó ej: 11/16/2017 12:00 am

              dd = dd.split('/');
              // Encuentro la posicion de la fecha segun el formato
              var dateFormat = BackEndJSSettings.DATE_FORMAT.split('/');
              var ddYY;
              var ddMM;
              var ddDD;

              // posicion 0
              if (dateFormat[0].toLowerCase().indexOf('y') === 0) {
                ddYY = 0;
              } else if (dateFormat[0].toLowerCase().indexOf('m') === 0) {
                ddMM = 0;
              } else {
                ddDD = 0;
              }

              // posicion 1
              if (dateFormat[1].toLowerCase().indexOf('y') === 0) {
                ddYY = 1;
              } else if (dateFormat[1].toLowerCase().indexOf('m') === 0) {
                ddMM = 1;
              } else {
                ddDD = 1;
              }

              // posicion 2
              if (dateFormat[2].toLowerCase().indexOf('y') === 0) {
                ddYY = 2;
              } else if (dateFormat[2].toLowerCase().indexOf('m') === 0) {
                ddMM = 2;
              } else {
                ddDD = 2;
              }
              utcArguments.push(Number(dd[ddYY]));
              utcArguments.push(Number(dd[ddMM] - 1));
              utcArguments.push(Number(dd[ddDD]));
              if (tt.length > 0) {
                utcArguments.push(Number(tt[0]));
                utcArguments.push(Number(tt[1]));
              }
            }
            date = Date.UTC.apply(null, utcArguments);
          } else {
            // tiene GMT transformo el literal en UTC ej: Thu Oct 05 15:11:05 GMT 2017
            date = new Date(date).valueOf();
          }
        }
        return date;
      },
      parseDateToSF: function(date) {
        if (date && date !== '') {
          date = new Date(date);
          date = new Date(
            date.valueOf() - date.getTimezoneOffset() * 60000
          ).valueOf();
        }
        return date;
      },
      formatDate: function() {
        BackEndJSSettings.DATE_FORMAT =
          BackEndJSSettings.DATE_FORMAT
          // Replace days
            .replace(/^d\//g, 'dd/')
            .replace(/\/d\//g, '/dd/')
            .replace(/\/d$/g, '/dd')
            .replace(/d/g, 'D')
          // Replace months
            // .replace(/^M\//g, 'MM/')
            // .replace(/\/M\//g, '/MM/')
            // .replace(/\/M$/g, '/MM')
          // Replace years
            .replace(/^yy\//g, 'yyyy/')
            .replace(/\/yy\//g, '/yyyy/')
            .replace(/\/yy$/g, '/yyyy')
            .replace(/y/g, 'Y');

        BackEndJSSettings.DATETIME_FORMAT =
          BackEndJSSettings.DATETIME_FORMAT
          // Replace days
            .replace(/^d\//g, 'dd/')
            .replace(/\/d\//g, '/dd/')
            .replace(/\/d+\s/g, '/dd ')
            .replace(/d/g, 'D')
          // Replace months
            // .replace(/^M\//g, 'MM/')
            // .replace(/\/M\//g, '/MM/')
            // .replace(/\/M+\s/g, '/MM ')
          // Replace years
            .replace(/^yy\//g, 'yyyy/')
            .replace(/\/yy\//g, '/yyyy/')
            .replace(/\/yy+\s/g, '/yyyy ')
            .replace(/y/g, 'Y');
      },
      escapeHTML: function(data) {
        data && data.replace && (data = data.replace(/&/g, '\x26amp;'),
        data = data.replace(/</g, '\x26lt;'),
        data = data.replace(/>/g, '\x26gt;'));
        return data;
      },
      unescapeHTML: function(data) {
        var specialCharacters = [
          {key: '\x26amp;', value: '&'},
          {key: '\x26gt;', value: '>'},
          {key: '&quot;', value: '\''}
        ];
        if (data && data.replace) {
          specialCharacters.forEach(function(char) {
            var newRegExp = new RegExp(char.key, 'g');
            data = data.replace(newRegExp, char.value);
          });
        }
        return data;
      },
      /**
       * @method
       * @summary registra los componentes
       *
       * @param {object} config  objecto que registra el componente con el componentHandler
       */
      register: function(config) {
        fielo.util.registered_.push(config);
      },
      /**
       * @method
       * @summary inicia los componentes en el componentHandler
       *
       * @param {array} components  componentes a iniciar con el componentHandler
       */
      init: function() {
        fielo.util.registered_.forEach(function(config) {
          componentHandler.register(config);
        });
      },
      backdrop: document.getElementsByClassName('slds-backdrop')[0],
      modalShow: function(modalObj, source) {
        var modal = document.getElementById(modalObj.id);
        if (modal.getAttribute('data-on-show') !== null) {
          window[modal.getAttribute('data-on-show')](modal, source);
        }
      }
    },
    helper: {
      // listado de componentes registrados
      registered_: [],
      /**
       * @method
       * @summary registra los componentes
       *
       * @param {object} config  objecto que registra el componente con el componentHandler
       */
      register: function(config) {
        fielo.helper.registered_[config.classAsString] = config;
      },
      /**
       * @method
       * @summary inicia los componentes en el componentHandler
       *
       * @param {array} components  componentes a iniciar con el componentHandler
       */
      init: function(components) {
        components.forEach(function(component) {
          componentHandler.register(fielo.helper.registered_[component]);
        });
      }
    }
  };
})();

window.fielo = fielo;

window.addEventListener('load', function() {
  'use strict';
  svg4everybody();
  fielo.util.formatDate();
  fielo.util.createSpinner();
  fielo.util.notify.createContainer();

  $('body').modal({
    selector: '[data-aljs="modal"]',
    onShow: fielo.util.modalShow
  });
});
