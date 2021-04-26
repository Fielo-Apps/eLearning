(function() {
  'use strict';

  /**
   * @description Clase constructora para los elementos de un formulario
   * Fielo FormElement activa las funcionalidades para los elementos del formulario
   * Implementa los patrones de diseño definidos por MDL en
   * {@link https://github.com/jasonmayes/mdl-component-design-pattern}
   *
   * @version 1
   * @author Hugo Gómez Mac Gregor <hugo.gomez@fielo.com>
   * @param {HTMLElement} element - Elemento que será mejorado.
   * @constructor
   */

  var FieloFormElement = function FieloFormElement(element) {
    this.element_ = element;

    // Initialize instance.
    this.init();
  };
  window.FieloFormElement = FieloFormElement;

  /**
   * Guarda las constantes en un lugar para que sean facilmente actualizadas
   * @enum {string | number}
   * @private
   */
  FieloFormElement.prototype.Constant_ = {
    COMPONENT_ID: 'data-component-id',
    CONTROLLER_ELEMENT: 'data-controller-element',
    FIELD_ID: 'data-field-id',
    FIELD_LABEL: 'data-field-label',
    FIELD_META: 'data-field-meta',
    FIELD_NAME: 'data-field-name',
    TIMEZONE_FIX: 'data-timezone-fix',
    FORM_ID: 'data-id',
    LOOKUP_ITEMS: 'data-items',
    OBJECT_LABEL: 'data-object-label',
    OBJECT_NAME: 'data-object-name',
    OBJECT_PLURAL_LABEL: 'data-object-plural-label',
    ON_CHANGE: 'data-on-change',
    OPTIONS_GETTER: 'data-options-getter',
    OPTIONS: 'data-options',
    PICKLIST_CONTROLLER: (BackEndJSSettings.RESOURCE.NAMESPACE === '.') ?
      'PicklistController.getRecords' :
      BackEndJSSettings.RESOURCE.NAMESPACE + 'PicklistController.getRecords',
    PICKLIST_CONTROLLER_RECORD: (BackEndJSSettings.RESOURCE.NAMESPACE === '.') ?
      'PicklistController.getName' :
      BackEndJSSettings.RESOURCE.NAMESPACE + 'PicklistController.getName',
    REQUIRED: 'data-required',
    TYPE: 'data-type',
    VALID_FOR: 'data-valid-for',
    VALUE: 'data-value',
    WHERE_CONDITION: 'data-where'
  };

  /**
   * Guarda strings para nombres de clases definidas por este componente que son usadas por JavaScript.
   * Esto nos permite cambiarlos solo en un lugar
   * @enum {string}
   * @private
   */
  FieloFormElement.prototype.CssClasses_ = {
    CONTROL: 'slds-form-element__control',
    CHECKBOX: 'slds-checkbox',
    DATE: 'slds-date',
    DATE_TIME: 'slds-datetime',
    DATE_PICKER: 'fielosf-date-picker',
    DATE_PICKER_FAUX: 'fielosf-date-picker--faux',
    DROPDOWN_LIST: 'slds-dropdown__list',
    DROPDOWN_ITEM: 'slds-dropdown__item',
    VOID_ITEM: 'slds-dropdown__item--void',
    ERROR: 'slds-has-error',
    HAS_ICON: 'slds-input-has-icon',
    HELP: 'slds-form-element__help',
    HIDE: 'slds-hide',
    ICON: 'slds-form-element__icon',
    ICON_LEFT: 'slds-input-has-icon--left',
    ICON_RIGHT: 'slds-input-has-icon--right',
    INPUT: 'slds-input',
    LABEL: 'slds-form-element__label',
    LOOKUP: 'slds-lookup__search-input',
    PICKLIST: 'slds-picklist',
    MULTISELECT: 'slds-picklist--draggable',
    PICKLIST_LABEL: 'slds-picklist__label',
    POP_OVER: 'slds-popover',
    RADIO_GROUP: 'slds-radio--button-group',
    RADIO_LABEL: 'slds-radio--button__label',
    READ_ONLY: 'slds-form-element__static',
    SVG: 'slds-button__icon',
    SELECTED: 'slds-is-selected'
  };

  /**
   * Agrega mensaje de error
   *
   * @param {string} message - Lista de mensajes a agregar
   * @public
   */
  FieloFormElement.prototype.setErrorMessage = function(message) {
    if (this.help_) {
      if (message) {
        this.help_.innerHTML = message;
      }
      this.element_.classList.add(this.CssClasses_.ERROR);
      this.help_.classList.remove(this.CssClasses_.HIDE);
    }
  };

  /**
   * Limpia mensaje de error
   *
   * @public
   */
  FieloFormElement.prototype.clean = function() {
    if (this.help_) {
      this.help_.innerHTML = '';
      this.element_.classList.remove(this.CssClasses_.ERROR);
      this.help_.classList.add(this.CssClasses_.HIDE);
    }
  };

  /**
   * Arma el hover del icono para mostrar el help
   *
   * @public
   */
  FieloFormElement.prototype.setIconHover_ = function() {
    this.icon_.addEventListener('mouseover', this.showPopover.bind(this));
    this.icon_.addEventListener('mouseout', this.hidePopover.bind(this));
  };

  /**
   * Muestra y posiciona el popover sobre el ícono
   */
  FieloFormElement.prototype.showPopover = function() {
    this.popover_.style.position = 'absolute';
    this.popover_.style.left = '7px';
    this.popover_.style.margin = '-1.5rem';
    this.popover_.style.width = '40rem';

    this.popover_.style.top = (this.popover_.offsetHeight - 18) + 'px';
    this.popover_.classList.remove(this.CssClasses_.HIDE);
  };

  /**
   * Oculta el popover
   */
  FieloFormElement.prototype.hidePopover = function() {
    this.popover_.classList.add(this.CssClasses_.HIDE);
  };

  /**
   *
   * Config de elementos
   *
   */

  /**
   * Inicializa el datepicker
   */
  FieloFormElement.prototype.configDatepicker_ = function() {
    var dateFormat = BackEndJSSettings.DATE_FORMAT;

    switch (this.type_) {
      case 'input-datetime':
        this.input_ =
          this.element_.getElementsByClassName(this.CssClasses_.DATE_TIME)[0];
        dateFormat = BackEndJSSettings.DATETIME_FORMAT;
        break;
      default:
      // date
        this.input_ =
          this.element_.getElementsByClassName(this.CssClasses_.DATE)[0];
        break;
    }

    this.defaultConfig_ = this.defaultConfig_ || {};
    this.defaultConfig_.format = dateFormat;
    if (this.input_.value !== '') {
      this.defaultConfig_.initDate = moment(this.input_.value);
    }

    this.defaultConfig_.dayLabels = [
      {
        full: moment.weekdays()[0],
        abbr: moment.weekdaysShort()[0]
      },
      {
        full: moment.weekdays()[1],
        abbr: moment.weekdaysShort()[1]
      },
      {
        full: moment.weekdays()[2],
        abbr: moment.weekdaysShort()[2]
      },
      {
        full: moment.weekdays()[3],
        abbr: moment.weekdaysShort()[3]
      },
      {
        full: moment.weekdays()[4],
        abbr: moment.weekdaysShort()[4]
      },
      {
        full: moment.weekdays()[5],
        abbr: moment.weekdaysShort()[5]
      },
      {
        full: moment.weekdays()[6],
        abbr: moment.weekdaysShort()[6]
      }
    ];
    this.defaultConfig_.monthLabels = [
      {
        full: moment.months()[0],
        abbr: moment.monthsShort()[0]
      },
      {
        full: moment.months()[1],
        abbr: moment.monthsShort()[1]
      },
      {
        full: moment.months()[2],
        abbr: moment.monthsShort()[2]
      },
      {
        full: moment.months()[3],
        abbr: moment.monthsShort()[3]
      },
      {
        full: moment.months()[4],
        abbr: moment.monthsShort()[4]
      },
      {
        full: moment.months()[5],
        abbr: moment.monthsShort()[5]
      },
      {
        full: moment.months()[6],
        abbr: moment.monthsShort()[6]
      },
      {
        full: moment.months()[7],
        abbr: moment.monthsShort()[7]
      },
      {
        full: moment.months()[8],
        abbr: moment.monthsShort()[8]
      },
      {
        full: moment.months()[9],
        abbr: moment.monthsShort()[9]
      },
      {
        full: moment.months()[10],
        abbr: moment.monthsShort()[10]
      },
      {
        full: moment.months()[11],
        abbr: moment.monthsShort()[11]
      }
    ];

    this.hiddenPicker_ =
      this.element_.getElementsByClassName(this.CssClasses_.DATE_PICKER)[0];

    $(this.input_).datepicker(this.defaultConfig_);

    this.picker_ = this.element_
      .getElementsByClassName(this.CssClasses_.DATE_PICKER_FAUX)[0];

    this.picker_.addEventListener('click', function(click) {
      click.stopPropagation();
      $(this.input_).prev('svg').trigger('click');
    }.bind(this));

    if (this.input_.value !== '') {
      this.set('value', fielo.util.parseDateFromSF(this.input_.value));
    }

    this.disableTimezoneFix_ =
        this.element_.getAttribute(this.Constant_.TIMEZONE_FIX) || null;

    if (this.fieldName_ == 'FieloELR__StartDate__c' ||
    this.fieldName_ == 'FieloELR__EndDate__c') {
      this.disableTimezoneFix_ = true;
    }
  };

  /**
   * Inicializa el picklist
   */
  FieloFormElement.prototype.configPicklist_ = function() {
    this.input_ =
      this.element_.getElementsByClassName(this.CssClasses_.PICKLIST)[0];
    this.elementList_ =
      this.element_.getElementsByClassName(this.CssClasses_.DROPDOWN_LIST)[0];
    this.elementListItems_ = this.elementList_
      .getElementsByClassName(this.CssClasses_.DROPDOWN_ITEM);

    var optionNumber = 0;
    [].forEach.call(this.elementListItems_, function(elem) {
      elem.id = 'option-' + optionNumber;
      optionNumber++;
    });
    this.voidItem_ = this.elementList_
      .getElementsByClassName(this.CssClasses_.VOID_ITEM)[0];

    this.label_ = this.element_.querySelector(
      '.' + this.CssClasses_.PICKLIST_LABEL + ' span'
    );

    this.labelValue_ = String(this.label_.textContent).trim();

    this.defaultConfig_ = {
      onChange: this.onChange_.bind(this)
    };

    $(this.input_).picklist(this.defaultConfig_);

    if (this.validFor_) {
      this.hideItems_();
    }
  };

  /**
   * Inicializa el multiSelect
   */
  FieloFormElement.prototype.configMultiselect_ = function() {
    this.input_ =
      this.element_.getElementsByClassName(this.CssClasses_.MULTISELECT)[0];
    var values = {};
    values.unselectedItems = this.setDataOptions_() || [];
    values.selectedItems = [];
    $(this.input_).unbind().removeData();
    var options = this.input_.getElementsByTagName('li');
    while (options.length > 0) {
      $(options[0]).remove();
      options = this.input_.getElementsByTagName('li');
    }

    $(this.input_).multiSelect(values);
  };

  /**
   * Inicializa el radio
   */
  FieloFormElement.prototype.configRadio_ = function() {
    this.input_ = null;

    this.elementListItems_ = this.element_.getElementsByTagName('input');

    [].forEach.call(this.elementListItems_, function(input) {
      input.addEventListener('change', this.onChange_.bind(this));
    }, this);
  };

  /**
   * Inicializa el checkbox
   */
  FieloFormElement.prototype.configCheckbox_ = function() {
    this.input_ = this.element_.getElementsByTagName('input')[0];
    this.input_.addEventListener('change', this.onChange_.bind(this));
  };

  /**
   * Inicializa el checkbox
   */
  FieloFormElement.prototype.configCheckboxes_ = function() {
    this.elementList_ =
      this.element_.getElementsByClassName(this.CssClasses_.CONTROL)[0];
    this.elementListItems_ = this.elementList_.getElementsByClassName(
      this.CssClasses_.CHECKBOX
    );
    this.initCheckboxesInputs_();
  };

  FieloFormElement.prototype.initCheckboxesInputs_ = function() {
    this.inputs_ = this.element_.getElementsByTagName('input');
    [].forEach.call(this.inputs_, function(input) {
      input.addEventListener('change', this.onChange_.bind(this));
    }, this);
    if (this.validFor_) {
      this.hideItems_();
    }
  };

  /**
   * Inicializa el richtext
   */
  FieloFormElement.prototype.configRichtext_ = function() {
    this.input_ =
      this.element_.getElementsByClassName(this.CssClasses_.INPUT)[0];
    // QUEDA PENDIENTE LA CONFIGURACION
    CKEDITOR.replace(this.input_, FIELO_CKEDITOR_CONFIG);
  };

  /**
   * Inicializa el lookup
   */
  FieloFormElement.prototype.configLookup_ = function() {
    this.input_ =
      this.element_.getElementsByClassName(this.CssClasses_.LOOKUP)[0];

    this.objectName_ =
      this.element_.getAttribute(this.Constant_.OBJECT_NAME) || null;

    this.fieldId_ = this.element_.getAttribute(this.Constant_.FIELD_ID) || 'id';

    this.fieldLabel_ =
      this.element_.getAttribute(this.Constant_.FIELD_LABEL) || 'name';

    this.fieldMeta_ =
      this.element_.getAttribute(this.Constant_.FIELD_META) || null;

    this.whereCondition_ =
      this.element_.getAttribute(this.Constant_.WHERE_CONDITION) || '';

    this.items_ =
      this.element_.getAttribute(this.Constant_.LOOKUP_ITEMS) || null;
    if (this.items_) {
      this.items_ = JSON.parse(this.items_.replace(/'/g, '"'));
    }

    // Construyo configuración
    var config = {};
    // config.showSearch = true;

    if (this.objectName_) {
      config.emptySearchTermQuery = this.lookupEmptySearchTermQuery_.bind(this);
      config.filledSearchTermQuery = this.getLookupRecords_.bind(this);
    } else {
      config.items = this.items_;
    }
    config.objectLabel =
      this.element_.getAttribute(this.Constant_.OBJECT_LABEL) || null;
    config.objectPluralLabel =
       this.element_.getAttribute(this.Constant_.OBJECT_PLURAL_LABEL) || null;
    if (this.onChangeHook_) {
      config.onChange = window[this.onChangeHook_].bind(this);
    }

    $(this.input_).lookup(config);
  };

  /**
   * Inicializa el input
   */
  FieloFormElement.prototype.configInput_ = function() {
    this.input_ = this.element_.querySelector('input, textarea, select');
    if (this.onChangeHook_) {
      this.input_.addEventListener(
        'change',
        window[this.onChangeHook_].bind(this)
      );
    }
  };

  FieloFormElement.prototype.lookupEmptySearchTermQuery_ = function(render) {
    if (this.items_) {
      render(this.items_);
    }
  };

  FieloFormElement.prototype.setLookupValue_ = function(id, element) {
    try {
      Visualforce.remoting.Manager.invokeAction(
        this.Constant_.PICKLIST_CONTROLLER_RECORD,
        id,
        function(result) {
          $(element.input_).lookup(
            'setSelection',
            {
              id: result.Id,
              label: result.Name
            }
          );
        },
        {
          escape: true
        }
      );
    } catch (e) {
      console.warn(e);
    }
  };

  FieloFormElement.prototype.getLookupRecords_ = function(searchTerm, render) {
    try {
      Visualforce.remoting.Manager.invokeAction(
        this.Constant_.PICKLIST_CONTROLLER,
        this.objectName_,
        this.fieldId_,
        this.fieldLabel_,
        this.fieldMeta_,
        this.whereCondition_,
        searchTerm,
        this.processLookupRecords_.bind(this, render),
        {
          escape: true
        }
      );
    } catch (e) {
      console.warn(e);
    }
  };

  FieloFormElement.prototype.processLookupRecords_ = function(
    render, result, event
  ) {
    try {
      if (event.status && result !== undefined) {
        var items = [];
        if (this.fieldMeta_) {
          [].forEach.call(result, function(record) {
            items.push({
              id: record[this.fieldId_],
              label: fielo.util.unescapeHTML(record[this.fieldLabel_]),
              metaLabel: fielo.util.unescapeHTML(record[this.fieldMeta_])
            });
          }, this);
        } else {
          [].forEach.call(result, function(record) {
            items.push({
              id: fielo.util.unescapeHTML(record[this.fieldId_]),
              label: fielo.util.unescapeHTML(record[this.fieldLabel_])
            });
          }, this);
        }
        render(items);
      } else {
        // fieloUtils.debug.log(event);
      }
    } catch (e) {
      throw (e);
    }
  };
  /**
   *
   * Render de elementos
   *
   */

  FieloFormElement.prototype.clearOptions_ = function() {
    switch (this.type_) {
      case 'picklist':
        if (this.optionsGetter_) {
          this.disable_();
          while (this.elementList_.firstChild) {
            this.elementList_.removeChild(this.elementList_.firstChild);
          }
        }
        break;
      default:
    }
  };
  /**
   * Renderiza el picklist
   */
  FieloFormElement.prototype.renderPicklist_ = function() {
    this.label_.textContent = this.labelValue_;
    // Adjunto hijos
    var html = '';
    if (!this.required_) {
      html +=
      '<li id="' + this.formId_ + '-void" data-value="" ' +
      'class="' + this.CssClasses_.DROPDOWN_ITEM + ' ' +
        this.CssClasses_.VOID_ITEM + '" ' +
      'role="presentation" title="' + this.labelValue_ + '">' +
        '<a href="javascript:void(0)" role="menuitemradio" data-label-value="' +
        this.labelValue_ + '" >' +
          '<p class="slds-truncate">' +
            '<svg aria-hidden="true" class="slds-icon slds-icon--selected ' +
            'slds-icon--x-small slds-icon-text-default' +
            ' slds-m-right--x-small">' +
              '<use xmlns:xlink="http://www.w3.org/1999/xlink" ' +
              'xlink:href="{!URLFOR($Resource.FieloSalesforce_Backend)}/' +
              'lightning/icons/utility-sprite/svg/symbols.svg#check"></use>' +
            '</svg><span class="option-text">' + this.labelValue_ +
          '</span></p>' +
        '</a>' +
      '</li>';
    }

    var optionNumber = 0;
    this.options_.forEach(function(option) {
      html +=
      '<li class="slds-dropdown__item" id="option-' +
        optionNumber +
        '" data-value="' + option.value.replace(/"/g, '##')
        .replace(/&quot;/g, '##').replace(/'/g, '#-#') +
        '" role="presentation">' +
        '<a href="javascript:void(0)" role="menuitemradio" data-label-value="' +
        option.label + '" >' +
          '<p class="slds-truncate">' +
            '<svg aria-hidden="true" class="slds-icon slds-icon--selected ' +
            'slds-icon--x-small slds-icon-text-default ' +
            'slds-m-right--x-small">' +
              '<use xlink:href="' + BackEndJSSettings.RESOURCE.BACKEND +
              '/lightning/icons/utility-sprite/svg/symbols.svg#check" ' +
              'xmlns:xlink="http://www.w3.org/1999/xlink"></use>' +
            '</svg><span class="option-text">' + option.label +
          '</span></p>' +
        '</a>' +
      '</li>';
      optionNumber++;
    });
    this.elementList_.innerHTML = html;
    $(this.input_).picklist('getValue').$choices =
      $('.' + this.CssClasses_.DROPDOWN_ITEM + ' a', this.input_);
    $(this.input_).picklist('bindChoices');
  };

  /**
   * Renderiza el checkbox
   */
  FieloFormElement.prototype.renderCheckboxes_ = function() {
    // Adjunto hijos
    var html = '';

    this.options_.forEach(function(option) {
      html +=
        '<div class="' + this.CssClasses_.CONTROL + '">' +
        '<span class="' + this.CssClasses_.CHECKBOX + '">' +
          '<input type="checkbox" name="options" value ="' +
            option.value + '" id="' + option.id.replace(/\s/g, '') + '"/>' +
          '<label class="' + this.CssClasses_.CHECKBOX + '__label" for="' +
            option.id.replace(/\s/g, '') + '">' +
            '<span class="' + this.CssClasses_.CHECKBOX + '--faux"></span>' +
            '<span class="' + this.CssClasses_.LABEL + '">' + option.label +
            '</span> </label> </span> </div>';
    }, this);
    this.elementList_.innerHTML = html;
    this.initCheckboxesInputs_();
  };

  /**
   * Oculto los items segun el data-type
   */
  FieloFormElement.prototype.hideItems_ = function() {
    switch (this.type_) {
      case 'picklist':
      case 'checkboxes':
        [].forEach.call(this.elementListItems_, function(item) {
          item.classList.add(this.CssClasses_.HIDE);
        }, this);
        if (this.voidItem_) {
          this.voidItem_.classList.remove(this.CssClasses_.HIDE);
        }
        break;
      default:
    }
  };

  FieloFormElement.prototype.hide = function() {
    this.element_.classList.add(this.CssClasses_.HIDE);
  };

  FieloFormElement.prototype.show = function() {
    this.element_.classList.remove(this.CssClasses_.HIDE);
  };

  /**
   * Deseleciona los items
   */
  FieloFormElement.prototype.clearSelected_ = function() {
    switch (this.type_) {
      case 'picklist':
        [].forEach.call(
          this.elementList_.getElementsByClassName(this.CssClasses_.SELECTED),
          function(selected) {
            selected.classList.remove(this.CssClasses_.SELECTED);
          },
          this
        );
        break;
      case 'checkboxes':
        this.clear();
        break;
      default:
    }
  };

  /**
   * Muestra las opciones válidas para cada data-type
   * @param {String | Number} value - valor que fue elegido por el elemento al que depende
   */
  FieloFormElement.prototype.showValidOptions_ = function(value) {
    this.hideItems_();
    switch (this.type_) {
      case 'picklist':
      case 'checkboxes':
        if (this.validFor_.hasOwnProperty(value)) {
          this.validFor_[value].forEach(function(item) {
            this.elementList_.querySelector('[data-value="' + item + '"]')
              .classList.remove(this.CssClasses_.HIDE);
          }, this);
        }
        break;
      default:
    }
    this.cbValidOptions_();
  };

  /**
   * Selecciona la primera opcion solo si hay un valor disponible
   */
  FieloFormElement.prototype.selectFirstOption = function() {
    if (
      this.type_ !== 'hidden' &&
      this.required_ &&
      this.elementListItems_ &&
      $(this.elementListItems_).not('.' + this.CssClasses_.HIDE).length === 1
    ) {
      this.set(
        'value',
        $(this.elementListItems_).not('.' + this.CssClasses_.HIDE)[0]
          .getAttribute(this.Constant_.VALUE)
      );
    }
  };

  /**
   *
   * Event listeners
   *
   */

  /**
   * Helper para el change de cada data-type
   */
  FieloFormElement.prototype.onChange_ = function() {
    if (this.dontChangeOnAjax) {
      this.doChange();
    }
  };

  FieloFormElement.prototype.doChange = function() {
    switch (this.type_) {
      case 'radio':
        [].forEach.call(
          this.elementListItems_,
          function(item) {
            if (item.checked) {
              this.input_ = item;
            }
          },
          this
        );
        break;
      default:
    }
    if (typeof window[this.onChangeHook_] === 'function') {
    // llamo al on change externo
      window[this.onChangeHook_](this.get('value'), this);
    }
    if (this.dependableElements !== null) {
      for (var element in this.dependableElements) {
        if (this.dependableElements.hasOwnProperty(element)) {
          this.dependableElements[element].refresh(this.get('value'));
        }
      }
    }
  };

  FieloFormElement.prototype.reset_ = function() {
    switch (this.type_) {
      case 'picklist':
        // Actualizo el label
        this.label_.textContent = this.labelValue_;
        break;
      case 'checkboxes':
      default:
    }
    this.clearSelected_();
    this.clearOptions_();
    if (this.dependableElements !== null) {
      for (var element in this.dependableElements) {
        if (this.dependableElements.hasOwnProperty(element)) {
          this.dependableElements[element].reset_();
        }
      }
    }
  };

  /**
   * Actualiza el listado de opciones para cada data-type
   * El optionsGetter_debe retornar una lista de tipo [{label: '', value: '', id: ''}]
   * @param  {String|Id} value - valor del elemento al que depende que luego sedrá evaluado
   */
  FieloFormElement.prototype.refresh = function(value) {
    this.reset_();

    if (
      this.optionsGetter_ &&
      typeof window[this.optionsGetter_] === 'function'
    ) {
      // llamo al getter
      window[this.optionsGetter_](value, this);
    } else if (this.validFor_) {
      // muestro opciones validas
      this.showValidOptions_(value);
      this.enable_();
      this.selectFirstOption();
    }
  };

  FieloFormElement.prototype.render = function(value) {
    this.options_ = value;
    // renderizo
    switch (this.type_) {
      case 'picklist':
        this.renderPicklist_();
        break;
      case 'checkboxes':
        this.renderCheckboxes_();
        break;
      default:
    }
    this.enable_();
  };

  /**
   * Getters de cada data-type
   * @param  {String} property - Propiedad a consultar
   * @return {Object}          - Resultado de la consulta
   */
  FieloFormElement.prototype.get = function(property) {
    var value;
    var values = [];
    switch (property) {
      case 'id':
        return this.id_;
      case 'fieldName':
        return this.element_.getAttribute(this.Constant_.FIELD_NAME);
      case 'label':
        return this.element_.getAttribute(this.Constant_.OBJECT_LABEL);
      case 'name':
        return this.input_.name;
      case 'type':
        return this.type_;
      case 'value':
        switch (this.type_) {
          case 'input-date':
          case 'input-datetime':
            value = this.input_.value;
            if (this.input_.value) {
              value = $(this.input_).datepicker('getDate').valueOf();

              if (!this.disableTimezoneFix_) {
                // gets the offset
                var offset = new Date().getTimezoneOffset();
                // check if  we are in DST
                if (new Date().isDst()) {
                  // We are in DST
                  // So then the computer clock was already forwarded one hour
                  if (
                    new Date(value).toLocaleDateString('en', {
                      timeZoneName: 'long'
                    }).indexOf('Summer Time') === -1
                  ) {
                    // Since the selected date isn't summer time
                    // we need to compensate the removed hour by the computer
                    offset += 60;
                  }
                } else if (
                  new Date(value).toLocaleDateString('en', {
                    timeZoneName: 'long'
                  }).indexOf('Summer Time') > -1
                ) {
                  // We aren't in DST
                  // So then the computer clock isn't forwarded

                  // Since the selected date is summer time
                  // we need to remove since we aren't in DST and
                  // one hour more since is a summer time date
                  offset -= 60;
                }
                // change the offset sign because is inverted
                offset *= -1;
                // Add the offset hours needed to standarize the date to 0
                value += offset * 60000;

                if (this.type_ === 'input-datetime') {
                  // reset standard offset
                  value -= offset * 60000;
                  // Agrega perfiles definido en SF
                  value += BackEndJSSettings.OFFSET * 60000; // eslint-disable-line no-undef
                }
              }
            } else {
              value = null;
            }
            return value;
          case 'picklist':
            value = $(this.input_).picklist('getValueId');
            if (typeof value === 'string') {
              value = this.input_.querySelector('#' + value);
              if (
                value && value.classList.contains(this.CssClasses_.SELECTED)
              ) {
                value = value.getAttribute(this.Constant_.VALUE);
              } else {
                value = null;
              }
            } else {
              value = null;
            }
            return value;
          case 'lookup':
            value = $(this.input_).lookup('getSelection');
            if (value) {
              value = value.id;
            }
            return value;
          case 'multiselect':
            var list = $(this.input_).multiSelect('getSelectedItems');

            [].forEach.call(list, function(item) {
              if (item.hasOwnProperty('id')) {
                values.push(item.id);
              }
            });
            if (values.length > 0) {
              return values;
            }
            return [];
          case 'radio':
            if (this.input_) {
              return this.input_.value;
            }
            return null;
          case 'checkbox':
            return this.input_.checked;
          case 'checkboxes':
            [].forEach.call(this.inputs_, function(input) {
              if (input.checked) {
                values.push(input.value);
              }
            });
            return values;
          case 'richtext':
            return CKEDITOR.instances[this.input_.id].getData();
          case 'text':
            return this.element_.getElementsByClassName(
              'fielosf-output')[0].innerHTML;
          default:
            if (this.input_) {
              return this.input_.value;
            }
            return this.element_.getAttribute('data-value');
        }
      default:
        return null;
    }
  };

  /**
   * Setters de cada data-type
   * @param  {String} property - Propiedad a guardar
   * @param {Object} value     - Valor a guardar obj.record - obj.apiname
   */
  FieloFormElement.prototype.set = function(property, value) {
    if (value !== null && value !== undefined) {
      switch (property) {
        case 'checkboxBinding':
          this.element_.querySelector(
            '.' + this.CssClasses_.CHECKBOX + ' input'
          ).id = value;
          this.element_.getElementsByClassName(
            this.CssClasses_.CHECKBOX + '__label'
          )[0].setAttribute('for', value);
          break;
        case 'id':
          this.id_ = value;
          this.element_.setAttribute(this.Constant_.COMPONENT_ID, value);
          break;
        case 'name':
          this.input_.name = value;
          break;
        case 'type':
          this.type_ = value;
          this.element_.setAttribute(this.Constant_.TYPE, value);
          break;
        case 'value':
          switch (this.type_) {
            case 'input-date':
            case 'input-datetime':
              if (!isNaN(value)) {
                // gets the offset
                var offset = new Date().getTimezoneOffset();
                // check if  we are in DST
                if (new Date().isDst()) {
                  // We are in DST
                  // So then the computer clock was already forwarded one hour
                  if (
                    moment(value)._d.toLocaleDateString('en', {
                      timeZoneName: 'long'
                    }).indexOf('Summer Time') === -1
                  ) {
                    // Since the selected date isn't summer time
                    // we need to compensate the removed hour by the computer
                    offset += 60;
                  }
                } else if (
                  moment(value)._d.toLocaleDateString('en', {
                    timeZoneName: 'long'
                  }).indexOf('Summer Time') > -1
                ) {
                  // We aren't in DST
                  // So then the computer clock isn't forwarded

                  // Since the selected date is summer time
                  // we need to remove since we aren't in DST and
                  // one hour more since is a summer time date
                  offset -= 60;
                }
                // change the offset sign because is inverted
                offset *= -1;
                // Remove the offset since it comes from UTC
                // and for the picklist is needed local time
                value -= offset * 60000;

                if (this.type_ === 'input-datetime') {
                  // reset standard offset
                  value += offset * 60000;
                  // Agrega perfiles definido en SF
                  value -= BackEndJSSettings.OFFSET * 60000; // eslint-disable-line no-undef
                }
                $(this.input_).datepicker('setDate', value);
              }
              break;
            case 'picklist':
              var item =
                this.input_.querySelector('[data-value="' + value + '"]');
              if (item) {
                $(this.input_).picklist('setValue', item.id, true);
              }
              this.enable_();
              break;
            case 'multiselect':
              $(this.input_).multiSelect('setSelectedItems', value);
              break;
            case 'lookup':
              this.setLookupValue_(value, this);
              break;
            case 'radio':
              [].forEach.call(
                this.elementListItems_,
                function(item) {
                  if (item.value === value) {
                    this.input_ = item;
                    this.input_.checked = true;
                  }
                },
                this
              );
              break;
            case 'checkbox':
              this.input_.checked =
                (typeof value === 'boolean' ? value : !(value === 'false'));
              break;
            case 'checkboxes':
              value.forEach(function(v) {
                this.inputs_[v].checked =
                  (typeof v === 'boolean' ? v : !(v === 'false'));
              }, this);
              break;
            case 'text':
              this.element_
                .getElementsByClassName('fielosf-output')[0].innerHTML = value;
              break;
            case 'input-textarea':
              this.input_.value = fielo.util.unescapeJsInHtml(value);
              break;
            case 'richtext':
              CKEDITOR.instances[this.input_.id].setData(value);
              break;
            default:
              this.input_.value = value;
          }
          break;
        default:
          this.element_.setAttribute(property, value);
      }
    }
  };

  /**
   * clear the value of the element
   */
  FieloFormElement.prototype.clear = function() {
    switch (this.type_) {
      case 'picklist':
        this.label_.textContent = this.labelValue_;
        var items =
          this.input_.getElementsByClassName(this.CssClasses_.SELECTED) || null;
        [].forEach.call(items, function(item) {
          item.classList.remove(this.CssClasses_.SELECTED);
        }, this);
        break;
      case 'lookup':
        $(this.input_).lookup('setSelection', {});
        break;
      case 'radio':
        [].forEach.call(this.elementListItems_, function(item) {
          item.checked = false;
        });
        break;
      case 'checkbox':
        this.input_.checked = false;
        break;
      case 'checkboxes':
        [].forEach.call(this.inputs_, function(input) {
          input.checked = false;
        });
        break;
      case 'multiselect':
        var unselection = [];
        var options = this.element_.querySelectorAll(
          '.' + this.CssClasses_.PICKLIST + '__item'
        );
        [].forEach.call(options, function(option) {
          unselection.push(option.id);
        });
        $(this.input_).multiSelect('setUnselectedItems', unselection);
        break;
      case 'richtext':
        CKEDITOR.instances[this.input_.id].setData('');
        break;
      default:
        this.input_.value = '';
    }
    this.selectFirstOption();
  };
  /**
   * Registra la dependencia hacia otro elemento
   * @public
   */
  FieloFormElement.prototype.registerDependency_ = function() {
    if (this.controllerElement_) {
      var binder = document.getElementById(this.controllerElement_);
      if (binder && typeof binder.FieloFormElement === 'object') {
        binder.FieloFormElement.dependableElements[this.element_.id] = this;
      }
    }
  };

  /**
   * Deshabilita el elemento
   */
  FieloFormElement.prototype.disable_ = function() {
    var controlElement = this.element_.getElementsByClassName(this.CssClasses_.CONTROL)[0];

    controlElement.setAttribute('disabled', '');
    controlElement.classList.add('disabled');
  };

  /**
   * Habilita el elemento
   */
  FieloFormElement.prototype.enable_ = function() {
    var controlElement = this.element_.getElementsByClassName(this.CssClasses_.CONTROL)[0];

    if (controlElement.hasAttribute('disabled')) {
      controlElement.removeAttribute('disabled');
      controlElement.classList.remove('disabled');
    }
  };

  FieloFormElement.prototype.cbValidOptions_ = function() {
    this.cbValidOptionsActions_.forEach(function(action) {
      if (typeof window[action] === 'function') {
        // llamo al on change externo
        window[action](this);
      }
    }, this);
  };

  FieloFormElement.prototype.registerCbValidOptions = function(action) {
    this.cbValidOptionsActions_.push(action);
  };

  FieloFormElement.prototype.setDataOptions_ = function() {
    var res = this.element_.getAttribute(this.Constant_.OPTIONS) || null;
    if (res) {
      res = JSON.parse(res);
    }
    return res;
  };

  /**
   * Inicializa el elemento
   */
  FieloFormElement.prototype.init = function() {
    if (this.element_) {
      this.id_ = this.element_.getAttribute(this.Constant_.COMPONENT_ID);
      this.help_ =
        this.element_.getElementsByClassName(this.CssClasses_.HELP)[0] || null;
      this.icon_ =
        this.element_.getElementsByClassName(this.CssClasses_.ICON)[0] || null;
      if (this.icon_) {
        this.popover_ =
          this.element_.getElementsByClassName(this.CssClasses_.POP_OVER)[0];
        this.setIconHover_();
      }
      this.type_ = this.element_.getAttribute(this.Constant_.TYPE) || null;

      this.formId_ = '';
      if (this.element_.hasAttribute(this.Constant_.FORM_ID)) {
        this.formId_ =
          this.element_.getAttribute(this.Constant_.FORM_ID) || '';
      }
      this.cbValidOptionsActions_ = [];

      this.dontChangeOnAjax = true;
      this.required_ = false;
      if (this.element_.hasAttribute(this.Constant_.REQUIRED)) {
        this.required_ =
          (this.element_.getAttribute(this.Constant_.REQUIRED) === 'true');
      }

      this.controllerElement_ =
        this.element_.getAttribute(this.Constant_.CONTROLLER_ELEMENT) || null;
      if (this.controllerElement_) {
        this.disable_();
      }

      this.validFor_ =
        this.element_.getAttribute(this.Constant_.VALID_FOR) || null;
      if (this.validFor_) {
        this.validFor_ = JSON.parse(this.validFor_);
      }

      this.onChangeHook_ =
        this.element_.getAttribute(this.Constant_.ON_CHANGE) || null;

      this.dataOptions_ =
        this.setDataOptions_();

      this.optionsGetter_ =
        this.element_.getAttribute(this.Constant_.OPTIONS_GETTER) || null;
      this.dependableElements = {};

      this.fieldName_ =
        this.element_.getAttribute(this.Constant_.FIELD_NAME);

      switch (this.type_) {
        case 'picklist':
          this.configPicklist_();
          break;
        case 'lookup':
          this.configLookup_();
          break;
        case 'input-date':
        case 'input-datetime':
          this.configDatepicker_();
          break;
        case 'radio':
          this.configRadio_();
          break;
        case 'checkbox':
          this.configCheckbox_();
          break;
        case 'checkboxes':
          this.configCheckboxes_();
          break;
        case 'multiselect':
          this.configMultiselect_();
          break;
        case 'richtext':
          this.configRichtext_();
          break;
        default:
          this.configInput_();
          break;
      }

      // Registro las dependencias
      this.registerDependency_();
      this.element_.addEventListener('click', function(click) {
        if (this.element_.hasAttribute('disabled')) {
          click.preventDefault();
          click.stopPropagation();
        }
      }.bind(this));

      this.selectFirstOption();
    }
  };

  // registro el componente en fielo.util
  fielo.util.register({
    constructor: FieloFormElement,
    classAsString: 'FieloFormElement',
    cssClass: 'slds-form-element',
    widget: true
  });
})();
