(function() {
  'use strict';

  /**
   * @description Clase constructora para los Menues.
   * Fielo Menu activa las funcionalidades para todos los menues de backend
   * Implementa los patrones de diseño definidos por MDL en
   * {@link https://github.com/jasonmayes/mdl-component-design-pattern}
   *
   * @version 1
   * @author Hugo Gómez Mac Gregor <hugo.gomez@fielo.com>
   * @param {HTMLElement} element - Elemento que será mejorado.
   * @constructor
   */
  var FieloMenu = function FieloMenu(element) {
    this.element_ = element;

    // Initialize instance.
    this.init();
  };
  window.FieloMenu = FieloMenu;

  /**
   * Guarda las constantes en un lugar para que sean facilmente actualizadas
   * @enum {string | number}
   * @private
   */
  FieloMenu.prototype.Constant_ = {};

  /**
   * Guarda strings para nombres de clases definidas por este componente que son usadas por JavaScript.
   * Esto nos permite cambiarlos solo en un lugar
   * @enum {string}
   * @private
   */
  FieloMenu.prototype.CssClasses_ = {
    /** Botón para abrir el menu */
    BUTTON_OPEN: 'fielosf-menu__open',
    /** contenedor del menu */
    ITEMS_CONTAINER: 'fielosf-menu__items-container',
    VIEW_MENU: 'fielosf-menu--is-view',
    /** Nombre para ocultar el elemento */
    HIDE: 'slds-hide'
  };

  /**
   * Pasa los id's de salesforce de 18 a 15 caracteres
   *
   *
   * @public
   */
  FieloMenu.prototype.trimSalesforceIds_ = function() {
    [].forEach.call(
      this.itemsContainer_.getElementsByTagName('a'),
      function(link) {
        var linkStructure = link.href.split('?fcf=');
        if (linkStructure.length > 1) {
          link.href =
            linkStructure[0] + '?fcf=' + linkStructure[1].slice(0, -3);
        }
      }
    );
  };

  /**
   * Muestra/Oculta el menu
   *
   *
   * @public
   */
  FieloMenu.prototype.toggleOpen_ = function() {
    this.itemsContainer_.classList.toggle(this.CssClasses_.HIDE);
    if (this.isOpen_) {
      this.isOpen_ = false;
    } else {
      this.isOpen_ = true;
    }
  };

  /**
   * Bind para el click
   *
   * @private
   */
  FieloMenu.prototype.toggleOpenClick = function() {
    this.toggleOpen_();
  };

  /**
   * Bind para el mouseOut
   *
   * @private
   * @param {event} event Evento Mouse out
   */
  FieloMenu.prototype.toggleOpenMouseOut = function() {
    this.itemsContainer_.classList.add(this.CssClasses_.HIDE);
  };

  /**
   * Inicializa el elemento
   */
  FieloMenu.prototype.init = function() {
    if (this.element_) {
      // Estado del menu
      this.isOpen_ = false;
      // Registro el boton para abrir el menu
      this.btnOpen_ =
        this.element_.getElementsByClassName(this.CssClasses_.BUTTON_OPEN)[0];

      // Registro el contenedor de items del menu
      this.itemsContainer_ = this.element_.getElementsByClassName(
        this.CssClasses_.ITEMS_CONTAINER
      )[0];

      // Vinculo la escucha con el click Handler
      this.btnOpen_.addEventListener('click', this.toggleOpenClick.bind(this));

      // Vinculo la escucha con el mouseout Handler
      this.itemsContainer_.addEventListener(
        'mouseleave',
        this.toggleOpenMouseOut.bind(this)
      );

      if (this.element_.classList.contains(this.CssClasses_.VIEW_MENU)) {
        this.trimSalesforceIds_();
      }
    }
  };

  // El componente se registra por si solo.
  // Asume que el componentHandler esta habilitado en el scope global
  componentHandler.register({
    constructor: FieloMenu,
    classAsString: 'FieloMenu',
    cssClass: 'fielosf-menu',
    widget: true
  });
})();
