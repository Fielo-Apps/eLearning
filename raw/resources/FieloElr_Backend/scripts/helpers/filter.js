
(function() {
  'use strict';

  /**
   * @description Clase constructora de los filtros.
   * FieloFilter activa el funcionamiento de los filtros
   * Implementa los patrones de diseño definidos por MDL en
   * {@link https://github.com/jasonmayes/mdl-component-design-pattern}
   *
   * @version 2
   * @author Hugo Gómez Mac Gregor <hugo.gomez@fielo.com>
   * @contributor Diego Amarante <diego.amarante@fielo.com>
   * @param {HTMLElement} element - Elemento que será mejorado.
   * @constructor
   */
  var FieloFilter = function FieloFilter(element) {
    this.element_ = element;
    // Initialize instance.
    this.init();
  };
  window.FieloFilter = FieloFilter;

  /**
   * Guarda las constantes en un lugar para que sean facilmente actualizadas
   * @enum {string | number}
   * @private
   */
  FieloFilter.prototype.Constant_ = {
    BINDING: 'data-binding',
    CHANGE_TITLE: 'data-change-title',
    DATA_FILTERS: 'data-filters'
  };

  /**
   * Guarda strings para nombres de clases definidas por este componente
   * que son usadas por JavaScript.
   * Esto nos permite cambiarlos solo en un lugar
   * @enum {string}
   * @private
   */
  FieloFilter.prototype.CssClasses_ = {
    ACTIVE: 'slds-is-active',
    HIDE: 'slds-hide',
    ITEM: 'fielosf-list__item',
    LINK: 'fielosf-link',
    PAGINATOR: 'fielosf-paginator',
    TITLE: 'fielosf-filter__title'
  };

  // Private methods

  /**
   * Setea los registros por defecto
   *
   * @private
   */
  FieloFilter.prototype.setDefaults_ = function() {
    // Registro el título
    this.title_ =
      this.element_.querySelector('.' + this.CssClasses_.TITLE) || null;

    if (this.title_ !== null) {
      // Registro el item activo
      this.activeTitle_ = this.element_.querySelector(
        '.' + this.CssClasses_.HIDE + '.' + this.CssClasses_.ITEM +
        '[' + this.Constant_.CHANGE_TITLE + ']'
      ) || false;
    }

    // Registro todos los items
    this.items_ =
      this.element_.querySelectorAll(
        '.' + this.CssClasses_.ITEM + ' ' +
        '.' + this.CssClasses_.LINK
      );

    // Registro el item activo
    this.itemActive_ = this.element_.querySelector(
      '.' + this.CssClasses_.ITEM + '.' + this.CssClasses_.ACTIVE
    ) || false;

    // registro el data binding
    this.dataBinding_ =
      this.element_.getAttribute(this.Constant_.BINDING) || null;

    // Seteo el filtro
    this.filters_ = {};

    // Registro los paginadores de este filtro
    this.bindWithPaginators_();

    // Seteo los items
    this.setupItems_();

    // para evitar el undefined
    this.callback = function() {};
  };

  /**
   * Setea el tipo de filtro
   *
   * @private
   */
  FieloFilter.prototype.bindWithPaginators_ = function() {
    // defino la variable
    if (this.dataBinding_) {
      this.listOfPaginators_ = document.querySelectorAll(
        '.' + this.CssClasses_.PAGINATOR +
        '[' + this.Constant_.BINDING + '=' + this.dataBinding_ + ']'
      );
    } else {
      this.listOfPaginators_ =
        document.getElementsByClassName(this.CssClasses_.PAGINATOR);
    }
  };

  /**
   * Limpia el item activo de sus propiedades
   *
   * @private
   */
  FieloFilter.prototype.cleanActiveCss_ = function() {
    // si existe un item activo
    if (this.itemActive_) {
      // Limpo al activo viejo de todas sus clases
      this.itemActive_.classList.remove(this.CssClasses_.ACTIVE);
    }
  };

  /**
   * Verifico si el item ya esta activado
   *
   * @param {HTMLelement} item - Item a analizar
   * @private
   */
  FieloFilter.prototype.checkIfItemIsAlreadyActive_ = function(item) {
    if (item.classList.contains(this.CssClasses_.ACTIVE)) {
      this.clickedOnSameItem_ = true;
    } else {
      this.clickedOnSameItem_ = false;
    }
  };

  /**
   * Activa el item clickeado
   *
   * @param {HTMLelement} item - Item a activar
   * @private
   */
  FieloFilter.prototype.activeItem_ = function(item) {
    this.checkIfItemIsAlreadyActive_(item);
    if (!this.clickedOnSameItem_) {
      this.cleanActiveCss_();
      // 2_ No tengo item activo
      // Activar actual
      this.itemActive_ = item;
      this.itemActive_.classList.add(this.CssClasses_.ACTIVE);
    }
  };

  /**
   * Actualiza el título el item clickeado
   *
   * @param {HTMLelement} item - Item a activar
   * @private
   */
  FieloFilter.prototype.updateTitle = function(item) {
    this.activeTitle_.classList.remove(this.CssClasses_.HIDE);
    this.title_.textContent = String(item.textContent).trim();
    this.activeTitle_ = item;
    this.activeTitle_.classList.add(this.CssClasses_.HIDE);
  };

  /**
   * Limpia el filtro para ser mandado al paginador
   *
   * @param {HTMLelement} paginator - paginador asociado
   * @private
   */
  FieloFilter.prototype.clearFilter_ = function() {
    // Actualizo los filtros pasados
    for (var filter in this.filters_) {
      if (this.filters_.hasOwnProperty(filter)) {
        this.filters_[filter] = null;
      }
    }
  };

  /**
   * Inicializa cada item
   *@param {event} click - Evento de tipo click
   * @private
   */
  FieloFilter.prototype.itemClickListener_ = function(click) {
    click.preventDefault();
    var item = fielo.util
      .getParentUntil(click.currentTarget, '.' + this.CssClasses_.ITEM);
    // Guardo los filtros del item clickeado
    this.filters_ =
      JSON.parse(click.currentTarget.getAttribute(this.Constant_.DATA_FILTERS));

    // activo el item clickeado
    this.activeItem_(item);

    // Si existe el título y el item puede modificar el título
    if (
      this.title_ !== null && item.hasAttribute(this.Constant_.CHANGE_TITLE)
    ) {
      this.updateTitle(item);
    }

    if (!this.clickedOnSameItem_) {
      // disparo los paginadores
      [].forEach.call(this.listOfPaginators_, function(paginator) {
        // Seteo el paginador
        paginator.FieloPaginator.setFilters(this.filters_);
        paginator.FieloPaginator.setPage();
        paginator.FieloPaginator.getRecords();
      }, this);
    }

    this.callback();
  };

  /**
   * Inicializa cada item
   *
   * @private
   */
  FieloFilter.prototype.setupItems_ = function() {
    [].forEach.call(this.items_, function(item) {
      item.addEventListener('click', this.itemClickListener_.bind(this));
    }, this);
  };

  // Public methods

  /**
   * Inicializa el elemento
   */
  FieloFilter.prototype.init = function() {
    if (this.element_) {
      this.setDefaults_();
    }
  };

  // registro el componente en fielo.helper
  fielo.helper.register({
    constructor: FieloFilter,
    classAsString: 'FieloFilter',
    cssClass: 'fielosf-filter'
  });
})();
