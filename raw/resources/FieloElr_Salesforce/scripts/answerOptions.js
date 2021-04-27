(function() {
  'use strict';

  /**
   * @description Controlador para el formulario FieloAnswerOptions.
   * Permite el envío del formulario
   * Implementa los patrones de diseño definidos por MDL en
   * {@link https://github.com/jasonmayes/mdl-component-design-pattern}
   *
   * @version 1
   * @author Hugo Gómez Mac Gregor <hugo.gomez@fielo.com>
   * @param {HTMLElement} element - Elemento que será mejorado.
   * @constructor
   */
  var FieloAnswerOptions = function FieloAnswerOptions(element) {
    this.element_ = element;
    // Initialize instance.
    this.init();
  };
  window.FieloAnswerOptions = FieloAnswerOptions;

  /**
   * Guarda las constantes en un lugar para que sean facilmente actualizadas
   * @enum {string | number}
   * @private
   */
  FieloAnswerOptions.prototype.Constant_ = {
    DATA_UPGRADED: 'data-upgraded',
    DATA_CONTROLLER: 'data-controller-element',
    DATA_FIELD_NAME: 'data-field-name',
    DATA_FIELD_TABLE: 'data-field',
    OBJECT_TYPE: 'FieloELR__AnswerOption__c'

  };

  /**
   * Guarda strings para nombres de clases definidas poPr este componente que
   * son usadas por JavaScript.
   * Esto nos permite cambiarlos solo en un lugar
   * @enum {string}
   * @private
   */
  FieloAnswerOptions.prototype.CssClasses_ = {
    ITEM: 'fielosf-answer-options__item',
    CONTAINER: 'fielosf-answer-options__container',
    DELETE: 'slds-button--delete',
    NEW: 'slds-button--new-answer',
    FORM_ELEMENT: 'slds-form-element',
    OUTPUT_ELEMENT: 'fielosf-output',
    ELEMENT_LABEL: 'slds-form-element__label',
    PILL_REMOVE: 'slds-pill__remove'

  };

  FieloAnswerOptions.prototype.initItem_ = function(answerOptionItem) {
    answerOptionItem.deleteBtn_ =
      answerOptionItem.getElementsByClassName(this.CssClasses_.DELETE)[0];
    answerOptionItem.deleteBtn_.addEventListener(
      'click',
      this.deleteItem_.bind(this, answerOptionItem)
    );
    this.recentReorder_ = $(answerOptionItem)
        .closest('.fielosf-recent-reorder')[0];
    if (this.recentReorder_) {
      this.recentReorder_.FieloRecentReorder.order();
    }
    var formElementFields = $(answerOptionItem)
      .find('.slds-form-element');
    var label = null;
    if (formElementFields) {
      [].forEach.call(formElementFields, function(field) {
        if (field.closest('td')) {
          if (!$(field).closest('td')
            .hasClass('ui-state-disabled')) {
            $(field).closest('td').addClass('ui-state-disabled');
          }
        }
        label = $(field)
          .find('.' + this.CssClasses_.ELEMENT_LABEL)[0];
        if (label) {
          $(label).toggle(false);
        }
      }, this);
    }
  };

  FieloAnswerOptions.prototype.deleteItem_ = function(answerOptionItem) {
    var answerOptionId =
      answerOptionItem.getAttribute('data-record-id');
    if (answerOptionId) {
      if (!this.deletedItems) {
        this.deletedItems = [];
      }
      this.deletedItems.push(answerOptionId);
    }
    if (this.answerOptionItems_.length > 1) {
      answerOptionItem.remove();
      if (this.recentReorder_) {
        this.recentReorder_.FieloRecentReorder.order();
      }
    }
  };

  FieloAnswerOptions.prototype.clearItem_ = function(item) {
    [].forEach.call(item.getElementsByClassName(this
        .CssClasses_.FORM_ELEMENT), function(element) {
      if (element.FieloFormElement) {
        element.FieloFormElement.clear();
      }
    }, this);
    item.setAttribute('data-record-id', '');
  };

  FieloAnswerOptions.prototype.newAnswerOptionItem_ = function() {
    this.model_ = $(this.answerOptionItems_[0])
      .clone(true)[0];
    var answerOptionItem = $(this.model_).clone(true)[0];
    $(this.container_).append(answerOptionItem);
    [].forEach.call(
      answerOptionItem
        .querySelectorAll('[' + this.Constant_.DATA_UPGRADED + ']'),
      function(element, position) {
        element.removeAttribute(this.Constant_.DATA_UPGRADED);
        element.id = String(element.id + '-' + this.answerOptionItems_.length);
        var dataController = element
          .getAttribute(this.Constant_.DATA_CONTROLLER) || null;
        if (dataController && position !== 0) {
          element.setAttribute(
            this.Constant_.DATA_CONTROLLER,
            String(dataController + '-' + this.answerOptionItems_.length)
          );
        }
        componentHandler.upgradeElement(element);
      },
        this
    );
    this.initItem_(answerOptionItem);
    this.clearItem_(answerOptionItem);
  };

  /**
   *
   * Getter y Setters
   *
   */

  /**
   * Retorna la lista de items
   * @return {Array | Object} - Lista de objetos (sObjects)
   */
  FieloAnswerOptions.prototype.get = function() {
    var sObjectList = [];
    var fields = null;
    var fieldName = null;
    [].forEach.call(this.answerOptionItems_, function(item) {
      var sObject = {};
      fields = item.getElementsByClassName(this
          .CssClasses_.FORM_ELEMENT);
      [].forEach.call(fields, function(field) {
        var sObjectValue = field.FieloFormElement.get('value');
        fieldName = field.getAttribute(this.Constant_.DATA_FIELD_NAME);
        sObject[fieldName] = sObjectValue;
      }, this);

      fields = item.getElementsByClassName(this
          .CssClasses_.OUTPUT_ELEMENT);
      [].forEach.call(fields, function(field) {
        var sObjectValue = field.innerHTML;
        fieldName = field.getAttribute(this.Constant_.DATA_FIELD_TABLE);
        sObject[fieldName] = sObjectValue;
      }, this);

      if (item.getAttribute('data-record-id') !== '') {
        sObject.Id = item.getAttribute('data-record-id');
      }
      sObjectList.push(sObject);
    }, this);
    return sObjectList;
  };

  FieloAnswerOptions.prototype.set = function() {

  };

  FieloAnswerOptions.prototype.clear = function() {
    this.newAnswerOptionItem_();
    var items = this.element_.getElementsByClassName(this.CssClasses_.DELETE);
    while (items.length > 1) {
      items[0].click();
    }
    if (this.recentReorder_) {
      this.recentReorder_.FieloRecentReorder.order();
    }
    this.deletedItems = null;
  };

  /**
   * Inicializa el elemento
   */
  FieloAnswerOptions.prototype.init = function() {
    if (this.element_) {
      this.container_ =
        this.element_.getElementsByClassName(this.CssClasses_.CONTAINER)[0];
      this.answerOptionItems_ =
        this.element_.getElementsByClassName(this.CssClasses_.ITEM);
      this.model_ = this.answerOptionItems_[0].cloneNode(true);
      this.newBtn_ =
        this.element_.getElementsByClassName(this.CssClasses_.NEW)[0];
      if (this.newBtn_) {
        this.newBtn_
          .addEventListener('click', this.newAnswerOptionItem_.bind(this));
      }
      [].forEach.call(this.answerOptionItems_, this.initItem_.bind(this));
    }
  };

  fielo.util.register({
    constructor: FieloAnswerOptions,
    classAsString: 'FieloAnswerOptions',
    cssClass: 'fielosf-answer-options',
    widget: true
  });
})();

