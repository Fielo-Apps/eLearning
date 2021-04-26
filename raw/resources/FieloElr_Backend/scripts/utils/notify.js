(function() {
  'use strict';

  /**
   * @description Clase constructora para los notifys.
   * Fielo Notify activa las funcionalidades para los mensajes de notify
   * Implementa los patrones de diseño definidos por MDL en
   * {@link https://github.com/jasonmayes/mdl-component-design-pattern}
   *
   * @version 1
   * @author Hugo Gómez Mac Gregor <hugo.gomez@fielo.com>
   * @param {HTMLElement} element - Elemento que será mejorado.
   * @constructor
   */

  var FieloNotify = function FieloNotify(element) {
    this.element_ = element;

    // Initialize instance.
    this.init();
  };
  window.FieloNotify = FieloNotify;

  /**
   * Guarda las constantes en un lugar para que sean facilmente actualizadas
   * @enum {string | number}
   * @private
   */
  FieloNotify.prototype.Constant_ = {};

  /**
   * Guarda strings para nombres de clases definidas por este componente que son usadas por JavaScript.
   * Esto nos permite cambiarlos solo en un lugar
   * @enum {string}
   * @private
   */
  FieloNotify.prototype.CssClasses_ = {
    /** Botón para cerrar el alert */
    CLOSE: 'slds-notify__close',
    /** Botón para volver a la etapa anterior */
    BACK: 'fielosf-notify__back',
    /** Botón para ir a la etapa siguiente */
    CONTINUE: 'fielosf-notify__continue',
    /** Elemento que contiene los mensajes de error */
    MESSAGE: 'fielosf-notify__message',
    /** Elemento que contiene el ícono de notify */
    ICON: 'fielosf-notify__icon',
    /** Tipos de notify */
    TYPE_ALERT: 'slds-notify--alert',
    TYPE_TOAST: 'slds-notify--toast',
    /** Themes de errores */
    THEME_SUCCESS: 'slds-theme--success',
    THEME_ERROR: 'slds-theme--error',
    THEME_WARNING: 'slds-theme--warning',
    THEME_OFFLINE: 'slds-theme--offline'
  };

  /**
   * Muestra el notify
   *
   * @public
   */

  FieloNotify.prototype.show = function(container, clear) {
    if (typeof container === 'undefined') {
      this.container_ = fielo.util.notify.container;
      this.setType('toast');
    } else {
      this.container_ = container;
    }
    this.container_.appendChild(this.element_);
    if (typeof clear === 'undefined') {
      clear = true;
    }
    if (clear) {
      var delay;
      switch (this.theme_) {
        case this.CssClasses_.THEME_SUCCESS:
          delay = 10000;
          break;
        case this.CssClasses_.THEME_ERROR:
          delay = 10000;
          break;
        case this.CssClasses_.THEME_OFFLINE:
          delay = 10000;
          break;
        default:
          delay = 10000;
      }
      setTimeout(
        function() {
          this.hide();
        }.bind(this),
        delay
      );
    }
  };

  /**
   * Oculta el notify
   *
   * @public
   */
  FieloNotify.prototype.hide = function() {
    this.element_.remove();
  };

  /**
   * Agrega mensaje de error
   *
   * @param {array} messages - Lista de mensajes a agregar
   * @public
   */
  FieloNotify.prototype.addMessages = function(messages) {
    messages.forEach(function(msg, index) {
      if (msg === null) {
        messages.splice(index, 1);
      }
    });
    messages.forEach(function(item) {
      var p = document.createElement("p");
      p.innerHTML = '<strong>' + fielo.util.unescapeHTML(fielo.util.escapeHTML(item)) + '</strong>';
      this.messageContainer_.appendChild(p);
    }, this);
  };
  /**
   * Guarda el theme de notify
   *
   * @param {string} type - Tipo de notify
   * @public
   */
  FieloNotify.prototype.setTheme = function(type) {
    this.element_.classList.remove(
      this.CssClasses_.THEME_SUCCESS,
      this.CssClasses_.THEME_ERROR,
      this.CssClasses_.THEME_WARNING,
      this.CssClasses_.THEME_OFFLINE
    );
    switch (type.toLowerCase()) {
      case 'success':
      case 'info':
      case 'confirm':
        type = this.CssClasses_.THEME_SUCCESS;
        break;
      case 'error':
        type = this.CssClasses_.THEME_ERROR;
        break;
      case 'warning':
        type = this.CssClasses_.THEME_WARNING;
        break;
      case 'offline':
      default:
        type = this.CssClasses_.THEME_OFFLINE;
    }
    this.theme_ = type;
    this.element_.classList.add(type);
  };

  /**
   * Guarda el tipo de notify
   *
   * @param {string} type - Tipo de notify
   * @public
   */
  FieloNotify.prototype.setType = function(type) {
    this.element_.classList.remove(
      this.CssClasses_.TYPE_TOAST,
      this.CssClasses_.TYPE_ALERT
    );

    switch (type.toLowerCase()) {
      case 'toast':
        type = this.CssClasses_.TYPE_TOAST;
        break;
      case 'alert':
        type = this.CssClasses_.TYPE_ALERT;
        break;
      default:
        type = this.CssClasses_.TYPE_TOAST;
    }
    this.element_.classList.add(type);
  };

  /**
   * Guarda el ícono
   *
   * @param {string} icon - Icono a mostrar
   * @public
   */
  FieloNotify.prototype.setIcon = function(icon) {
    if (this.iconContainer_) {
      this.iconContainer_.setAttribute('xlink:href', icon);
    }
  };

  /**
   * Inicializa el elemento
   */
  FieloNotify.prototype.init = function() {
    if (this.element_) {
      // Registro el boton para cerrar
      this.btnClose_ =
        this.element_.querySelector('.' + this.CssClasses_.CLOSE);

      // Registro el boton para la etapa anterior
      this.btnBack_ =
        this.element_.querySelector('.' + this.CssClasses_.BACK);

      // Registro el boton para la etapa siguiente
      this.btnContinue_ =
        this.element_.querySelector('.' + this.CssClasses_.CONTINUE);

      // Registro el elemento donde se muestra el mensaje
      this.messageContainer_ =
        this.element_.querySelector('.' + this.CssClasses_.MESSAGE);
      // Registro el elemento donde se encuentra el ícono
      this.iconContainer_ =
        this.element_.querySelector('.' + this.CssClasses_.ICON);

      // Vinculo la escucha con el click Handler
      if (this.btnClose_) {
        this.btnClose_.addEventListener('click', this.hide.bind(this));
      }

      // Seteo icono por defecto
      this.setIcon(
        BackEndJSSettings.RESOURCE.BACKEND +
        '/lightning/icons/utility-sprite/svg/symbols.svg#close'
      );

      this.setType(this.CssClasses_.TYPE_ALERT);
    }
  };

  // registro el componente en fielo.util
  fielo.util.register({
    constructor: FieloNotify,
    classAsString: 'FieloNotify',
    cssClass: 'slds-notify',
    widget: true
  });

  // Lo registro en fielo.util
  window.fielo.util.notify = {
    createContainer: function() {
      var markup = document.createElement('div');
      markup.setAttribute(
        'class',
        'slds-notify_container slds-notify_container--main'
      );
      document.getElementsByClassName('fielosf')[0].appendChild(markup);
      window.fielo.util.notify.container = markup;
    },
    create: function() {
      var markup = document.createElement('div');
      markup.classList.add('slds-notify');
      markup.innerHTML =
        '<button ' +
          'class="slds-button slds-notify__close slds-button--icon-inverse"' +
          ' title="' + BackEndJSSettings.LABELS.Close + '">' +
          '<svg aria-hidden="true" class="slds-button__icon">' +
            '<use class="fielosf-notify__icon" xlink:href=""></use>' +
          '</svg>' +
          '<span class="slds-assistive-text">' +
            BackEndJSSettings.LABELS.Close + '</span>' +
        '</button>' +
        '<div class="fielosf-notify__message"></div>';
      componentHandler.upgradeElement(markup);
      return markup;
    }
  };
})();
