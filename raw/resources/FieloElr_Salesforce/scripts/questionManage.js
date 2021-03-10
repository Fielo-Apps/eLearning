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
  var FieloQuestionManage = function FieloQuestionManage(element) {
    this.element_ = element;

    // Initialize instance.
    this.init();
  };
  window.FieloQuestionManage = FieloQuestionManage;

  /**
   * Guarda las constantes en un lugar para que sean facilmente actualizadas
   * @enum {string | number}
   * @private
   */
  FieloQuestionManage.prototype.Constant_ = {
    OBJECT_NAME: 'data-object-name',
    SAVE_CONTROLLER: 'FieloELR.LevelReorderController.reorder',
    DATA_CONTROLLER: 'data-controller-element',
    DATA_UPGRADED: 'data-upgraded'
  };

  /**
   * Guarda strings para nombres de clases definidas por este componente que
   * son usadas por JavaScript.
   * Esto nos permite cambiarlos solo en un lugar
   * @enum {string}
   * @private
   */
  FieloQuestionManage.prototype.CssClasses_ = {
    CONTAINER: 'fielosf-recent-records__container',
    FIELD: 'fielosf-output',
    MODEL: 'fielosf-recent-records__model',
    SAVE: 'fielosf-question-manage__save',
    CANCEL: 'fielosf-question-manage__cancel',
    SECTION_PANEL: 'slds-panel__section',
    FORM_ELEMENT: 'slds-form-element',
    REORDER: 'fielosf-recent-reorder'
  };
  /**
  * Get Module
  */

  FieloQuestionManage.prototype.getModule_ = function() {
    var moduleSection =
      this.element_.getElementsByClassName(this.CssClasses_.SECTION_PANEL)[0];
    var fields =
      $(moduleSection).find('.' + this.CssClasses_.FORM_ELEMENT);
    var sObject = {};
    sObject.id = this.parameters_.Id ||
      this.parameters_.cloneId ||
      this.parameters_.FieloELR__Module__c;
    [].forEach.call(fields, function(field) {
      sObject[field.FieloFormElement.get('fieldName')] =
        field.FieloFormElement.get('value');
    }, this);
    return sObject;
  };

  FieloQuestionManage.prototype.getQuestions_ = function() {
    var questionSection =
      this.element_.getElementsByClassName(this.CssClasses_.SECTION_PANEL)[1];
    var questionSectionfields =
      $(questionSection).find('.' + this.CssClasses_.FORM_ELEMENT);
    var fixedFields = {};

    [].forEach.call(questionSectionfields, function(field) {
      fixedFields[field.FieloFormElement.get('fieldName')] =
        field.FieloFormElement.get('value');
    }, this);

    var items = $(this.element_)
      .find('.' + this.CssClasses_.MODEL);
    var shuffleQuestions =
      this.elements_.FieloELR__ShuffleQuestions__c
        .FieloFormElement.get('value');
    var sObjectList = [];
    [].forEach.call(items, function(item) {
      var sObject = {};
      sObject.id = item.getAttribute('data-record-id');
      if (!shuffleQuestions) {
        sObject.FieloELR__Order__c =// eslint-disable-line camelcase
          $(item).find('[data-field = "FieloELR__Order__c"]')[0].innerHTML;
      }

      if (this.questionFields_) {
        this.questionFields_.forEach(function(fieldName) {
          sObject[fieldName] =
            $(item).find('[data-field-name= "' + fieldName + '"]')[0]
              .FieloFormElement.get('value');
        }, this);
      }

      [].forEach.call(Object.keys(fixedFields), function(fieldName) {
        if (this.questionFields_) {
          if (!this.questionFields_.has(fieldName)) {
            sObject[fieldName] = fixedFields[fieldName];
          }
        } else {
          sObject[fieldName] = fixedFields[fieldName];
        }
      }, this);

      sObjectList.push(sObject);
    }, this);
    return sObjectList;
  };

  FieloQuestionManage.prototype.retrieve_ = function(source) {
    // traigo los parameters del boton
    this.parameters_ = source.FieloButton.getParameters();

    // Setea parametros default en edit y new
    this.setParameters_();

    // 2 - Hacer retrieve si estoy en edit
    if (
      this.parameters_.hasOwnProperty('Id') ||
      this.parameters_.hasOwnProperty('FieloELR__Module__c') ||
      this.parameters_.hasOwnProperty('cloneId')
    ) {
      this.isEditing = true;
      this.recordId_ = this.parameters_.Id;

      var retrieveRecordId = this.parameters_.Id ||
        this.parameters_.cloneId ||
        this.parameters_.FieloELR__Module__c;

      // Si es un record busca los datos y los setea
      this.fields_ = this.moduleFields_;

      var objectName = this.element_.getAttribute(this.Constant_.OBJECT_NAME);
      Visualforce.remoting.Manager.invokeAction(
        this.element_.getAttribute('data-retrieve-controller'),
        objectName,
        retrieveRecordId,
        this.fields_.join(),
        this.retrieveHandler_.bind(this),
        {escape: true}
      );
    } else {
      this.isEditing = false;
      this.setParameters_();
      this.endRetrieve();
    }
  };

  FieloQuestionManage.prototype.retrieveProxy_ = function(modal, source) {
    modal.FieloQuestionManage.retrieve_(source);
  };
  window.FieloQuestionManage_retrieve =// eslint-disable-line camelcase
    FieloQuestionManage.prototype.retrieveProxy_;

  FieloQuestionManage.prototype.retrieveHandler_ = function(result) {
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
          if (
            this.elements_[field].FieloFormElement.get('type') === 'input-date'
          ) {
            result[field] = fielo.util.parseDateFromSF(result[field]);
          }
          this.elements_[field].FieloFormElement.set('value', result[field]);
        }
      }, this);

      // Global Question Setup
      if (result.FieloELR__Questions__r) {
        if (result.FieloELR__Questions__r.length > 0) {
          var questionSection =
            this.element_
              .getElementsByClassName(this.CssClasses_.SECTION_PANEL)[1];
          var questionSectionfields =
            $(questionSection).find('.' + this.CssClasses_.FORM_ELEMENT);

          [].forEach.call(questionSectionfields, function(field) {
            field.FieloFormElement.set('value',
              result.FieloELR__Questions__r[0][
                field.FieloFormElement.get('fieldName')]);
          }, this);
        }
      }

      // 3 - Pisar con los parameters de source en edit y new
      this.setParameters_();
      this.endRetrieve();
    } catch (e) {
      var notify = fielo.util.notify.create();
      notify.FieloNotify.addMessages([this.Constant_.HAS_ERROR, e]);
      notify.FieloNotify.setTheme('error');
      notify.FieloNotify.show();
    }
    // Hago focus en el primer elemento del form
    var elements =
      this.element_.getElementsByClassName(this.CssClasses_.ELEMENTS);
    for (var i = 0; i < elements.length; i++) {
      var type = elements[i].FieloFormElement.get('type');
      if (type === 'lookup' || type.indexOf('input') !== -1) {
        elements[i].getElementsByClassName('slds-input')[0].focus();
        break;
      }
    }
    fielo.util.spinner.FieloSpinner.hide();
  };

  FieloQuestionManage.prototype.setParameters_ = function() {
    for (var field in this.parameters_) {
      if (field in this.parameters_) {
        if (field in this.elements_) {
          this.elements_[field].FieloFormElement.set(
            'value',
            this.parameters_[field]
          );
        }
      }
    }
  };

  /**
  * Save Order
  */
  FieloQuestionManage.prototype.save_ = function() {
    // fielo.util.spinner.FieloSpinner.show();
    var moduleValues = this.getModule_();
    var questionValues = this.getQuestions_();

    var moduleNullFields = [];
    var questionNullFields = {};

    [].forEach.call(Object.keys(moduleValues), function(field) {
      if (moduleValues[field] === '' ||
          moduleValues[field] === null) {
        moduleNullFields.push(field);
      }
    });

    questionValues.forEach(function(row) {
      if (moduleValues.FieloELR__PenaltyMode__c === 'Negative Weight') {
        row.FieloELR__PenaltyPerAttempt__c = 0;// eslint-disable-line camelcase
      } else if (moduleValues.FieloELR__PenaltyMode__c === 'Percent Decrease') {
        row.FieloELR__IncorrectWeight__c = 0;// eslint-disable-line camelcase
      } else if (moduleValues.FieloELR__PenaltyMode__c === 'None') {
        row.FieloELR__PenaltyPerAttempt__c = 0;// eslint-disable-line camelcase
        row.FieloELR__IncorrectWeight__c = 0;// eslint-disable-line camelcase
      }

      if (
        moduleValues
        .FieloELR__AttemptsAllowedPerQuestion__c === 'Unlimited') { // eslint-disable-line camelcase
        moduleValues.FieloELR__AttemptsAllowedPerQuestion__c = ''; // eslint-disable-line camelcase
      }

      [].forEach.call(Object.keys(row), function(field) {
        if (row[field] === '' ||
          row[field] === null) {
          if (!questionNullFields[row.id]) {
            questionNullFields[row.id] = [];
          }
          questionNullFields[row.id].push(field);
        }
      });
    });

    [].forEach.call(questionValues, function(question) {
      if (question.id === 'r[\'id\']') {
        var index = questionValues.indexOf(question);
        if (index > -1) {
          questionValues.splice(index, 1);
        }
      }
    }, this);

    try {
      Visualforce.remoting.Manager.invokeAction(
        this.element_.getAttribute('data-save-controller'),
        moduleValues,
        moduleNullFields,
        questionValues,
        questionNullFields,
        this.processRemoteActionResult_.bind(this),
        {
          escape: false
        }
      );
    } catch (e) {
      console.warn(e);
    }
  };

  FieloQuestionManage.prototype.getFields_ = function() {
    var moduleFields = $($(this.element_)
      .find('.' + this.CssClasses_.SECTION_PANEL)[0])
      .find('.' + this.CssClasses_.FORM_ELEMENT);

    if (this.moduleFields_ === null || this.moduleFields_ === undefined) {
      this.moduleFields_ = [];
    }
    this.elements_ = [];
    [].forEach.call(moduleFields, function(field) {
      this.moduleFields_.push(field.FieloFormElement.get('fieldName'));
      this.elements_[field.FieloFormElement.get('fieldName')] = field;
    }, this);
  };

  FieloQuestionManage.prototype.changeForm = function() {
    var penaltyMode =
      this.elements_.FieloELR__PenaltyMode__c
        .FieloFormElement.get('value');
    var weightedQuestions =
      this.elements_.FieloELR__WeightedQuestions__c
        .FieloFormElement.get('value');
    var shuffleQuestions =
      this.elements_.FieloELR__ShuffleQuestions__c
        .FieloFormElement.get('value');
    var questionPool =
      this.elements_.FieloELR__QuestionPool__c
        .FieloFormElement.get('value');
    var incorrectWeight =
      $($(this.element_).find('.' + this.CssClasses_.SECTION_PANEL)[1])
        .find('[data-field-name="FieloELR__IncorrectWeight__c"]');
    var penaltyPerAttempt =
      $($(this.element_).find('.' + this.CssClasses_.SECTION_PANEL)[1])
        .find('[data-field-name="FieloELR__PenaltyPerAttempt__c"]');
    var shuffleQuestionsDiv =
      $($(this.element_).find('.' + this.CssClasses_.SECTION_PANEL)[0])
        .find('[data-field-name="FieloELR__ShuffleQuestions__c"]')[0];
    var weightedQuestionsDiv =
      $($(this.element_).find('.' + this.CssClasses_.SECTION_PANEL)[0])
        .find('[data-field-name="FieloELR__WeightedQuestions__c"]')[0];

    if (shuffleQuestions) {
      this.reorderObject.disableSort();
    } else {
      this.reorderObject.enableSort();
    }
    if (penaltyMode === 'None') {
      incorrectWeight.toggle(false);
      penaltyPerAttempt.toggle(false);
      if (weightedQuestions) {
        // Add Inputs
        this.addInputs('FieloELR__CorrectWeight__c');
        this.removeInputs('FieloELR__PenaltyPerAttempt__c');
        this.removeInputs('FieloELR__IncorrectWeight__c');
      } else {
        // Remove Inputs
        this.removeInputs('FieloELR__CorrectWeight__c');
        this.removeInputs('FieloELR__PenaltyPerAttempt__c');
        this.removeInputs('FieloELR__IncorrectWeight__c');
      }
    } else if (penaltyMode === 'Percent Decrease') {
      incorrectWeight.toggle(false);
      if (weightedQuestions) {
        penaltyPerAttempt.toggle(false);
        // Add Inputs
        this.addInputs('FieloELR__CorrectWeight__c');
        this.addInputs('FieloELR__PenaltyPerAttempt__c');
        this.removeInputs('FieloELR__IncorrectWeight__c');
      } else {
        penaltyPerAttempt.toggle(true);
        // Remove Inputs
        this.removeInputs('FieloELR__CorrectWeight__c');
        this.removeInputs('FieloELR__PenaltyPerAttempt__c');
        this.removeInputs('FieloELR__IncorrectWeight__c');
      }
    } else if (penaltyMode === 'Negative Weight') {
      penaltyPerAttempt.toggle(false);
      if (weightedQuestions) {
        incorrectWeight.toggle(false);
        // Add Inputs
        this.addInputs('FieloELR__CorrectWeight__c');
        this.addInputs('FieloELR__IncorrectWeight__c');
        this.removeInputs('FieloELR__PenaltyPerAttempt__c');
      } else {
        incorrectWeight.toggle(true);
        // Remove Inputs
        this.removeInputs('FieloELR__CorrectWeight__c');
        this.removeInputs('FieloELR__PenaltyPerAttempt__c');
        this.removeInputs('FieloELR__IncorrectWeight__c');
      }
    } else {
      incorrectWeight.toggle(false);
      penaltyPerAttempt.toggle(false);
      this.removeInputs('FieloELR__CorrectWeight__c');
      this.removeInputs('FieloELR__PenaltyPerAttempt__c');
      this.removeInputs('FieloELR__IncorrectWeight__c');
    }
    if (questionPool === null ||
      questionPool === undefined ||
      questionPool === '') {
      if ($(shuffleQuestionsDiv).hasClass('disabled')) {
        $(shuffleQuestionsDiv).removeClass('disabled');
        shuffleQuestionsDiv.FieloFormElement.set('value', false);
      }
      if ($(weightedQuestionsDiv).hasClass('disabled')) {
        $(weightedQuestionsDiv).removeClass('disabled');
        weightedQuestionsDiv.FieloFormElement.set('value', false);
        this.changeForm();
      }
    } else if (questionPool > 0.0) {
      if (!$(shuffleQuestionsDiv).hasClass('disabled')) {
        $(shuffleQuestionsDiv).addClass('disabled');
        shuffleQuestionsDiv.FieloFormElement.set('value', true);
      }
      if (!$(weightedQuestionsDiv).hasClass('disabled')) {
        $(weightedQuestionsDiv).addClass('disabled');
        weightedQuestionsDiv.FieloFormElement.set('value', false);
        this.changeForm();
      }
    } else {
      if ($(shuffleQuestionsDiv).hasClass('disabled')) {
        $(shuffleQuestionsDiv).removeClass('disabled');
        shuffleQuestionsDiv.FieloFormElement.set('value', false);
      }
      if ($(weightedQuestionsDiv).hasClass('disabled')) {
        $(weightedQuestionsDiv).removeClass('disabled');
        weightedQuestionsDiv.FieloFormElement.set('value', false);
        this.changeForm();
      }
    }
  };

  FieloQuestionManage.prototype.endRetrieve = function() {
    this.changeForm();
  };

  /**
  * Process Remote Action
  */

  FieloQuestionManage.prototype.processRemoteActionResult_ = function(
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

  FieloQuestionManage.prototype.addInputs = function(fieldName) {
    var items = $(this.element_)
      .find('.' + this.CssClasses_.MODEL);
    var currentField;
    var newField;
    this.showColumn(fieldName);
    this.addField(fieldName);
    [].forEach.call(items, function(item) {
      currentField = $(item)
        .find('[data-field="' + fieldName + '"]')[0];
      if (currentField) {
        if (fieldName === 'FieloELR__CorrectWeight__c') {
          newField =
            this.correctWeightModel.cloneNode(true);
        } else if (fieldName === 'FieloELR__IncorrectWeight__c') {
          newField =
            this.incorrectWeightModel.cloneNode(true);
        } else if (fieldName === 'FieloELR__PenaltyPerAttempt__c') {
          newField =
            this.penaltyPerAttemptModel.cloneNode(true);
        }
        this.initField(newField);

        newField.FieloFormElement
          .set('value', currentField.innerHTML);
        $(currentField).closest('td')[0]
          .appendChild(newField);
        if (!$(currentField).closest('td').hasClass('ui-state-disabled')) {
          $(currentField).closest('td').addClass('ui-state-disabled');
        }

        if (newField) {
          $(currentField).closest('td')[0]
            .removeChild(currentField);
          $(newField).toggle(true);
          $(newField).closest('td').toggle(true);
        }
      }
    }, this);
  };

  FieloQuestionManage.prototype.removeInputs = function(fieldName) {
    var items = $(this.element_)
      .find('.' + this.CssClasses_.MODEL);
    var currentField = null;
    var newField = null;
    this.removeField(fieldName);
    [].forEach.call(items, function(item) {
      currentField = $(item)
        .find('[data-field-name="' + fieldName + '"]')[0];
      if (currentField) {
        if (fieldName === 'FieloELR__CorrectWeight__c') {
          newField =
            this.correctWeightOutputModel.cloneNode(true);
        } else if (fieldName === 'FieloELR__IncorrectWeight__c') {
          newField =
            this.incorrectWeightOutputModel.cloneNode(true);
        } else if (fieldName === 'FieloELR__PenaltyPerAttempt__c') {
          newField =
            this.penaltyPerAttemptOutputModel.cloneNode(true);
        }
        newField.innerHTML =
          currentField.FieloFormElement
            .get('value');

        $(currentField).closest('td')[0]
          .appendChild(newField);

        if (newField) {
          $(currentField).closest('td')[0]
            .removeChild(currentField);
          $(newField).toggle(true);
        }
      }
    }, this);
    this.hideColumn(fieldName);
  };

  FieloQuestionManage.prototype.hideColumn = function(fieldName) {
    var items = $(this.element_)
      .find('.' + this.CssClasses_.MODEL);
    var currentField = null;

    [].forEach.call(items, function(item) {
      currentField = $(item)
        .find('[data-field-name="' + fieldName + '"]')[0];
      if (!currentField) {
        currentField = $(item)
          .find('[data-field="' + fieldName + '"]')[0];
      }
      if (currentField) {
        $(currentField).toggle(false);
        $(currentField).closest('td').toggle(false);
      }
    }, this);

    if (currentField) {
      var index = $(currentField).closest('td').index();
      var column = $('#' + this.element_.id)
        .find('thead')
          .find('tr')[0].cells[index];
      $(column).toggle(false);
    }
  };

  FieloQuestionManage.prototype.showColumn = function(fieldName) {
    var items = $(this.element_)
      .find('.' + this.CssClasses_.MODEL);
    var currentField = null;

    [].forEach.call(items, function(item) {
      currentField = $(item)
        .find('[data-field-name="' + fieldName + '"]')[0];
      if (!currentField) {
        currentField = $(item)
          .find('[data-field="' + fieldName + '"]')[0];
      }
      if (currentField) {
        $(currentField).toggle(true);
        $(currentField).closest('td').toggle(true);
      }
    }, this);

    if (currentField) {
      var index = $(currentField).closest('td').index();
      var column = $('#' + this.element_.id)
        .find('thead')
          .find('tr')[0].cells[index];
      $(column).toggle(true);
    }
  };

  FieloQuestionManage.prototype.initField = function(element) {
    element.removeAttribute(this.Constant_.DATA_UPGRADED);
    if (!this.fieldIndex) {
      this.fieldIndex = 1;
    }
    element.id = String(element.id + '-' + this.fieldIndex);
    var dataController = element
      .getAttribute(this.Constant_.DATA_CONTROLLER) || null;
    if (dataController && this.fieldIndex !== 0) {
      element.setAttribute(
        this.Constant_.DATA_CONTROLLER,
        String(dataController + '-' + this.fieldIndex)
      );
      this.fieldIndex++;
    }
    componentHandler.upgradeElement(element);
  };

  /**
  * Inicializa el elemento
  */
  FieloQuestionManage.prototype.init = function() {
    if (this.element_) {
      this.container_ =
        this.element_.getElementsByClassName(this.CssClasses_.CONTAINER)[0] ||
        null;
      this.element_.getElementsByClassName(this.CssClasses_.SAVE)[0]
        .addEventListener('click', this.save_.bind(this));
      this.reorderObject = this.element_.FieloRecentReorder;
      if (this.reorderObject) {
        this.reorderObject.disableReorder = true;
      }

      $($(this.element_)
        .find('.' + this.CssClasses_.SECTION_PANEL)[1])
          .find('h3')[0].innerHTML = 'Global Question Setup';
      // $($(this.element_).find('.' + this.CssClasses_.SECTION_PANEL)[0])
        // .prepend($(globalSetupHeader).clone(true));
      $($(this.element_).find('.' + this.CssClasses_.SECTION_PANEL)[0])
        .find('h3')[0].innerHTML = 'Module Setup';

      $('#' + this.element_.id + '-section-Id')
        .toggle(false);
      $('#' + this.element_.id + '-questionsection-Id')
        .toggle(false);

      $('#' + this.element_.id)
        .find('[data-field-name="FieloELR__IncorrectWeight__c"]')
          .toggle(false);
      $('#' + this.element_.id)
        .find('[data-field-name="FieloELR__PenaltyPerAttempt__c"]')
          .toggle(false);
      $('#' + this.element_.id)
        .find('[data-field-name="FieloELR__CorrectWeight__c"]')
          .toggle(false);

      this.swapAttemptsAllowedPerQuestion();

      this.getFields_();

      this.initModels();

      this.hideColumn('FieloELR__Order__c');

      [].forEach.call(Object.keys(this.elements_), function(field) {
        if (field === 'FieloELR__WeightedQuestions__c' ||
            field === 'FieloELR__ShuffleQuestions__c' ||
            field === 'FieloELR__QuestionPool__c' ||
            field === 'FieloELR__PenaltyMode__c') {
          this.elements_[field].addEventListener('change',
            this.changeForm.bind(this));
          componentHandler.upgradeElement(this.elements_[field]);
        }
      }, this);
    }
  };

  FieloQuestionManage.prototype.addField = function(fieldName) {
    if (!this.questionFields_) {
      this.questionFields_ = new Set();
    }
    this.questionFields_.add(fieldName);
  };

  FieloQuestionManage.prototype.removeField = function(fieldName) {
    if (this.questionFields_) {
      if (this.questionFields_.has(fieldName)) {
        this.questionFields_.delete(fieldName);
      }
    }
  };

  FieloQuestionManage.prototype.swapAttemptsAllowedPerQuestion = function() {
    var fields = $(this.element_)
      .find('[data-field-name="FieloELR__AttemptsAllowedPerQuestion__c"]');
    var activeField = null;
    var hidenField = null;
    [].forEach.call(fields, function(field) {
      if ($(field).hasClass('slds-hide')) {
        hidenField = field;
      } else {
        activeField = field;
      }
    });
    $(hidenField).insertBefore(activeField);
    if ($(hidenField).hasClass('slds-hide')) {
      $(hidenField).removeClass('slds-hide');
    }
    if ($(hidenField).hasClass('slds-is-collapsed')) {
      $(hidenField).removeClass('slds-is-collapsed');
    }
    $(activeField).remove();
  };

  FieloQuestionManage.prototype.initModels = function() {
    // Input Fields
    this.incorrectWeightModel = $('#' + this.element_.id)
      .find('[data-field-name="FieloELR__IncorrectWeight__c"]')[0]
        .cloneNode(true);
    this.penaltyPerAttemptModel = $('#' + this.element_.id)
      .find('[data-field-name="FieloELR__PenaltyPerAttempt__c"]')[0]
        .cloneNode(true);
    this.correctWeightModel = $('#' + this.element_.id)
      .find('[data-field-name="FieloELR__CorrectWeight__c"]')[0]
        .cloneNode(true);
    // Output Fields
    this.incorrectWeightOutputModel = $('#' + this.element_.id)
      .find('[data-field="FieloELR__IncorrectWeight__c"]')[0]
        .cloneNode(true);
    this.penaltyPerAttemptOutputModel = $('#' + this.element_.id)
      .find('[data-field="FieloELR__PenaltyPerAttempt__c"]')[0]
        .cloneNode(true);
    this.correctWeightOutputModel = $('#' + this.element_.id)
      .find('[data-field="FieloELR__CorrectWeight__c"]')[0]
        .cloneNode(true);

    // Removing Input Labels
    this.incorrectWeightModel.removeChild(
      $(this.incorrectWeightModel).find('label')[0]);
    this.penaltyPerAttemptModel.removeChild(
      $(this.penaltyPerAttemptModel).find('label')[0]);
    this.correctWeightModel.removeChild(
      $(this.correctWeightModel).find('label')[0]);
  };

  // El componente se registra por si solo.
  // Asume que el componentHandler esta habilitado en el scope global
  fielo.helper.register({
    constructor: FieloQuestionManage,
    classAsString: 'FieloQuestionManage',
    cssClass: 'fielosf-question-manage',
    widget: true
  });
})();
