(function() {
  'use strict';

  /**
   * @description Clase constructora de los paginados.
   * FieloPaginator activa el funcionamiento del paginado
   * Implementa los patrones de diseño definidos por MDL en
   * {@link https://github.com/jasonmayes/mdl-component-design-pattern}
   *
   * @version 2
   * @author Hugo Gómez Mac Gregor <hugo.gomez@fielo.com>
   * @contributor Diego Amarante <diego.amarante@fielo.com>
   * @param {HTMLElement} element - Elemento que será mejorado.
   * @constructor
   */

  var FieloPaginator = function FieloPaginator(element) {
    this.element_ = element;

    // Initialize instance.
    this.init();
  };
  window.FieloPaginator = FieloPaginator;

  /**
   * Guarda las constantes en un lugar para que sean facilmente actualizadas
   * @enum {string | number}
   * @private
   */
  FieloPaginator.prototype.Constant_ = {
    CONTROLLER: 'data-controller',
    CONTROLLER_ARGUMENTS: 'data-controller-arguments',
    BINDING: 'data-binding',
    PAGE: 'data-page',
    RECORDS_PER_PAGE: 'data-records-per-page',
    RECORDS_IN_PAGE: 'data-records-in-page',
    DISABLED: 'disabled',
    FILTERS: 'data-filters',
    ORDER_BY: 'data-order-by',
    WHERE_CLAUSE: 'data-where-clause'
  };

  /**
   * Guarda strings para nombres de clases definidas por este componente
   * que son usadas por JavaScript.
   * Esto nos permite cambiarlos solo en un lugar
   * @enum {string}
   * @private
   */
  FieloPaginator.prototype.CssClasses_ = {
    // Enlaces del paginador
    BUTTON_PREVIOUS: 'fielosf-button__previous',
    BUTTON_NEXT: 'fielosf-button__next',
    HIDE: 'slds-hide'
  };

  // Private methods

  /**
   * Setea los registros por defecto
   *
   * @private
   */
  FieloPaginator.prototype.setDefaults_ = function() {
    // Regisro el controlador
    this.controller_ = this.element_.getAttribute(this.Constant_.CONTROLLER);

    // registro el data binding
    this.dataBinding_ = this.element_.getAttribute(this.Constant_.BINDING);

    // registro la pagina actual
    this.page_ = Number(this.element_.getAttribute(this.Constant_.PAGE)) || 1;

    // Guardo la # de items por pagina
    this.recordsPerPage_ =
      Number(this.element_.getAttribute(this.Constant_.RECORDS_PER_PAGE));

    // registro los filtros
    this.filters_ = this.element_.getAttribute(this.Constant_.FILTERS) || null;
    if (this.filters_) {
      this.filters_ = JSON.parse(this.filters_);
    } else {
      this.filters_ = {};
    }

    // registro el orderBy
    this.orderBy_ = this.element_.getAttribute(this.Constant_.ORDER_BY) || null;

    // Registro los botones
    this.buttons_ = {
      previous:
        this.element_.querySelector('.' + this.CssClasses_.BUTTON_PREVIOUS),
      next:
        this.element_.querySelector('.' + this.CssClasses_.BUTTON_NEXT)
    };

    this.quantityOfRecords_ =
      Number(this.element_.getAttribute(this.Constant_.RECORDS_IN_PAGE)) || 0;

    this.whereClause_ =
      this.element_.getAttribute(this.Constant_.WHERE_CLAUSE) || null;
  };

  // Tiene que ser definido
  FieloPaginator.prototype.callback = function(records) {
    fielo.util.spinner.FieloSpinner.hide();
    console.warn('callback of paginator not binded');
    console.log(records);
  };

  /**
   * Habilita o deshabilita los links
   *
   * @private
   */
  FieloPaginator.prototype.setButtonsStatus_ = function() {
    // link next
    if (this.quantityOfRecords_ <= this.recordsPerPage_) {
      this.buttons_.next.setAttribute(this.Constant_.DISABLED, '');
    } else {
      this.buttons_.next.removeAttribute(this.Constant_.DISABLED);
    }
    // link previous
    if (this.page_ === 1) {
      this.buttons_.previous.setAttribute(this.Constant_.DISABLED, '');
    } else {
      this.buttons_.previous.removeAttribute(this.Constant_.DISABLED);
    }
  };

  /**
   * Pide la página anterior
   *
   * @private
   */
  FieloPaginator.prototype.getPreviousPage_ = function() {
    if (!this.buttons_.previous.hasAttribute(this.Constant_.DISABLED)) {
      this.setPage(this.page_ - 1);
      this.getRecords();
    }
  };

  /**
   * Pide la página siguiente
   *
   * @private
   */
  FieloPaginator.prototype.getNextPage_ = function() {
    if (!this.buttons_.next.hasAttribute(this.Constant_.DISABLED)) {
      this.setPage(this.page_ + 1);
      this.getRecords();
    }
  };

  /**
   * Registra los listeners de los links
   *
   * @private
   */
  FieloPaginator.prototype.setLinksListeners_ = function() {
    this.buttons_.previous
      .addEventListener('click', this.getPreviousPage_.bind(this));

    this.buttons_.next
      .addEventListener('click', this.getNextPage_.bind(this));
  };

  /**
   * Lanza la configuración inicial de los links
   *
   * @private
   */
  FieloPaginator.prototype.setUpLinks_ = function() {
    this.setButtonsStatus_();
    this.setLinksListeners_();
  };

  // Public methods

  /**
   * Setea la página
   *
   * @param {number} pageNumber - Número de página a guardar
   * @private
   */
  FieloPaginator.prototype.setPage = function(pageNumber) {
    // actualizo la variable interna
    this.page_ = pageNumber || 1;

    // actualizo el atributo html
    this.element_.setAttribute(this.Constant_.PAGE, this.page_);
  };

  /**
   * Devuelve los filtros
   *
   * @return {object} Objeto con los filtros aplicados
   * @public
   */
  FieloPaginator.prototype.getFilters = function() {
    return this.filters_;
  };

  /**
   * Setea los filtros
   *
   * @param {object} newFilters - Filtros a guardar
   * @public
   */
  FieloPaginator.prototype.setFilters = function(newFilters) {
    // Actualizo los filtros pasados
    for (var filter in newFilters) {
      if ({}.hasOwnProperty.call(newFilters, filter)) {
        this.filters_[filter] = newFilters[filter];
      }
    }

    // actualizo el atributo html
    this.element_.setAttribute(
      this.Constant_.FILTERS,
      JSON.stringify(this.filters_)
    );
  };

  /**
   * Setea el orderBy
   *
   * @param {string} order - Orden que se aplica al paginado
   * @private
   */
  FieloPaginator.prototype.setOrderBy = function(order) {
    // actualizo la variable interna
    this.orderBy_ = order;

    // actualizo el atributo html
    this.element_.setAttribute(this.Constant_.ORDER_BY, order);
  };

  /**
   * Método que resuelve el request del paginador
   *
   * @param {array} records - Array con registros en formato json
   * @private
   */
  FieloPaginator.prototype.resolveRequest_ = function(records) {
    // Si existen records
    if (records) {
      // Actualizo la cantidad de tegistros en la pagina
      this.quantityOfRecords_ = records.length || 0;
      this.callback(records.slice(0, this.recordsPerPage_));
    } else {
      // Ya está todo listo. Oculto el spinner
      fielo.util.spinner.FieloSpinner.hide();
      var notify = fielo.util.notify.create();
      notify.FieloNotify.addMessages([
        BackEndJSSettings.LABELS.NoRecordsToShow
      ]);
      notify.FieloNotify.setTheme('info');
      notify.FieloNotify.show();
    }
    // Actualiza el estado de los links
    this.setButtonsStatus_();
  };

  /**
   * Obtiene los records pedidos
   * @return {Array} - Fields of Sobject
   */
  FieloPaginator.prototype.getSObject = function() {
    return this.element_.getAttribute(this.Constant_.CONTROLLER_ARGUMENTS)
      .split('|')[0];
  };

  /**
   * Obtiene los records pedidos
   *
   */
  FieloPaginator.prototype.getRecords = function() {
    // muestro el spinner antes de la petición
    fielo.util.spinner.FieloSpinner.show();

    // Preparo los parámetros a enviar
    var invokeData = [];
    invokeData.push(this.controller_);

    var controllerArguments = this.element_.getAttribute(
      this.Constant_.CONTROLLER_ARGUMENTS
    ).split('|') || null;

    controllerArguments.forEach(function(param) {
      invokeData.push(param);
    });

    invokeData.push(
      (this.page_ * this.recordsPerPage_) - this.recordsPerPage_
    );
    invokeData.push(this.orderBy_);
    invokeData.push(JSON.stringify(this.filters_));
    invokeData.push(this.recordsPerPage_ + 1);

    invokeData.push(this.whereClause_);

    invokeData.push(this.resolveRequest_.bind(this));
    invokeData.push({escape: true});

    try {
      Visualforce.remoting.Manager.invokeAction.apply(
        Visualforce.remoting.Manager, invokeData
      );
    } catch (e) {
      // Ya está todo listo. Oculto el spinner
      fielo.util.spinner.FieloSpinner.hide();
    }
  };

  FieloPaginator.prototype.getParams_ = function() {
    return {
      offset: this.recordsPerPage_,
      orderBy: this.orderBy_,
      page: this.page_
    };
  };

  /**
   * Inicializa el elemento
   */
  FieloPaginator.prototype.init = function() {
    if (this.element_) {
      this.setDefaults_();
      this.setUpLinks_();
    }
  };

  // registro el componente en fielo.helper
  fielo.helper.register({
    constructor: FieloPaginator,
    classAsString: 'FieloPaginator',
    cssClass: 'fielosf-paginator'
  });
})();
