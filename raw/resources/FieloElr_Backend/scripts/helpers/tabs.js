(function() {
  'use strict';

  /**
   * @description Clase constructora para los Tabs de Lightning.
   * Fielo Tabs Default activa las pestañas de lightning
   * Implementa los patrones de diseño definidos por MDL en
   * {@link https://github.com/jasonmayes/mdl-component-design-pattern}
   *
   * @version 1
   * @author Hugo Gómez Mac Gregor <hugo.gomez@fielo.com>
   * @param {HTMLElement} element - Elemento que será mejorado.
   * @constructor
   */
  var FieloTabs = function FieloTabs(element) {
    this.element_ = element;

    // Initialize instance.
    this.init();
  };
  window.FieloTabs = FieloTabs;

  /**
   * Guarda strings para nombres de clases definidas por este componente que son usadas por JavaScript.
   * Esto nos permite cambiarlos solo en un lugar
   * @enum {string}
   * @private
   */
  FieloTabs.prototype.CssClasses_ = {
    // Link de la pestaña
    LINK: 'slds-tabs--default__link',
    // Pestañas
    TABS: 'slds-tabs--default__item',
    // Paneles con el contenido
    PANELS: 'slds-tabs--default__content',
    // Marca las pestaña activa
    ACTIVE: 'slds-active',
    // Muestra el panel
    SHOW: 'slds-show',
    // Oculta el panel
    HIDE: 'slds-hide'
  };

  FieloTabs.prototype.Constant_ = {
    CONTROLS: 'aria-controls'
  };

  /**
   * Registra las pestañas
   *
   * @private
   */
  FieloTabs.prototype.setTabs_ = function() {
    this.tabs_ = this.element_.getElementsByClassName(this.CssClasses_.TABS);
    this.activeTab_ = this.element_.querySelector(
      '.' + this.CssClasses_.TABS + '.' + this.CssClasses_.ACTIVE
    );
  };

  /**
   * Registra los paneles
   *
   * @private
   */
  FieloTabs.prototype.setPanels_ = function() {
    var tmpPanels =
      this.element_.getElementsByClassName(this.CssClasses_.PANELS);

    this.panels_ = [];

    [].forEach.call(tmpPanels, function(currentPanel) {
      this.panels_[currentPanel.id] = currentPanel;
      if (currentPanel.classList.contains(this.CssClasses_.SHOW)) {
        this.activePanel_ = this.panels_[currentPanel.id];
      }
    }, this);
  };

  /**
   * Registra los eventos
   *
   * @private
   */
  FieloTabs.prototype.setEventListeners_ = function() {
    [].forEach.call(this.tabs_, function(tab) {
      tab.addEventListener('click', this.clickHandler_.bind(this));
    }, this);
  };

  /**
  * Handler del click
  *
  * @private
  * @param {event} event Evento click
  */
  FieloTabs.prototype.clickHandler_ = function(event) {
    this.showTab_(event.target);
    this.callback();
  };

  /**
  * Oculta el tab activo
  *
  * @private
  */
  FieloTabs.prototype.toggle_ = function() {
    try {
      this.activeTab_.classList.toggle(this.CssClasses_.ACTIVE);
      this.activePanel_.classList.toggle(this.CssClasses_.SHOW);
      this.activePanel_.classList.toggle(this.CssClasses_.HIDE);
    } catch (e) {}
  };

  /**
  * Muestra el tab correspondiente
  *
  * @private
  * @param {DOMElement} tab Evento click
  */
  FieloTabs.prototype.showTab_ = function(tab) {
    this.toggle_();
    this.activeTab_ = tab.parentElement;
    this.activePanel_ = this.panels_[tab.getAttribute(this.Constant_.CONTROLS)];
    this.toggle_();
  };

  /**
   * Inicializa el elemento
   */
  FieloTabs.prototype.init = function() {
    if (this.element_) {
      // para evitar el undefined
      this.callback = function() {};

      this.setTabs_();
      this.setPanels_();
      this.setEventListeners_();
    }
  };

  // registro el componente en fielo.helper
  fielo.helper.register({
    constructor: FieloTabs,
    classAsString: 'FieloTabs',
    cssClass: 'slds-tabs--default',
    widget: true
  });
})();
