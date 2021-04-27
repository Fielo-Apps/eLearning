(function() {
  'use strict';

  /**
   * @description Clase constructora para los elementos de un formulario
   * Fielo Output activates functionality to read only data
   * Implements design patterns form MDL at
   * {@link https://github.com/jasonmayes/mdl-component-design-pattern}
   *
   * @version 1
   * @author Hugo Gómez Mac Gregor <hugo.gomez@fielo.com>
   * @param {HTMLElement} element - Element to be upgraded
   * @constructor
   */

  var FieloOutput = function FieloOutput(element) {
    this.element_ = element;

    // Initialize instance.
    this.init();
  };
  window.FieloOutput = FieloOutput;

  /**
   * Svaes constants
   * @enum {string | number}
   * @private
   */
  FieloOutput.prototype.Constant_ = {
    TYPE: 'data-type'
  };

  /**
   * Saves Css Classes names.
   * @enum {string}
   * @private
   */
  FieloOutput.prototype.CssClasses_ = {
    HIDE: 'slds-hide'
  };

  /**
   * Configs date with moment
   */
  FieloOutput.prototype.configDate_ = function() {
    var date = new Date(this.element_.innerText);
    if (date) {
      // formats output
      if (this.type_.toLowerCase() === 'datetime') {
        var options = {
          year: 'numeric', month: 'numeric', day: 'numeric',
          hour: 'numeric', minute: 'numeric', second: 'numeric',
          hour12: false,
          timeZone: BackEndJSSettings.USER_TIMEZONE
        };
        date = new Intl.DateTimeFormat(BackEndJSSettings.LOCALE, options).format(date)
      }

      if (this.type_.toLowerCase() === 'date') {
        date = new Intl.DateTimeFormat(BackEndJSSettings.LOCALE.replace('_','-')).format(date)
      }

      this.element_.innerText = date;
    }
  };

  FieloOutput.prototype.set = function(value) {
    switch (this.type_.toLowerCase()) {
      case 'checkbox':
      case 'boolean':
        if (value) {
          this.element_.getElementsByTagName('input')[0]
            .setAttribute('checked', value);
          this.element_
            .getElementsByTagName('input')[0].checked = value;
        }
        break;
      default:
        this.element_.innerHTML = value;
    }
    this.config_();
  };

  FieloOutput.prototype.clear = function() {
    switch (this.type_.toLowerCase()) {
      case 'checkbox':
      case 'boolean':
        this.element_
          .getElementsByTagName('input')[0].checked = false;
        break;
      default:
        this.element_.innerHTML = '';
    }
    this.config_();
  };

  /**
   * Configura para renderizar html
   */
  FieloOutput.prototype.renderHTML_ = function() {
    $(this.element_).html($('<div/>').html(this.element_.innerHTML).text());
  };

  /**
  * Configures text/area
  */
  FieloOutput.prototype.configText_ = function() {
    this.element_.innerText =
      fielo.util.unescapeJsInHtml(this.element_.innerText);
  };

  FieloOutput.prototype.config_ = function() {
    switch (this.type_.toLowerCase()) {
      case 'date':
      case 'datetime':
        this.configDate_();
        break;
      case 'html':
        this.renderHTML_();
        break;
      case 'text':
      case 'textarea':
        this.configText_();
        break;
      default:
    }
  };

  /**
   * Inicializa el elemento
   */
  FieloOutput.prototype.init = function() {
    if (this.element_) {
      this.type_ = this.element_.getAttribute(this.Constant_.TYPE) || '';
      this.config_();
      this.element_.classList.remove(this.CssClasses_.HIDE);
    }
  };

  // registro el componente en fielo.util
  fielo.util.register({
    constructor: FieloOutput,
    classAsString: 'FieloOutput',
    cssClass: 'fielosf-output',
    widget: true
  });
})();
