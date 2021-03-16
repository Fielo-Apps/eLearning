(function() {
  'use strict';

  /**
   * @description Controlador para la Landing de Content
   * Implementa los patrones de diseño definidos por MDL en
   * {@link https://github.com/jasonmayes/mdl-component-design-pattern}
   *
   * @version 1
   * @author Nicolás Alejandro Soberón <nicolas.soberon@fielo.com>
   * @param {HTMLElement} element - Elemento que será mejorado.
   * @constructor
   */
  var FieloRecentReorder = function FieloRecentReorder(element) {
    this.element_ = element;

    // Initialize instance.
    this.init();
  };
  window.FieloRecentReorder = FieloRecentReorder;

  /**
   * Guarda las constantes en un lugar para que sean facilmente actualizadas
   * @enum {string | number}
   * @private
   */
  FieloRecentReorder.prototype.Constant_ = {
    UI_DISABLED: 'ui-state-disabled',
    UI_HANDLE: 'ui-sortable-handle'
  };

  /**
   * Guarda strings para nombres de clases definidas por este componente que
   * son usadas por JavaScript.
   * Esto nos permite cambiarlos solo en un lugar
   * @enum {string}
   * @private
   */
  FieloRecentReorder.prototype.CssClasses_ = {
    CONTAINER: 'fielosf-recent-records__container',
    FIELD: 'fielosf-output',
    MODEL: 'fielosf-recent-records__model',
    SAVE: 'fielosf-module-reorder__save',
    GRIPS: 'fielosf-draggable__grip',
    CURSOR: 'fielosf-draggable__cursor'
  };
  /**
  * Get
  */

  FieloRecentReorder.prototype.get = function() {
    var items = this.container_.getElementsByClassName(this.CssClasses_.MODEL);
    var sObjectList = [];
    [].forEach.call(items, function(item) {
      var sObject = {};
      sObject.id = item.getAttribute('data-record-id');
      sObject[this.orderByField_] = // eslint-disable-line camelcase
        item.querySelector(
          '[data-field = "' + this.orderByField_ + '"]').innerHTML;
      sObjectList.push(sObject);
    }, this);
    return sObjectList;
  };

  /**
  * Save Order
  */
  FieloRecentReorder.prototype.save_ = function() {
    if (!this.disableReorder) {
      fielo.util.spinner.FieloSpinner.show();
      var orderValues = this.get();
      try {
        Visualforce.remoting.Manager.invokeAction(
          this.element_.getAttribute('data-save-controller'),
          orderValues,
          this.processRemoteActionResult_.bind(this),
          {
            escape: false
          }
        );
      } catch (e) {
        console.warn(e);
      }
    }
  };

  /**
  * Process Remote Action
  */

  FieloRecentReorder.prototype.processRemoteActionResult_ = function(
    result
  ) {
    var notify = fielo.util.notify.create();
    notify.FieloNotify.addMessages([
      result.messagesSet
    ]);
    if (
      result.messages[0].severity &&
      result.messages[0].severity === 'ERROR'
    ) {
      notify.FieloNotify.setTheme('error');
    } else {
      notify.FieloNotify.setTheme('success');
      location.reload();
    }
    fielo.util.spinner.FieloSpinner.hide();
    notify.FieloNotify.show();
  };

  /**
  * Inicializa el drag and drop
  */

  FieloRecentReorder.prototype.sortable_ = function() {
    // Si el contenedor es tabla fija el ancho
    if (this.container_.nodeName === 'TBODY') {
      var columns = this.container_.querySelectorAll('td, th');
      $(columns).each(function() {
        var cell = $(this);
        cell.width(cell.width());
      });
    }
    this.addGrips();
    $(this.container_).sortable({
      update: this.order.bind(this),
      revert: true,
      cancel: '.' + this.Constant_.UI_DISABLED
    });
  };

  /**
  * Disable the drag and drop
  */

  FieloRecentReorder.prototype.disableSort = function() {
    // Si el contenedor es tabla fija el ancho
    var rows = $(this.element_).find('tr');
    [].forEach.call(rows, function(row) {
      if (!$(row).hasClass(this.Constant_.UI_DISABLED)) {
        $(row).addClass(this.Constant_.UI_DISABLED);
      }
      if ($(row).hasClass(this.Constant_.UI_HANDLE)) {
        $(row).removeClass(this.Constant_.UI_HANDLE);
      }
    }, this);
    this.removeGrips();
  };

  /**
  * Re-enable the drag and drop
  */

  FieloRecentReorder.prototype.enableSort = function() {
    // Si el contenedor es tabla fija el ancho
    var rows = $(this.element_).find('tr');
    [].forEach.call(rows, function(row) {
      if ($(row).hasClass(this.Constant_.UI_DISABLED)) {
        $(row).removeClass(this.Constant_.UI_DISABLED);
      }
      if (!$(row).hasClass(this.Constant_.UI_HANDLE)) {
        $(row).addClass(this.Constant_.UI_HANDLE);
      }
    }, this);
    this.addGrips();
  };

  /**
  * Add grips to rows
  */

  FieloRecentReorder.prototype.addGrips = function() {
    if (!this.hasGrips) {
      this.hasGrips = true;
      var rows = $(this.element_).find('tr');
      rows = $(rows).not(rows[0]);
      [].forEach.call(rows, function(row) {
        if (!$(row).hasClass(this.CssClasses_.GRIPS)) {
          $(row).addClass(this.CssClasses_.GRIPS);
        }
        if (!$(row).hasClass(this.CssClasses_.CURSOR)) {
          $(row).addClass(this.CssClasses_.CURSOR);
        }
      }, this);
    }
  };

  /**
  * Add grips to rows
  */

  FieloRecentReorder.prototype.removeGrips = function() {
    if (this.hasGrips) {
      this.hasGrips = false;
      var rows = $(this.element_).find('tr');
      rows = $(rows).not(rows[0]);
      [].forEach.call(rows, function(row) {
        if ($(row).hasClass(this.CssClasses_.GRIPS)) {
          $(row).removeClass(this.CssClasses_.GRIPS);
        }
        if ($(row).hasClass(this.CssClasses_.CURSOR)) {
          $(row).removeClass(this.CssClasses_.CURSOR);
        }
      }, this);
    }
  };

  /**
  * Setea el orden de los elementos
  */

  FieloRecentReorder.prototype.order = function() {
    var items = this.container_.getElementsByClassName(this.CssClasses_.MODEL);
    var i = 1;
    var field = null;
    [].forEach.call(items, function(elem) {
      field = elem.querySelector(
        '[data-field = "' + this.orderByField_ + '"]');
      if (field) {
        field.innerHTML = i;
      }
      i++;
    }, this);
  };

  /**
  * Inicializa el elemento
  */
  FieloRecentReorder.prototype.init = function() {
    if (this.element_) {
      this.container_ =
        this.element_.getElementsByClassName(this.CssClasses_.CONTAINER)[0] ||
        null;
      this.orderByField_ =
        this.element_.getAttribute('data-order-by');

      this.sortable_();
      this.order();
      this.saveBtn_ = this.element_
        .querySelector('.' + this.CssClasses_.SAVE);
      if (this.saveBtn_) {
        this.saveBtn_.addEventListener('click', this.save_.bind(this));
      }
    }
  };

  // El componente se registra por si solo.
  // Asume que el componentHandler esta habilitado en el scope global
  fielo.helper.register({
    constructor: FieloRecentReorder,
    classAsString: 'FieloRecentReorder',
    cssClass: 'fielosf-recent-reorder',
    widget: true
  });
})();
