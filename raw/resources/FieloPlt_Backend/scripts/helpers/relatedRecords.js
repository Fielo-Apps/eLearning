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
  var FieloRelatedRecords = function FieloRelatedRecords(element) {
    this.element_ = element;

    // Initialize instance.
    this.init();
  };
  window.FieloRelatedRecords = FieloRelatedRecords;

  /**
   * Guarda las constantes en un lugar para que sean facilmente actualizadas
   * @enum {string | number}
   * @private
   */
  FieloRelatedRecords.prototype.Constant_ = {
    ACTION: 'data-action',
    ASYNC: 'data-async',
    FIELD: 'data-field',
    MODEL: '.slds-table tbody',
    NAME: 'data-name',
    PARAMETERS: 'data-parameters',
    RECORD_ID: 'data-record-id',
    SHOW: 'data-aljs-show',
    TYPE: 'data-type',
    UPGRADED: 'data-upgraded',
    QTY_CONTROLLER: 'FieloPLT.RelatedListController.getRecordsQty'
  };

  /**
   * Guarda strings para nombres de clases definidas por este componente que
   * son usadas por JavaScript.
   * Esto nos permite cambiarlos solo en un lugar
   * @enum {string}
   * @private
   */
  FieloRelatedRecords.prototype.CssClasses_ = {
    BUTTON: 'slds-button',
    CONTAINER: 'fielosf-related-records__container',
    OUTPUT: 'fielosf-output',
    HIDE: 'slds-hide',
    MODEL: 'fielosf-related-records__model',
    PAGINATOR: 'fielosf-paginator',
    SIZE: 'fielosf-related-records__size',
    ELEMENT: 'slds-form-element'
  };

  FieloRelatedRecords.prototype.renderRecords_ = function(records) {
    if (this.model_) {
      var container =
        this.element_.getElementsByClassName(this.CssClasses_.CONTAINER)[0] ||
        null;

      container.innerHTML = '';

      records.forEach(function(record) {
        var newRecord = this.model_.cloneNode(true);
        newRecord.classList.remove(this.CssClasses_.HIDE);
        [].forEach.call(
          newRecord.getElementsByClassName(this.CssClasses_.OUTPUT),
          function(field) {
            // TODO Crear setter de output al cual se le pasa el record
            var dataField = field.getAttribute(this.Constant_.FIELD).split('.');
            var idField;
            var inDepth = (dataField.length > 1);
            if (inDepth) {
              idField = dataField.slice();
              idField[dataField.length - 1] = 'Id';
            }

            field.removeAttribute('data-upgraded');
            componentHandler.upgradeElement(field);
            field.FieloOutput.clear();
            field.FieloOutput.set(fielo.util.getObjectValue(record, dataField));

            // TODO Create config link of output
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
              // Crear type action
              case 'action':
                [].forEach.call(
                  field.getElementsByClassName(this.CssClasses_.BUTTON),
                  function() {
                  },
                  this
                );
                break;
              default:
            }
          },
          this
        );

        [].forEach.call(
          newRecord.getElementsByClassName('slds-button'),
          function(button) {
            button.setAttribute('data-record', JSON.stringify(record));
          },
          this
        );

        [].forEach.call(
          newRecord.querySelectorAll('[' + this.Constant_.UPGRADED + ']'),
          function(element) {
            element.removeAttribute(this.Constant_.UPGRADED);
            if (element.getAttribute(this.Constant_.RECORD_ID) !== null) {
              element.setAttribute(this.Constant_.RECORD_ID, record.Id);
            }
            var newParameters = element.getAttribute(this.Constant_.PARAMETERS);
            if (newParameters !== null) {
              if (newParameters === '') {
                newParameters = {};
              } else {
                newParameters = JSON.parse(newParameters);
              }
              newParameters.Id = record.Id;
              newParameters = JSON.stringify(newParameters);
              element.setAttribute(this.Constant_.PARAMETERS, newParameters);
            }
            componentHandler.upgradeElement(element);
          },
          this
        );
        newRecord.classList.remove(this.CssClasses_.HIDE);

        container.appendChild(newRecord);
      }, this);
    }
    this.bindActionsCallbacks_();
    this.renderCallback_();
    fielo.util.spinner.FieloSpinner.hide();
  };

  /**
   * Callback para render
   */
  FieloRelatedRecords.prototype.renderCallback_ = function() {
  };

  /**
   * Recarga los datos de la tabla
   */

  FieloRelatedRecords.prototype.reload_ = function() {
    this.paginator_.FieloPaginator.setPage();
    this.paginator_.FieloPaginator.getRecords();
    if (this.callbacks_.length > 0) {
      this.callbacks_.forEach(function(callback) {
        if (typeof callback === 'function') {
          callback();
        }
      });
    }
  };

  /**
   * Bindea las acciones de los botones
   */
  FieloRelatedRecords.prototype.bindActionsCallbacks_ = function() {
    var records = this.element_.getElementsByClassName('fielosf-related-records__record');
    if (this.element_.getAttribute('data-object') === 'FieloPLT__RedemptionItem__c') {
      [].forEach.call(records, function(item) {
      var recordItem = item.querySelector("td[data-name='FieloPLT__Status__c']");
        if (recordItem !== null) {
          var recordStatus = recordItem.getElementsByTagName('span')[0].innerText;
          if (recordStatus !== 'Ready') {
            item.querySelector("button").classList.add('slds-hide');
          }
        }
      }.bind(this));
    }
    var menus =   this.element_.querySelectorAll('.fielosf-menu');
    [].forEach.call(menus,function(menu){
      var actions =   menu.querySelectorAll(
          '.' + this.CssClasses_.BUTTON + '[' + this.Constant_.ACTION + ']'
        );
          //var hiddenActions = 0;
        [].forEach.call(
          actions,
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

        //if (hiddenActions === actions.length) {
          //menu.classList.add('slds-hide');  
        //}
      }.bind(this));
   };

  /**
   * Registra los callbacks
   * @param {Function} callback - function to fire
   */
  FieloRelatedRecords.prototype.registerCallback = function(callback) {
    this.callbacks_.push(callback);
  };

  /**
   * Inicializa el elemento
   */
  FieloRelatedRecords.prototype.init = function() {
    if (this.element_) {
      componentHandler.upgradeElements(
        this.element_.getElementsByClassName(this.CssClasses_.OUTPUT)
      );
      this.model_ = this.element_
        .getElementsByClassName(this.CssClasses_.MODEL)[0].cloneNode(true) ||
        null;
      this.paginator_ =
        this.element_.getElementsByClassName(this.CssClasses_.PAGINATOR)[0];
      this.paginator_.FieloPaginator.callback = this.renderRecords_.bind(this);
      this.async_ = this.element_.getAttribute(this.Constant_.ASYNC);
      if (this.async_ === 'true') {
        this.paginator_.FieloPaginator.setPage();
        this.paginator_.FieloPaginator.getRecords();
      }
      this.sizeCount_ =
        this.element_.getElementsByClassName(this.CssClasses_.SIZE)[0] || null;
      this.bindActionsCallbacks_();
      this.callbacks_ = [];
    }
  };

  fielo.helper.register({
    constructor: FieloRelatedRecords,
    classAsString: 'FieloRelatedRecords',
    cssClass: 'fielosf-related-records',
    widget: true
  });
})();
