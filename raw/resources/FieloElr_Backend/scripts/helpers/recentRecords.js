(function() {
  'use strict';

  /**
   * @description Controlador para Recent Records.
   * Implementa los patrones de diseño definidos por MDL en
   * {@link https://github.com/jasonmayes/mdl-component-design-pattern}
   *
   * @version 1
   * @author Nicolás Soberón <nicolas.soberon@fielo.com>
   * @param {HTMLElement} element - Elemento que será mejorado.
   * @constructor
   */
  var FieloRecentRecords = function FieloRecentRecords(element) {
    this.element_ = element;

    // Initialize instance.
    this.init();
  };
  window.FieloRecentRecords = FieloRecentRecords;

  /**
   * Guarda las constantes en un lugar para que sean facilmente actualizadas
   * @enum {string | number}
   * @private
   */
  FieloRecentRecords.prototype.Constant_ = {
    ACTION: 'data-action',
    ASYNC: 'data-async',
    FIELD: 'data-field',
    NAME: 'data-name',
    RECORD_ID: 'data-record-id',
    SHOW: 'data-aljs-show',
    TYPE: 'data-type',
    UPGRADED: 'data-upgraded'
  };

  /**
   * Guarda strings para nombres de clases definidas por este componente que
   * son usadas por JavaScript.
   * Esto nos permite cambiarlos solo en un lugar
   * @enum {string}
   * @private
   */
  FieloRecentRecords.prototype.CssClasses_ = {
    BUTTON: 'slds-button',
    CHECKBOXALL: 'fielosf-recent-records-checkboxall',
    CHECKBOXES: 'fielosf-recent-records-checkbox',
    COLUMN: 'fielosf--col-model',
    CONTAINER: 'fielosf-recent-records__container',
    DELETE: 'delete-field',
    HEADER: 'fielosf-recent-records__header',
    HIDE: 'slds-hide',
    MODEL: 'fielosf-recent-records__model',
    OUTPUT: 'fielosf-output',
    PAGINATOR: 'fielosf-paginator',
    ROW: 'fielosf-recent-records__row',
    SLDS_HEADER: 'fielosf-header'
  };

  FieloRecentRecords.prototype.renderRecords_ = function(records) {
    var i = 0;
    if (this.model_) {
      var colModel = this.model_
        .getElementsByClassName(this.CssClasses_.COLUMN)[0];
      var newModel = this.model_.cloneNode(true);
      var header = this.element_
        .getElementsByClassName(this.CssClasses_.HEADER)[0];
      var headerColModel =
        header.getElementsByClassName(this.CssClasses_.COLUMN)[0];
      for (var field in this.extraFields_) {
        if (this.extraFields_.hasOwnProperty(field)) {
          var newColModel = colModel.cloneNode(true);
          newColModel.getElementsByClassName(this.CssClasses_.OUTPUT)[0]
            .setAttribute(this.Constant_.FIELD, field);
          newModel.appendChild(newColModel);
          var newHeaderColModel = headerColModel.cloneNode(true);
          newHeaderColModel.classList.add(this.CssClasses_.DELETE);
          newHeaderColModel.getElementsByClassName(this.CssClasses_.OUTPUT)[0]
            .innerHTML = this.extraFields_[field];
          header.getElementsByClassName(this.CssClasses_.ROW)[0]
            .appendChild(newHeaderColModel);
        }
      }
      var container =
        this.element_.getElementsByClassName(this.CssClasses_.CONTAINER)[0] ||
        null;
      container.innerHTML = '';
      /* CHECK */
      if (records.length === 0) {
        this.model_.classList.add(this.CssClasses_.HIDE);
        container.appendChild(this.model_);
      }
      records.forEach(function(record) {
        var newRecord = newModel.cloneNode(true);
        newRecord.classList.remove(this.CssClasses_.HIDE);
        newRecord.setAttribute(this.Constant_.RECORD_ID, record.Id);
        var newRecordRow = newRecord
          .getElementsByClassName(this.CssClasses_.OUTPUT);
        [].forEach.call(
          newRecordRow,
          function(field) {
            // TODO Crear setter de output al cual se le pasa el record
            var dataField = field.getAttribute(this.Constant_.FIELD).split('.');
            var idField;
            var inDepth = (dataField.length > 1);
            if (inDepth) {
              idField = dataField.slice();
              idField[dataField.length - 1] = 'Id';
            }

            field.innerHTML = fielo.util.getObjectValue(record, dataField);

            switch (field.getAttribute(this.Constant_.TYPE).toLowerCase()) {
              case 'link':
              case 'reference':
                if (inDepth) {
                  field.setAttribute(
                    'href',
                    '/' + fielo.util.getObjectValue(record, idField)
                  );
                } else {
                  field.setAttribute('href', '/' + record.Id);
                }
                break;
              default:
            }
          },
          this
        );
        [].forEach.call(
          newRecord.querySelectorAll('[' + this.Constant_.UPGRADED + ']'),
          function(element) {
            element.removeAttribute(this.Constant_.UPGRADED);
            componentHandler.upgradeElement(element);
          },
          this
        );
        [].forEach.call(
          newRecord.getElementsByClassName(this.CssClasses_.CHECKBOXES),
          function(checkbox) {
            checkbox.FieloFormElement.set(
              'checkboxBinding',
              checkbox.id + '-input-' + i
            );
            checkbox.id += i;
            i++;
          }
        );
        container.appendChild(newRecord);
      }, this);
    }
    fielo.util.spinner.FieloSpinner.hide();
    this.callback();
  };

  /**
   * Callback
   */

  FieloRecentRecords.prototype.callback = function() {};

  /**
   * Recarga los datos de la tabla
   */

  FieloRecentRecords.prototype.reload_ = function() {
    this.paginator_.FieloPaginator.setPage();
    this.paginator_.FieloPaginator.getRecords();
  };
  /**
   * Bindea las acciones de los botones
   */

  FieloRecentRecords.prototype.bindHeaderActionsCallbacks_ = function() {
    [].forEach.call(
      document.querySelectorAll(
        '.' + this.CssClasses_.SLDS_HEADER +
        ' .' + this.CssClasses_.BUTTON + '[' + this.Constant_.ACTION + ']'
      ),
      function(button) {
        if (
          button.FieloButton.type_ &&
          (button.FieloButton.type_ === 'Remote' ||
          button.FieloButton.type_ === 'RemoteList')
        ) {
          button.FieloButton.callback = this.reload_.bind(this);
        } else if (button.FieloButton.type_ === 'Modal') {
          document.getElementById(button.getAttribute(this.Constant_.SHOW))
            .FieloForm.callback = this.reload_.bind(this);
        }
      },
      this
    );
  };

  /**
   * Set all checkboxes equals to selectAll check
   */
  FieloRecentRecords.prototype.checkOrUncheckAll_ = function() {
    for (var item = 0; item < this.checkboxes_.length; item++) {
      this.checkboxes_[item].FieloFormElement
        .set('value', this.selectAllCheckbox_.FieloFormElement.get('value'));
    }
  };

  /**
   * Reset all checkboxes
   */
  FieloRecentRecords.prototype.uncheckAll = function() {
    for (var item = 0; item < this.checkboxes_.length; item++) {
      this.checkboxes_[item].FieloFormElement.set('value', 'false');
    }
    this.selectAllCheckbox_.FieloFormElement.set('value', 'false');
  };

  FieloRecentRecords.prototype.addExtraField = function(extraField, value) {
    this.extraFields_[extraField] = value;
  };

  FieloRecentRecords.prototype.cleanExtraFields = function() {
    this.extraFields_ = {};
    var headerFields = this.element_.querySelectorAll(
      '.' + this.CssClasses_.HEADER + ' .' + this.CssClasses_.DELETE
    );
    [].forEach.call(headerFields, function(field) {
      field.remove();
    });
  };

  FieloRecentRecords.prototype.getChecked = function() {
    var value;
    var checked = [];
    var res = [];
    for (var item = 0; item < this.checkboxes_.length; item++) {
      checked = this.checkboxes_[item].FieloFormElement.get('value');
      if (checked) {
        value =
          $(this.checkboxes_[item]).closest('.' + this.CssClasses_.ROW)[0]
            .getAttribute(this.Constant_.RECORD_ID);
        res.push(value);
      }
    }
    return res;
  };
  // NO SE USA EN NINGUN LADO

  /**
   * Returs the recent records paginator
   * @return {object} paginator object
   * @public
   */
  FieloRecentRecords.prototype.getPaginator = function() {
    return this.paginator_;
  };

  /**
   * Inicializa el elemento
   */
  FieloRecentRecords.prototype.init = function() {
    if (this.element_) {
      componentHandler.upgradeElements(
        this.element_.getElementsByClassName(this.CssClasses_.OUTPUT)
      );
      this.model_ = this.element_
        .getElementsByClassName(this.CssClasses_.MODEL)[0].cloneNode(true) ||
        null;
      this.extraFields_ = {};
      this.paginator_ =
        this.element_.getElementsByClassName(this.CssClasses_.PAGINATOR)[0];
      this.paginator_.FieloPaginator.callback = this.renderRecords_.bind(this);
      this.async_ = this.element_.getAttribute(this.Constant_.ASYNC);
      if (this.async_ === 'true') {
        this.paginator_.FieloPaginator.setPage();
        this.paginator_.FieloPaginator.getRecords();
      }
      this.selectAllCheckbox_ =
        this.element_.getElementsByClassName(this.CssClasses_.CHECKBOXALL)[0];
      this.checkboxes_ =
        this.element_.getElementsByClassName(this.CssClasses_.CHECKBOXES);
      if (this.selectAllCheckbox_) {
        this.selectAllCheckbox_
          .addEventListener('change', this.checkOrUncheckAll_.bind(this));
      }
      this.bindHeaderActionsCallbacks_();
    }
  };

  fielo.helper.register({
    constructor: FieloRecentRecords,
    classAsString: 'FieloRecentRecords',
    cssClass: 'fielosf-recent-records',
    widget: true
  });
})();
