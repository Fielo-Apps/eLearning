// TODO: se puede deprecar todo este js
(function() {
  'use strict';

  /**
   * @description Clase constructora para los Selects Html.
   * Fielo Select activa las funcionalidades para los selects
   * Implementa los patrones de diseño definidos por MDL en
   * {@link https://github.com/jasonmayes/mdl-component-design-pattern}
   *
   * @version 1
   * @author Hugo Gómez Mac Gregor <hugo.gomez@fielo.com>
   * @param {HTMLElement} element - Elemento que será mejorado.
   * @constructor
   */
  var FieloSelect = function FieloSelect(element) {
    this.element_ = element;

    // Initialize instance.
    this.init();
  };
  window.FieloSelect = FieloSelect;

  /**
   * Guarda las constantes en un lugar para que sean facilmente actualizadas
   * @enum {string | number}
   * @private
   */
  FieloSelect.prototype.Constant_ = {};

  /**
   * Guarda strings para nombres de clases definidas por este componente que son usadas por JavaScript.
   * Esto nos permite cambiarlos solo en un lugar
   * @enum {string}
   * @private
   */
  FieloSelect.prototype.CssClasses_ = {};

  /**
   * Devuelve el valor seleccionado
   *
   * @public
   * @return {string} Valor seleccionado
   */
  FieloSelect.prototype.getValue = function() {
    return this.element_.options[this.element_.selectedIndex].value;
  };

  /**
   * Inicializa el elemento
   */
  FieloSelect.prototype.init = function() {
    if (this.element_) {}
  };

  // El componente se registra por si solo.
  // Asume que el componentHandler esta habilitado en el scope global
  componentHandler.register({
    constructor: FieloSelect,
    classAsString: 'FieloSelect',
    cssClass: 'slds-select',
    widget: true
  });
})();
