(function() {
  'use strict';

  /**
   * @description Clase constructora para los Alertas.
   * Fielo Alert activa las funcionalidades para los mensajes de alerta
   * Implementa los patrones de diseño definidos por MDL en
   * {@link https://github.com/jasonmayes/mdl-component-design-pattern}
   *
   * @version 1
   * @author Hugo Gómez Mac Gregor <hugo.gomez@fielo.com>
   * @param {HTMLElement} element - Elemento que será mejorado.
   * @constructor
   */
  var FieloSpinner = function FieloSpinner(element) {
    this.element_ = element;

    // Initialize instance.
    this.init();
  };
  window.FieloSpinner = FieloSpinner;

  /**
   * Guarda las constantes en un lugar para que sean facilmente actualizadas
   * @enum {string | number}
   * @private
   */
  FieloSpinner.prototype.Constant_ = {};

  /**
   * Guarda strings para nombres de clases definidas por este componente que son usadas por JavaScript.
   * Esto nos permite cambiarlos solo en un lugar
   * @enum {string}
   * @private
   */
  FieloSpinner.prototype.CssClasses_ = {
    /** Nombre para ocultar el elemento */
    HIDE: 'slds-hide'
  };

  /**
   * Muestra el spinner
   *
   * @public
   */
  FieloSpinner.prototype.show = function() {
    this.element_.classList.remove(this.CssClasses_.HIDE);
  };

  /**
   * Oculta el spinner
   *
   * @public
   */
  FieloSpinner.prototype.hide = function() {
    this.element_.classList.add(this.CssClasses_.HIDE);
  };

  /**
   * Inicializa el elemento
   */
  FieloSpinner.prototype.init = function() {
    if (this.element_) {
      window.fielo.util.spinner = this.element_;
    }
  };

  // El componente se registra por si solo.
  // Asume que el componentHandler esta habilitado en el scope global
  componentHandler.register({
    constructor: FieloSpinner,
    classAsString: 'FieloSpinner',
    cssClass: 'slds-spinner_container',
    widget: true
  });

  // Lo registro en fielo.util
  window.fielo.util.createSpinner = function() {
    var markup = document.createElement('div');
    markup.setAttribute(
      'class',
      'slds-spinner_container slds-spinner_container--main slds-hide'
    );
    markup.innerHTML =
      '<div class="slds-spinner--brand slds-spinner slds-spinner--medium"' +
      ' role="alert">' +
        '<span class="slds-assistive-text">' +
        BackEndJSSettings.LABELS.Loading + '</span>' +
        '<div class="slds-spinner__dot-a"></div>' +
        '<div class="slds-spinner__dot-b"></div>' +
      '</div>';
    componentHandler.upgradeElement(markup);
    document.getElementsByClassName('fielosf')[0].appendChild(markup);
    window.fielo.util.spinner = markup;
  };
})();
