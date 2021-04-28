(function() {
  'use strict';

  /**
   * @description Clase constructora para los Botones.
   * Fielo Button activa las funcionalidades para los botones
   * Implementa los patrones de diseño definidos por MDL en
   * {@link https://github.com/jasonmayes/mdl-component-design-pattern}
   *
   * @version 1
   * @author Hugo Gómez Mac Gregor <hugo.gomez@fielo.com>
   * @param {HTMLElement} element - Elemento que será mejorado.
   * @constructor
   */
  var FieloButton = function FieloButton(element) {
    this.element_ = element;

    // Initialize instance.
    this.init();
  };
  window.FieloButton = FieloButton;

  /*
   * Guarda las constantes en un lugar para que sean facilmente actualizadas
   * @enum {string | number}
   * @private
   */
  FieloButton.prototype.Constant_ = {
    ACTION: 'data-action',
    CONFIRM: 'data-confirm',
    CONFIRM_MESSAGE: 'data-confirm-message',
    HAS_ERROR: BackEndJSSettings.LABELS.ReviewFollowingErrors,
    PARAMETERS: 'data-parameters',
    SURE: BackEndJSSettings.LABELS.Areyousure,
    TYPE: 'data-type',
    REFLECTION: 'data-reflection',
    RECORD: 'data-record',
    VIS_FIELD: 'data-vis-field',
    VIS_VALUE: 'data-vis-value'
  };

  /**
   * Guarda strings para nombres de clases definidas por este componente que son usadas por JavaScript.
   * Esto nos permite cambiarlos solo en un lugar
   * @enum {string}
   * @private
   */
  FieloButton.prototype.CssClasses_ = {};

  /**
   * Deshabilita el boton
   *
   * @public
   */
  FieloButton.prototype.disable = function() {
    this.element_.setAttribute('disabled', '');
  };

  /**
   * Habilita el boton
   *
   * @public
   */
  FieloButton.prototype.enable = function() {
    this.element_.removeAttribute('disabled');
  };

  /**
   * Habilita el boton
   *
   * @public
   */
  FieloButton.prototype.setupRemote_ = function() {
    this.action_ = this.element_.getAttribute(this.Constant_.ACTION) || null;
    if (this.action_) {
      this.type_ = this.element_.getAttribute(this.Constant_.TYPE) || null;
    }
  };

  /**
   * Getter de parameters
   *
   * @public
   * @return {json} objeto con los parametros o null
   */
  FieloButton.prototype.getParameters = function() {
    return this.parameters_;
  };

  FieloButton.prototype.setParameter = function(key, value) {
    this.parameters_[key] = value;
    this.element_.setAttribute(
      this.Constant_.PARAMETERS,
      JSON.stringify(this.parameters_)
    );
  };

  FieloButton.prototype.clearParameters = function() {
    this.parameters_ = {};
    this.element_.setAttribute(
      this.Constant_.PARAMETERS,
      ''
    );
  };

  /**
   * Configura el confirm
   *
   * @public
   */
  FieloButton.prototype.setupConfirm_ = function() {
    this.confirm_ =
      this.element_.getAttribute(this.Constant_.CONFIRM) === 'true';
    if (this.confirm_) {
      this.confirmMessage =
        this.element_.getAttribute(this.Constant_.CONFIRM_MESSAGE) ||
        this.Constant_.SURE;
      this.wasConfirmed = false;
    }
  };

  FieloButton.prototype.processHandler_ = function(result, event) {
    fielo.util.spinner.FieloSpinner.hide();
    var hasError = false;
    var messageMap = {}
    // Si existen mensajes verifico si hay alguno de error
    // y seteo el flag error a true
    if (result) {
      if (
        typeof result.messages !== 'undefined' && result.messages.length > 0
      ) {
        result.messages.forEach(function(msg) {
          if (
            msg.severity.toLowerCase() === 'error' ||
            msg.severity.toLowerCase() === 'fatal'
          ) {
            hasError = true;
            if (messageMap && messageMap['error'] && messageMap['error'].length) {
              messageMap['error'].push(msg.summary);
            } else {
              messageMap['error'] = [msg.summary];
            }
          } else {
            if (messageMap && messageMap[msg.severity.toLowerCase()] && messageMap[msg.severity.toLowerCase()].length) {
              messageMap[msg.severity.toLowerCase()].push(msg.summary);
            } else {
              messageMap[msg.severity.toLowerCase()] = [msg.summary];
            }
          }
        });
      }
    } else {
      hasError = true;
    }

    // Si no hay errores
    if (result) {
      Object.keys(messageMap).forEach(function(msgSeverity) {
        var notify = fielo.util.notify.create();
        var messageSummary = [];

        if (msgSeverity == 'error') {
          // Guardo los mensajes en un arreglo
          messageSummary.push(this.Constant_.HAS_ERROR);
          notify.FieloNotify.setTheme('error');
        } else {
          // Baja el modal
          notify.FieloNotify.setTheme(msgSeverity ? msgSeverity : 'success');
        }

        messageMap[msgSeverity].forEach(function(msg) {
          messageSummary.push(msg);
        }, this);
        
        notify.FieloNotify.addMessages(messageSummary);
    
        notify.FieloNotify.show();
      }.bind(this));
    } else {
      var notify = fielo.util.notify.create();
      var messageSummary = [];
      messageSummary.push(event.message);
      notify.FieloNotify.addMessages(messageSummary);
      notify.FieloNotify.show();
    }

    if (result) {
      if (result.redirectURL && result.redirectURL === 'reload') {
        if(hasError || messageMap['warning']){
          setTimeout(
            $A.getCallback(function() {
              location.reload();
            }),
            10000
          );
        }else{
          location.reload();
        }
      } else if (
        result.redirectURL !== '' && result.redirectURL !== undefined
      ) {
        location.replace(result.redirectURL);
      } else {
        this.callback();
      }
    }
  };

  FieloButton.prototype.setupVisibility_ = function () {
    this.visField = this.element_.getAttribute(this.Constant_.VIS_FIELD);
    this.visValue = this.element_.getAttribute(this.Constant_.VIS_VALUE);
    if (this.element_.getAttribute(this.Constant_.RECORD) && this.visField && this.visValue) {
      this.record_ = JSON.parse(this.element_.getAttribute(this.Constant_.RECORD));
      var value = this.record_;
      [].forEach.call(this.visField.split('.'), function (fieldPath) {
        value = value[fieldPath];
      });
      if (value != this.visValue) {
        $(this.element_).toggle(false);
      }
    }
  };

  /**
   * Handler del click
   *
   * @public
   * @param {Event} click - Click realizado al botón
   * @return {Bool} Retorna false si el confirm es false
   */
  FieloButton.prototype.clickHandler_ = function(click) {
    if (this.confirm_ && !confirm(this.confirmMessage)) {
      this.wasConfirmed = false;
      click.stopPropagation();
      click.preventDefault();
      return false;
    } else {
      this.wasConfirmed = true;
      if (this.action_) {
        switch (this.type_) {
          case 'Remote' || 'RemoteList':
            fielo.util.spinner.FieloSpinner.show();
            try {
              if (this.reflection_) {
                Visualforce.remoting.Manager.invokeAction(
                  this.action_,
                  (this.type_ === 'Remote') ? this.recordId_ : { },
                  this.reflection_,
                  JSON.stringify(this.parameters_),
                  this.processHandler_.bind(this),
                  {
                    escape: false
                  }
                );
              } else {
                Visualforce.remoting.Manager.invokeAction(
                  this.action_,
                  (this.type_ === 'Remote') ? this.recordId_ : { },
                  this.processHandler_.bind(this),
                  {
                    escape: false
                  }
                );
              }
            } catch (e) {
              fielo.util.spinner.FieloSpinner.hide();
              console.warn(e);
            }
            break;
          default:
            // TODO CASO DEFAULT DE ACTION
        }
      }
    }
  };

  // Tiene que ser definido
  FieloButton.prototype.callback = function(records) {
    console.log(records);
  };

  /**
   * Inicializa el elemento
   */
  FieloButton.prototype.init = function() {
    if (this.element_) {
      this.element_.addEventListener('click', this.clickHandler_.bind(this));
      this.parameters_ =
        this.element_.getAttribute(this.Constant_.PARAMETERS) || null;
      this.reflection_ =
        this.element_.getAttribute(this.Constant_.REFLECTION) || null;
      if (this.parameters_) {
        this.parameters_ = JSON.parse(this.parameters_.replace(/'/g, '"'));
        this.recordId_ = this.parameters_.Id || null;
      } else {
        this.parameters_ = {};
      }
      this.setupRemote_();
      this.setupConfirm_();
      this.setupVisibility_();
    }
  };

  // El componente se registra por si solo.
  // Asume que el componentHandler esta habilitado en el scope global
  componentHandler.register({
    constructor: FieloButton,
    classAsString: 'FieloButton',
    cssClass: 'slds-button',
    widget: true
  });
})();
