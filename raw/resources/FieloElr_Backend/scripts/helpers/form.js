(function() {
  'use strict';

  /**
   * @description Clase constructora para los notifys.
   * Fielo Form activa las funcionalidades para los formularios
   * Implementa los patrones de diseño definidos por MDL en
   * {@link https://github.com/jasonmayes/mdl-component-design-pattern}
   *
   * @version 1
   * @author Hugo Gómez Mac Gregor <hugo.gomez@fielo.com>
   * @param {HTMLElement} element - Elemento que será mejorado.
   * @constructor
   */

  var FieloForm = function FieloForm(element) {
    this.element_ = element;

    // Initialize instance.
    this.init();
  };
  window.FieloForm = FieloForm;

  /**
   * Guarda las constantes en un lugar para que sean facilmente actualizadas
   * @enum {string | number}
   * @private
   */
  FieloForm.prototype.Constant_ = {
    DEFAULT: 'data-default-value',
    FIELD_NAME: 'data-field-name',
    FIELDS: 'data-fields',
    OBJECT_NAME: 'data-object-name',
    RECORD_ID: 'data-record-id',
    REDIRECT: 'data-redirect',
    RETRIEVE_CONTROLLER: 'data-retrieve-controller',
    SAVE_CONTROLLER: 'data-save-controller',
    SECONDARY_FIELDS: 'data-secondary-parameters',
    SOBJECT_TYPE: 'data-sobject-type',
    TYPE: 'data-type'
  };

  /**
   * Guarda strings para nombres de clases definidas por este componente que son usadas por JavaScript.
   * Esto nos permite cambiarlos solo en un lugar
   * @enum {string}
   * @private
   */
  FieloForm.prototype.CssClasses_ = {
    CONTAINER: 'slds-form-element',
    ELEMENTS: 'slds-form-element',
    ERROR: 'slds-has-error',
    HEADER: 'slds-modal__header',
    HIDE: 'slds-hide',
    INPUT: 'slds-input',
    NOTIFY: 'slds-notify',
    NOTIFY_CONTAINER: 'slds-notify_container',
    SAVE: 'slds-form__save',
    BUTTON: 'slds-button'
  };

  /**
   * Inicializa los elementos
   */
  FieloForm.prototype.setDefaults_ = function() {
    this.data_ = {};
    this.secondaryData_ = {};
    this.fields_ = this.element_
      .getAttribute(this.Constant_.FIELDS).replace(/ /g, '').split(',');
    // Registro el header del formulario
    this.header_ =
      this.element_.getElementsByClassName(this.CssClasses_.HEADER)[0] || null;

    // Registro los elementos del formulario
    this.elements_ = {};
    [].forEach.call(
      this.element_.getElementsByClassName(this.CssClasses_.CONTAINER),
      function(container) {
        componentHandler.upgradeElement(container);
        this.elements_[container.FieloFormElement.get('fieldName')] = container;
      },
      this
    );
    this.saveButton_ =
      this.element_.getElementsByClassName(this.CssClasses_.SAVE)[0] || null;
    if (this.saveButton_) {
      this.saveButton_.addEventListener('click', this.saveHandler_.bind(this));
      this.saveButton_ = this.saveButton_.FieloButton;
    }

    this.recordId_ = null;

    this.saveController_ =
      this.element_.getAttribute(this.Constant_.SAVE_CONTROLLER);
    this.retrieveController_ =
      this.element_.getAttribute(this.Constant_.RETRIEVE_CONTROLLER);
    this.secondaryFields_ =
      this.element_.getAttribute(this.Constant_.SECONDARY_FIELDS) || null;
    if (this.secondaryFields_) {
      this.secondaryFields_ = this.secondaryFields_.split(',');
    }
    this.isEditing = false;
    this.redirect_ =
      this.element_.getAttribute(this.Constant_.REDIRECT);

    this.sObjectType_ = this.element_.querySelector(
      '[' + this.Constant_.SOBJECT_TYPE + ']'
    );
    if (this.sObjectType_) {
      this.sObjectType_ =
        this.sObjectType_.getAttribute(this.Constant_.SOBJECT_TYPE);
    }

    this.button_ = document.querySelectorAll('.' + this.CssClasses_.BUTTON);
    this.button_ = [].filter.call(this.button_, function(b) {
      return b.getAttribute('data-aljs-show') === this.element_.id;
    }.bind(this));
    if (this.button_ && this.button_.length == 1) {
      this.button_ = this.button_[0];
    }

    if (location.hash && location.hash.split('#')[1] === this.element_.id) {
      if (this.button_) {
        if(Array.isArray(this.button_)){
          this.button_[0].click();
        }
        else{
          this.button_.click();
        }
      } else {
        this.clear_();
        $(this.element_).modal('show');
      }
    }
  };

  /**
   * Valida el formulario
   */
  FieloForm.prototype.getValues_ = function() {
    this.nullFields_ = [];
    this.data_ = {};
    $.extend(this.data_, this.parameters_);
    for (var element in this.elements_) {
      if (
        this.elements_.hasOwnProperty(element) &&
        this.elements_[element].FieloFormElement.get('fieldName') !== ''
      ) {
        // Obtiene el valor a envia
        // Usar interfaz
        var value = this.elements_[element].FieloFormElement.get('value');
        // Solo envia los que tengan el campo Name
        if (
          typeof this.elements_[element]
            .FieloFormElement.get('fieldName') !== 'undefined' &&
            this.elements_[element].FieloFormElement.get('fieldName') !== ''
        ) {
          // Guardo al sObject solo si no se trata de un
          if (
            !(this.secondaryFields_ &&
            this.contains_(this.secondaryFields_, element))
          ) {
            if (value === '' || value === null) {
              this.nullFields_.push(
                this.elements_[element].FieloFormElement.get('fieldName')
              );
            } else {
              this.data_[this.elements_[element]
                .FieloFormElement.get('fieldName')] = value;
            }
          }
        }
      }
    }

    // Lleno el secondary data respetando el orden de los parametros
    if (this.secondaryFields_) {
      this.secondaryFields_.forEach(function(field) {
        if (this.elements_[field]) {
          this.secondaryData_[
            this.elements_[field].FieloFormElement.get('fieldName')
          ] = this.elements_[field].FieloFormElement.get('value');
        } else {
          this.secondaryData_[field] = null;
        }
      }, this);
    }
  };

  /**
   * Se fija si un elemento pertenece a un arreglo
  */

  FieloForm.prototype.contains_ = function(arr, element) {
    for (var i = 0; i < arr.length; i++) {
      if (arr[i] === element) {
        return true;
      }
    }
    return false;
  };

  /**
   * Envía el formulario
   * @param {object} result - resultado de salesforce
   * @param {event} event - evento de salesforce
   *
   * @return {bool} false when has no errors
   */
  FieloForm.prototype.processRemoteActionResult_ = function(result, event) {
    this.enableSave();
    fielo.util.spinner.FieloSpinner.hide();
    var notify = fielo.util.notify.create();
    if (!result && !event.status) {
      notify.FieloNotify.addMessages([
        BackEndJSSettings.LABELS.ReviewFollowingErrors, event.message
      ]);
      notify.FieloNotify.setTheme('error');
      notify.FieloNotify.show();
    }
    try {
      // Limpia los Mensajes
      var headerMessages =
        this.header_.getElementsByClassName(this.CssClasses_.NOTIFY);
      while (headerMessages.length > 0) {
        headerMessages[0].FieloNotify.hide();
      }

      // Limpia los mensajes viejos
      for (var element in this.elements_) {
        if (this.elements_.hasOwnProperty(element)) {
          this.elements_[element].FieloFormElement.clean();
        }
      }

      // Coloco los mensajes de error o de exito segun corresponda
      if (event.status && result !== undefined) {
        var hasError = false;
        // Si existen mensajes verifico si hay alguno de error
        // y seteo el flag error a true
        if (typeof result.messages !== 'undefined') {
          result.messages.forEach(function(msg) {
            if (
              msg.severity.toLowerCase() === 'error' ||
              msg.severity.toLowerCase() === 'fatal'
            ) {
              hasError = true;
            }
          });
        }
        var messageSummary = [];

        if (!hasError) {
          // Baja el modal
          notify.FieloNotify.setTheme('success');
        }

        // Reemplazo caracteres especiales en los mensajes
        var specialChars = {
          '&gt;': '>',
          '&lt;': '<',
          '&amp;': '&',
          '&quot;': '"'
        };

        // Guardo los mensajes en un arreglo
        result.messages.forEach(function(msg) {
          var msgSummary = msg.summary;
          for (var char in specialChars) {
            if (specialChars.hasOwnProperty(char)) {
              var replaceChar = new RegExp(char, 'g');
              msgSummary = msgSummary.replace(replaceChar, specialChars[char]);
            }
          }
          if (msg.componentId === undefined) {
            messageSummary.push(msgSummary);
          } else if (this.elements_.hasOwnProperty(msg.componentId)) {
            this.elements_[msg.componentId]
              .FieloFormElement.setErrorMessage(msgSummary);
          } else {
            messageSummary.push(msgSummary);
          }
        }, this);

        if (!hasError) {
          // Baja el modal
          notify.FieloNotify.addMessages(messageSummary);
          notify.FieloNotify.show();
          $(this.element_).modal('dismiss');
          fielo.util.spinner.FieloSpinner.hide();

          if (this.redirect_ === 'true') {
            if (result.redirectURL !== '' && result.redirectURL !== undefined) {
              if (result.redirectURL === 'reload') {
                location.reload();
              } else {
                location.replace(result.redirectURL);
              }
            }
          }

          this.callback();
          return false;
        }

        notify = fielo.util.notify.create();
        notify.FieloNotify.addMessages([
          BackEndJSSettings.LABELS.ReviewFollowingErrors
        ]);
        notify.FieloNotify.setTheme('error');
        notify.FieloNotify.show(this.header_, false);

        // Pone el notification en el top
        if (messageSummary.length > 0) {
          notify = fielo.util.notify.create();
          notify.FieloNotify.addMessages([messageSummary]);
          notify.FieloNotify.setTheme('offline');
          notify.FieloNotify.show(this.header_, false);
        }
        messageSummary.length = 0;
      } else {
        notify.FieloNotify.addMessages([
          BackEndJSSettings.LABELS.ReviewFollowingErrors,
          event.message
        ]);
        notify.FieloNotify.setTheme('error');
        notify.FieloNotify.show();
      }
    } catch (e) {
      notify.FieloNotify.addMessages([
        BackEndJSSettings.LABELS.ReviewFollowingErrors,
        e
      ]);
      notify.FieloNotify.setTheme('error');
      notify.FieloNotify.show();
    }
    fielo.util.spinner.FieloSpinner.hide();
    if (result) {
      if (result.redirectURL && result.redirectURL === 'reload') {
        location.reload();
      } else if (
        result.redirectURL !== '' && result.redirectURL !== undefined
      ) {
        location.replace(result.redirectURL);
      }
    }
  };

  FieloForm.prototype.callback = function(records) {
    console.log(records);
  };

  /**
   * Envía el formulario
   */
  FieloForm.prototype.saveHandler_ = function() {
    if (this.canSave()) {
      if (this.saveButton_.wasConfirmed) {
        this.save_();
      }
    }
  };

  FieloForm.prototype.canSave = function () {
    return !this.saveButton_.element_.getAttribute('disabled');
  };

  FieloForm.prototype.disableSave = function () {
    this.saveButton_.element_.setAttribute('disabled', true);
  };

  FieloForm.prototype.enableSave = function () {
    this.saveButton_.element_.removeAttribute("disabled");
  };

  /**
   * Verifica si hay campos requeridos que no se hayan completado
   */

  FieloForm.prototype.checkRequiredPassOk_ = function() {
    this.requiredFailedElements_ = [];
    var fail = false;
    for (var element in this.elements_) {
      if (
        this.elements_.hasOwnProperty(element) &&
        this.elements_[element].FieloFormElement.required_ && (
          this.elements_[element].FieloFormElement.get('value') === null ||
          this.elements_[element].FieloFormElement.get('value') === ''
        )
      ) {
        this.requiredFailedElements_.push(this.elements_[element]);
        this.elements_[element].FieloFormElement.setErrorMessage();
        fail = true;
      }
    }

    if (fail) {
      return false;
    }
    return true;
  };

  /**
   * Envía el formulario
   */
  FieloForm.prototype.save_ = function() {
    this.disableSave();
    fielo.util.spinner.FieloSpinner.show();
    var notify;
    this.getValues_();
    if (this.recordId_) {
      this.data_.Id = this.recordId_;
    } else if (this.sObjectType_ && this.sObjectType_ !== '') {
      this.data_.sObjectType =
        this.sObjectType_;
    }

    if (this.data_.cloneId) {
      delete this.data_.cloneId;
    }

    if (this.checkRequiredPassOk_()) {
      // Arma el array de argumentos para el Invoke
      var invokeData = [];
      invokeData.push(this.saveController_);
      invokeData.push(this.data_);
      invokeData.push(this.nullFields_);
      for (var el in this.secondaryData_) {
        if (this.secondaryData_.hasOwnProperty(el)) {
          invokeData.push(this.secondaryData_[el]);
        }
      }
      invokeData.push(this.processRemoteActionResult_.bind(this));
      invokeData.push({
        escape: true
      });
      try {
        Visualforce.remoting.Manager.invokeAction.apply(
          Visualforce.remoting.Manager, invokeData
        );
      } catch (e) {
        this.enableSave();
        notify = fielo.util.notify.create();
        notify.FieloNotify.addMessages([
          BackEndJSSettings.LABELS.ReviewFollowingErrors,
          e
        ]);
        notify.FieloNotify.setTheme('error');
        notify.FieloNotify.show();
        fielo.util.spinner.FieloSpinner.hide();
      }
    } else {
      this.enableSave();
      notify = fielo.util.notify.create();
      notify.FieloNotify.addMessages([
        BackEndJSSettings.LABELS.CompleteRequiredFields
      ]);
      notify.FieloNotify.setTheme('error');
      notify.FieloNotify.show();
      fielo.util.spinner.FieloSpinner.hide();
    }
  };

  FieloForm.prototype.clear_ = function() {
    // Limpio los notify
    var headerMessages =
        this.header_.getElementsByClassName(this.CssClasses_.NOTIFY);
    while (headerMessages.length > 0) {
      headerMessages[0].FieloNotify.hide();
    }
    // limpio los elementos
    var elements =
      this.element_.getElementsByClassName(this.CssClasses_.ELEMENTS);
    [].forEach.call(
      elements,
      function(element) {
        var elemDefaultValue = element.getAttribute(this.Constant_.DEFAULT);
        if (elemDefaultValue === '') {
          element.FieloFormElement.clear();
          element.classList.remove(this.CssClasses_.ERROR);
        } else {
          element.FieloFormElement.set('value', elemDefaultValue);
        }
      }, this
    );
    // Se hace clear sobre el primer elemento del form para que quede el focus cuando se abre el form
    for (var i = 0; i < elements.length; i++) {
      var type = elements[i].FieloFormElement.get('type');
      if (type === 'lookup' || type.indexOf('input') !== -1) {
        var elemDefaultValue = elements[i].getAttribute(this.Constant_.DEFAULT);
        if (elemDefaultValue === '') {
          elements[i].FieloFormElement.clear();
        } else {
          elements[i].FieloFormElement.set('value', elemDefaultValue);
        }
        break;
      }
    }
  };

  FieloForm.prototype.setParameters_ = function() {
    for (var field in this.parameters_) {
      if (this.parameters_.hasOwnProperty(field) &&
          this.elements_.hasOwnProperty(field)) {
        this.elements_[field].FieloFormElement.set(
          'value',
          this.parameters_[field]
        );
      }
    }
  };

  /**
   * Trae los datos del registro
   * @param {event} source - current target
   *
   */
  FieloForm.prototype.retrieve_ = function(source) {
    // traigo los parameters del boton
    this.parameters_ = source.FieloButton.getParameters();

    // Setea parametros default en edit y new
    this.setParameters_();

    // 2 - Hacer retrieve si estoy en edit
    if (
      this.parameters_.hasOwnProperty('Id') ||
      this.parameters_.hasOwnProperty('cloneId')
    ) {
      this.isEditing = true;
      this.recordId_ = this.parameters_.Id;

      var retrieveRecordId = this.parameters_.Id || this.parameters_.cloneId;

      // Si es un record busca los datos y los setea
      var fields = this.element_.getAttribute(this.Constant_.FIELDS);
      var objectName = this.element_.getAttribute(this.Constant_.OBJECT_NAME);
      Visualforce.remoting.Manager.invokeAction(
        this.retrieveController_,
        objectName,
        retrieveRecordId,
        fields,
        this.retrieveHandler_.bind(this),
        {escape: false}
      );
    } else {
      this.isEditing = false;
      this.setParameters_();
      this.endRetrieve();
    }
  };

  FieloForm.prototype.retrieveProxy_ = function(modal, source) {
    modal.FieloForm.clear_();
    modal.FieloForm.retrieve_(source);
  };
  window.FieloForm_retrieve = FieloForm.prototype.retrieveProxy_; // eslint-disable-line camelcase

  /**
   * Callback interno para retrieveRecords_
   * @param {sObject} result - record
   * @param {event} event - status ajax
   *
   */
  FieloForm.prototype.retrieveHandler_ = function(result) {
    fielo.util.spinner.FieloSpinner.show();
    this.result = result;
    try {
      // analizo si hay listas
      // preparo un hash para representar los campos que tienen listas
      var hash = '|';
      for (var field in result) {
        if (result.hasOwnProperty(field) && field.indexOf('__r') > -1) {
          hash += field.slice(0, -1) + 'c|';
        }
      }

      this.fields_.forEach(function(field) {
        // si es una lista
        if(field){
          if (hash.indexOf(field) > -1) {
            var values;
            switch (typeof result[field.slice(0, -1) + 'r']) {
              case 'object':
                // es un objeto que en su propiedad field contiene un string con id separados por ;
                // siguiendo el formato de salesforce
                // hay que parsear la informacion para pasarlo a la interfaz normal
                values = result[field.slice(0, -1) + 'r'];
                // busco la clave que contiene el campo __c
                var __c;
                for (var key in values) {
                  if (values.hasOwnProperty(key) && key.indexOf('__c') > -1) {
                    __c = key;
                    break;
                  }
                }
                if (__c) {
                  values = values[__c].split(';');
                } else {
                  values = result[field];
                }
                break;
              case 'array':
              default:
                // una interfaz normal
                values = result[field.slice(0, -1) + 'r'];
                break;
            }
            this.elements_[field].FieloFormElement.set('value', values);
          } else if (this.elements_[field]) {
            // if it's date type onli we parse it to have a date without timestamp
            // DON'T add datetime type here. It won't  match GMT
            if (
              this.elements_[field].FieloFormElement.get('type') === 'input-date'
            ) {
              result[field] = fielo.util.parseDateFromSF(result[field]);
            }
            this.elements_[field].FieloFormElement.set('value', result[field]);
          }
        }
      }, this);
      // 3 - Pisar con los parameters de source en edit y new
      this.setParameters_();
      this.endRetrieve();
    } catch (e) {
      var notify = fielo.util.notify.create();
      notify.FieloNotify.addMessages([
        BackEndJSSettings.LABELS.ReviewFollowingErrors,
        e
      ]);
      notify.FieloNotify.setTheme('error');
      notify.FieloNotify.show();
    }
    // Hago focus en el primer elemento del form
    var elements =
      this.element_.getElementsByClassName(this.CssClasses_.ELEMENTS);
    for (var i = 0; i < elements.length; i++) {
      var type = elements[i].FieloFormElement.get('type');
      if (type === 'lookup' || type.indexOf('input') !== -1) {
        elements[i].getElementsByClassName(this.CssClasses_.INPUT)[0].focus();
        break;
      }
    }
    fielo.util.spinner.FieloSpinner.hide();
  };

  /**
   * Inicializa el formulario
   */
  FieloForm.prototype.init = function() {
    if (this.element_) {
      // Hooks
      this.endRetrieve = function() {};

      this.setDefaults_();
    }
  };

  // registro el componente en fielo.helper
  fielo.helper.register({
    constructor: FieloForm,
    classAsString: 'FieloForm',
    cssClass: 'slds-form',
    widget: true
  });
})();
