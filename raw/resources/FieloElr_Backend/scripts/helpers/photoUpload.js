(function() {
  'use strict';

  /**
   * @description Controller for the photo upload
   * Implements design pattern define at MDL
   * {@link https://github.com/jasonmayes/mdl-component-design-pattern}
   *
   * @version 1
   * @author Nicolás Alejandro Soberón <nicolas.soberon@fielo.com>
   * @param {HTMLElement} element - Element that will be improved
   * @constructor
   */
  var FieloPhotoUpload = function FieloPhotoUpload(element) {
    this.element_ = element;

    // Initialize instance.
    this.init();
  };
  window.FieloPhotoUpload = FieloPhotoUpload;

  /**
   * Saves the constants
   * @enum {string | number}
   * @private
   */
  FieloPhotoUpload.prototype.Constant_ = {
    DATA_EXTERNAL_URL_NAME: 'data-external-url-name',
    DATA_FIELD_NAME: 'data-field-name',
    DATA_FOLDER_ID: 'data-folder-id',
    DATA_RECORD: 'data-record',
    DATA_RECORD_NAME: 'data-record-name',
    DATA_SOBJECT_NAME: 'data-sobject-name',
    DATA_INSTANCE: 'data-instance',
    DATA_DOCUMENT: 'data-document-id',
    DATA_RELOAD: 'data-reload',
    DATA_VALUE: 'data-value',
    DELETE_CONTROLLER: (BackEndJSSettings.RESOURCE.NAMESPACE === '.') ?
      'PhotoUploadController.remove' :
      BackEndJSSettings.RESOURCE.NAMESPACE + 'PhotoUploadController.remove',
    SAVE_CONTROLLER: (BackEndJSSettings.RESOURCE.NAMESPACE === '.') ?
      'PhotoUploadController.saveWithCaption' :
      BackEndJSSettings.RESOURCE.NAMESPACE + 'PhotoUploadController.saveWithCaption',
    GET_CAPTION_CONTROLLER: (BackEndJSSettings.RESOURCE.NAMESPACE === '.') ?
    'PhotoUploadController.getImageCaption' :
    BackEndJSSettings.RESOURCE.NAMESPACE + 'PhotoUploadController.getImageCaption'
  };

  /**
   * Saves css class names
   * @enum {string}
   * @private
   */
  FieloPhotoUpload.prototype.CssClasses_ = {
    CANCEL: 'slds-button--cancel',
    CONTAINER: 'fielosf-recent-records__container',
    CROPPER: 'fielosf-cropper',
    DELETE: 'slds-button--delete',
    DOCUMENT: 'slds-button--document',
    DOCUMENT_PICKLIST: 'fielosf-document-picklist',
    EDIT: 'slds-button--edit',
    EXTERNAL_BTN: 'slds-button--url',
    EXTERNAL_INPUT: 'fielosf-external-url',
    EXTERNAL_LINK: 'fielosf-external-link',
    EXTERNAL_LINK_LABEL: 'fielosf-external-link-label',
    FIELD: 'fielosf-output',
    HIDE: 'slds-hide',
    IMAGE: '',
    INPUT_FILE: 'fielosf-input-file',
    INPUT_CAPTION: 'fielosf-image-caption',
    MODEL: 'fielosf-recent-records__model',
    PREVIEW: 'slds-button--preview',
    RECORD_IMG: 'fielosf-recordImg',
    REPLACE: 'slds-button--replace',
    SAVE: 'slds-button--save',
    UPLOAD_BTN: 'slds-button--upload'

  };

  /**
  * Retrieves all data needed to save to SalesForce
  */
  FieloPhotoUpload.prototype.handleClickOnSave_ = function() {
    // var div = document.getElementById("sizePhotoLimits");
    // div.style.display = 'none';
    fielo.util.spinner.FieloSpinner.show();
    var status = '';
    var imageUrl = '';
    var data = {};
    data.Id = this.record_;
    data.Name = this.recordName_;

    if (this.isExternal_) {
      status = 'external';
      data[this.dataExternalURL_] = this.externalUrlInput_.value;
      data[this.fieldName_] = '';
    }

    if (this.isDocument_) {
      status = 'internal';
      imageUrl = $(this.imEditing_ ? this.recordImg_ : this.cropperImage_)
        .cropper('getCroppedCanvas').toDataURL(this.imageType_);
      this.externalUrlInput_.value = '';
      data[this.dataExternalURL_] = '';
    }

    // the user is choosing from a list of documents
    /*
    // TODO if shoose from picklist
    if (status === 'existing') {
      imageUrl = '';
      this.externalUrlInput_.value = '';
      data[this.dataExternalURL_] = '';
      data[this.fieldName_] = this.documentPicklist_.get('value');
    }
    */

    try {
      Visualforce.remoting.Manager.invokeAction(
        this.Constant_.SAVE_CONTROLLER,
        data,
        this.folderId_,
        this.objectName_,
        this.fieldName_,
        this.dataExternalURL_,
        status,
        imageUrl,
        this.instance_,
        this.imageCaption_.value,
        this.processSavesAndDelete_.bind(this),
        {
          escape: false
        }
      );
    } catch (e) {
      console.warn(e);
    }
  };

  /**
  * Deletes photo on SalesForce
  */
  FieloPhotoUpload.prototype.deleteFile_ = function() {
    // var div = document.getElementById("sizePhotoLimits");
    // div.style.display = 'block';
    fielo.util.spinner.FieloSpinner.show();
    this.isAction_('deleting');
    var data = {};
    data.Id = this.record_;
    try {
      Visualforce.remoting.Manager.invokeAction(
        this.Constant_.DELETE_CONTROLLER,
        data,
        this.fieldName_,
        this.dataExternalURL_,
        this.processSavesAndDelete_.bind(this),
        {
          escape: false
        }
      );
    } catch (e) {
      this.isAction_();
      console.warn(e);
    }
  };

  /**
  * Sets document id Value
  * @param {String} value - Id to assign to the document id
  */
  FieloPhotoUpload.prototype.setDocumentId_ = function(value) {
    this.documentId_ = value;
    this.element_.setAttribute(this.Constant_.DATA_DOCUMENT, value);
  };

  /**
  * Process Remote Action
  * @param {sObject} result - Result of theremote action.
  */
  FieloPhotoUpload.prototype.processSavesAndDelete_ = function(result) {
    var notify = fielo.util.notify.create();
    notify.FieloNotify.addMessages([
      result.messages[0].summary
    ]);
    var theme = result.messages[0].severity.toLowerCase() === 'Error'.toLowerCase() ? 'Error' : 'Success';
    notify.FieloNotify.setTheme(theme);
    notify.FieloNotify.show();
    if (theme === 'Error') {
      this.handleClickOnCancel_();
      fielo.util.spinner.FieloSpinner.hide();
      return;
    }

    if (theme !== 'Error' && this.reload_) {
      this.refresh_();
    }

    // Updates the document id
    this.setDocumentId_(result.recordsId[0] || '');

    var imgEl;
    if (this.isDocument_ && !this.imDeleting_) {
      if (this.imEditing_) {
        imgEl = this.recordImg_;
      } else {
        imgEl = this.cropperImage_;
      }

      this.recordImg_.src =
        $(imgEl).cropper('getCroppedCanvas').toDataURL(this.imageType_);
      this.destroyCropper_(this.recordImg_);
    }

    this.externalLink_.innerText = result.redirectURL;
    if (this.isExternal_) {
      // updates url value
      this.externalLink_.innerText = this.externalUrlInput_.value;
      this.externalLink_.setAttribute(
        this.Constant_.DATA_VALUE,
        this.externalUrlInput_.value
      );

      this.recordImg_.src = this.externalUrlInput_.value;
    }

    if (this.imDeleting_) {
      this.recordImg_.src = '';
      this.externalUrlInput_.value = '';
      this.setDocumentId_();
      this.isStep_('new');
    } else {
      this.isOld_ = true;
    }

    // reset Actions
    this.fileImage_.value = '';
    this.isAction_();
    this.showElements_();
    fielo.util.spinner.FieloSpinner.hide();
  };

  /**
  * Refresh Page
  */
  FieloPhotoUpload.prototype.refresh_ = function() {
    location.reload();
  };

  /**
   * Inits the cropper plugin
   * @param {HTMLElement} element - element to be the cropper
   */
  FieloPhotoUpload.prototype.initCropper_ = function(element) {
    var width = $(element).width();
    var height = $(element).height();
    if (width <= 200) {
      height = Math.floor(300 * height / width);
      width = 300;
    }

    if (height <= 100) {
      width = Math.floor(200 * width / height);
      height = 200;
    }

    $(element).cropper({
      rotatable: false,
      zoomable: false,
      movable: false,
      scalable: false,
      minContainerWidth: width,
      minContainerHeight: height,
      autoCropArea: 1,
      viewMode: 3,
      ready: function() {
        var container =
          this.element_.getElementsByClassName('cropper-container')[0];
        if (container) {
          container.classList.add('slds-m-top--large');
        }
      }.bind(this)
    });
  };

  /**
  * Destroys the cropper
  * @param {HTMLElement} element - Elemento del que se elimina el cropper.
  */
  FieloPhotoUpload.prototype.destroyCropper_ = function(element) {
    $(element).cropper('destroy');
    this.cropperImage_.src = '';
  };

  /**
  * Loads the local image selected with the cropper
  */
  FieloPhotoUpload.prototype.loadImage_ = function() {
    this.destroyCropper_(this.cropperImage_);
    this.showElements_();
    if (this.fileImage_.files[0]) {
      this.cropperImage_.src = URL.createObjectURL(this.fileImage_.files[0]);
      this.imageType_ = this.fileImage_.files[0].type;
      this.cropperImage_.addEventListener(
        'load',
        this.initCropper_.bind(this, this.cropperImage_)
      );
    }
  };

  /**
  * Opens a popup witha preview of the image
  */
  FieloPhotoUpload.prototype.previewImage_ = function() {
    var win = window.open(
    );
    if (this.isExternal_) {
      win.document.body.innerHTML =
        '<img class="fielosf-js-photoupload__imagePreview" src="' +
        this.externalUrlInput_.value + '" />';
    } else {
      var imgEl = this.imEditing_ ? this.recordImg_ : this.cropperImage_;
      win.document.body.append($(imgEl)
        .cropper('getCroppedCanvas'));
    }
  };

  /**
  * Handles click on external url button
  */
  FieloPhotoUpload.prototype.handleClickOnExternalUrl_ = function() {
    this.isAction_('uploading');
    this.isStep_('external');
    this.showElements_();
  };

  /**
  * Handles click on cancel
  */
  FieloPhotoUpload.prototype.handleClickOnCancel_ = function() {
    if (this.imUploading_)
      if (this.isDocument_) {
        this.fileImage_.value = '';
        this.destroyCropper_(this.cropperImage_);
        if (this.documentId_ === '' || this.documentId_ === undefined) {
          this.isStep_('new');
        }
      }
    if (this.isExternal_) {
      this.externalUrlInput_.value = '';
      if (this.documentId_ === '') {
        this.isStep_('external');
      }
    }
    if (this.isNew_) {
      this.isStep_('new');
    } else if (this.documentId_ === '') {
      this.isStep_('external');
    } else {
      this.isStep_('document');
    }
    if (this.imEditing_) {
      this.destroyCropper_(this.recordImg_);
    }
    this.isAction_();
    this.showElements_();
  };

  /**
  * Handles click on external url
  */
  FieloPhotoUpload.prototype.handleClickOnUpload_ = function() {
    this.isAction_('uploading');
    this.isStep_('document');
    this.fileImage_.click();
  };

  /**
  * Handles click on edit button
  */
  FieloPhotoUpload.prototype.handleClickOnEdit_ = function() {
    // var div = document.getElementById("sizePhotoLimits");
    // div.style.display = 'block';
    this.isAction_('editing');
    this.initCropper_(this.recordImg_);
    this.showElements_();
  };

  /**
  * Handles click on replace button
  */
  FieloPhotoUpload.prototype.handleClickOnReplace_ = function() {
    // var div = document.getElementById("sizePhotoLimits");
    // div.style.display = 'block';
    this.isAction_('replacing');
    this.showElements_();
  };

  /**
  * Binds listeners
  */
  FieloPhotoUpload.prototype.setListeners_ = function() {
    this.upload_.addEventListener('click',
      this.handleClickOnUpload_.bind(this)
    );

    this.external_.addEventListener('click',
      this.handleClickOnExternalUrl_.bind(this)
    );

    this.preview_.addEventListener('click',
      this.previewImage_.bind(this)
    );

    this.replace_.addEventListener('click',
      this.handleClickOnReplace_.bind(this)
    );

    if (this.documentPicklist_) {
      this.document_.addEventListener('click', function() {
        this.showElements_();
        this.documentPicklist_.classList.remove(this.CssClasses_.HIDE);
      }.bind(this));
    }

    this.edit_.addEventListener('click',
      this.handleClickOnEdit_.bind(this)
    );

    this.save_.addEventListener('click',
      this.handleClickOnSave_.bind(this)
    );

    this.delete_.addEventListener('click',
      this.deleteFile_.bind(this)
    );

    this.cancel_.addEventListener('click',
      this.handleClickOnCancel_.bind(this)
    );

    this.fileImage_.addEventListener('change',
      this.loadImage_.bind(this)
    );

    this.externalUrlInput_.addEventListener('keypress', function(e) {
      var key = e.which || e.keyCode;
      if (key === 13) {
        // 13 is enter
        // code for enter
        this.save_.click();
      }
    }.bind(this));
  };

  /**
  * Gets the image's caption
  */
 /**
  * Binds listeners
  */
  FieloPhotoUpload.prototype.getImageCaption_ = function() {
    try {
      var data = {};
      data.Id = this.record_;
      data.Name = this.recordName_;

      Visualforce.remoting.Manager.invokeAction(
        this.Constant_.GET_CAPTION_CONTROLLER,
        data,
        'fieloplt__imagecaption__c',
        this.objectName_,
        this.getImageCaptionHandler_.bind(this),
        {escape: false}
      );
      console.log(data);
    } catch (e) {
      console.warn(e);
    }
  };

  FieloPhotoUpload.prototype.getImageCaptionHandler_ = function(result) {
    var this_ = this;
    if (result) {
      this.imageCaption_.value = result;
    }
  };

  /**
  * Init data elements
  */
  FieloPhotoUpload.prototype.initData_ = function() {
    this.record_ =
      this.element_.getAttribute(this.Constant_.DATA_RECORD);
    this.recordName_ =
      this.element_.getAttribute(this.Constant_.DATA_RECORD_NAME);
    this.objectName_ =
      this.element_.getAttribute(this.Constant_.DATA_SOBJECT_NAME);
    this.folderId_ =
      this.element_.getAttribute(this.Constant_.DATA_FOLDER_ID);
    this.fieldName_ =
      this.element_.getAttribute(this.Constant_.DATA_FIELD_NAME);
    this.dataExternalURL_ =
      this.element_.getAttribute(this.Constant_.DATA_EXTERNAL_URL_NAME);
    this.instance_ =
      this.element_.getAttribute(this.Constant_.DATA_INSTANCE);
    this.setDocumentId_(
      this.element_.getAttribute(this.Constant_.DATA_DOCUMENT) || ''
    );

    if (this.element_.getAttribute(this.Constant_.DATA_RELOAD) === 'true') {
      this.reload_ = true;
    } else {
      this.reload_ = false;
    }
  };

  /**
  * Init External elements
  */
  FieloPhotoUpload.prototype.initExternalElements_ = function() {
    /* EXTERNAL URL INPUT */
    this.externalUrlInput_ = this.element_
      .getElementsByClassName(this.CssClasses_.EXTERNAL_INPUT)[0];
    this.externalLinkLabel_ = this.element_
      .getElementsByClassName(this.CssClasses_.EXTERNAL_LINK_LABEL)[0];
    this.externalLink_ = this.element_
      .getElementsByClassName(this.CssClasses_.EXTERNAL_LINK)[0] || null;
    if (this.externalLink_.getAttribute(this.Constant_.DATA_VALUE) !== '') {
      this.externalLink_.innerText =
        this.externalLink_.getAttribute(this.Constant_.DATA_VALUE);
    }
  };

  /**
  * Init actions
  */
  FieloPhotoUpload.prototype.initActions_ = function() {
    this.isAction_();
  };

  /**
  * Inits images
  */
  FieloPhotoUpload.prototype.initImages_ = function() {
    this.newImage_ = this.element_
      .getElementsByClassName(this.CssClasses_.IMAGE)[0];
    this.fileImage_ = this.element_
      .getElementsByClassName(this.CssClasses_.INPUT_FILE)[0];
    this.cropperImage_ = this.element_
      .getElementsByClassName(this.CssClasses_.CROPPER)[0];
    this.recordImg_ = this.element_
      .getElementsByClassName(this.CssClasses_.RECORD_IMG)[0];
    this.imageCaption_ = this.element_
      .getElementsByClassName(this.CssClasses_.INPUT_CAPTION)[0];
  };

  /**
  * Sets the step where the user is
  * @param {string} step - name of step
  */
  FieloPhotoUpload.prototype.isStep_ = function(step) {
    step = step || '';
    // there's no image
    this.isNew_ = false;
    // the image is a document
    this.isDocument_ = false;
    // the image is no from SalesForce
    this.isExternal_ = false;

    switch (step.toLowerCase()) {
      case 'new':
        this.isNew_ = true;
        this.isOld_ = false;
        break;
      case 'document':
        this.isDocument_ = true;
        break;
      case 'external':
        this.isExternal_ = true;
        break;
      default:
        // statements_def
        break;
    }
  };

  /**
  * Inits steps
  */
  FieloPhotoUpload.prototype.initSteps_ = function() {
    // By default image exist so it's an old image
    this.isOld_ = true;
    // reset steps
    this.isStep_();

    // No image
    if (
      this.recordImg_.getAttribute('src') === '' &&
      this.externalLink_.getAttribute(this.Constant_.DATA_VALUE) === ''
    ) {
      this.isStep_('new');
    }

    // Internal image
    if (this.documentId_ !== '') {
      this.isStep_('document');
    }

    // External image
    if (this.recordImg_.getAttribute('src') !== '' && !this.isDocument_) {
      this.isStep_('external');
    }
  };

  /**
  * Sets the action that the user is doing
  * @param {string} action - name of action
  */
  FieloPhotoUpload.prototype.isAction_ = function(action) {
    action = action || '';
    // the user is uploading an image (document or url)
    this.imUploading_ = false;
    // the user is deleting an image (document or url)
    this.imDeleting_ = false;
    // the user is editing an image (document or url)
    this.imEditing_ = false;
    // the user is replacing an image (url)
    this.imReplacing_ = false;

    switch (action.toLowerCase()) {
      case 'uploading':
        this.imUploading_ = true;
        break;
      case 'deleting':
        this.imDeleting_ = true;
        break;
      case 'editing':
        this.imEditing_ = true;
        break;
      case 'replacing':
        this.imReplacing_ = true;
        break;
      default:
        // statements_def
        break;
    }
  };

  /**
  * Inits buttons states
  */
  FieloPhotoUpload.prototype.initButtons_ = function() {
    this.upload_ = this.element_
      .getElementsByClassName(this.CssClasses_.UPLOAD_BTN)[0];
    this.external_ = this.element_
      .getElementsByClassName(this.CssClasses_.EXTERNAL_BTN)[0];
    this.preview_ = this.element_
      .getElementsByClassName(this.CssClasses_.PREVIEW)[0];
    this.cancel_ = this.element_
      .getElementsByClassName(this.CssClasses_.CANCEL)[0];
    this.replace_ = this.element_
      .getElementsByClassName(this.CssClasses_.REPLACE)[0];
    this.document_ = this.element_
      .getElementsByClassName(this.CssClasses_.DOCUMENT)[0];
    this.save_ = this.element_
      .getElementsByClassName(this.CssClasses_.SAVE)[0];
    this.delete_ = this.element_
      .getElementsByClassName(this.CssClasses_.DELETE)[0];
    this.edit_ = this.element_
      .getElementsByClassName(this.CssClasses_.EDIT)[0];
    this.documentPicklist_ = this.element_
      .getElementsByClassName(this.CssClasses_.DOCUMENT_PICKLIST)[0];
  };

  /**
  * Hides all elements
  */
  FieloPhotoUpload.prototype.hideElements_ = function() {
    // buttons
    this.upload_.classList.add(this.CssClasses_.HIDE);
    this.external_.classList.add(this.CssClasses_.HIDE);
    this.replace_.classList.add(this.CssClasses_.HIDE);
    this.delete_.classList.add(this.CssClasses_.HIDE);
    this.edit_.classList.add(this.CssClasses_.HIDE);
    this.preview_.classList.add(this.CssClasses_.HIDE);
    this.cancel_.classList.add(this.CssClasses_.HIDE);
    this.save_.classList.add(this.CssClasses_.HIDE);

    // other elements
    if (this.documentPicklist_) {
      this.document_.classList.add(this.CssClasses_.HIDE);
    }
    this.externalUrlInput_.classList.add(this.CssClasses_.HIDE);
    this.externalLink_.classList.add(this.CssClasses_.HIDE);
    this.externalLinkLabel_.classList.add(this.CssClasses_.HIDE);
    this.recordImg_.classList.add(this.CssClasses_.HIDE);
  };

  /**
  * Shows elements for each case
  */
  FieloPhotoUpload.prototype.showElements_ = function() {
    this.hideElements_();

    if (this.imEditing_ || this.imUploading_) {
      this.preview_.classList.remove(this.CssClasses_.HIDE);
      this.save_.classList.remove(this.CssClasses_.HIDE);
    }

    if (this.isExternal_ && this.imUploading_) {
      this.externalUrlInput_.classList.remove(this.CssClasses_.HIDE);
      this.externalUrlInput_.focus();
    }

    // It was saved. Or it's existing. Have document or External image
    if (
      !this.isNew_ &&
      !this.imEditing_ && !this.imReplacing_ && !this.imUploading_
    ) {
      this.replace_.classList.remove(this.CssClasses_.HIDE);
      this.delete_.classList.remove(this.CssClasses_.HIDE);
      this.recordImg_.classList.remove(this.CssClasses_.HIDE);
      if (this.isDocument_) {
        this.edit_.classList.remove(this.CssClasses_.HIDE);
        this.destroyCropper_(this.cropperImage_);
      } else {
        this.externalLinkLabel_.classList.remove(this.CssClasses_.HIDE);
        this.externalLink_.classList.remove(this.CssClasses_.HIDE);
      }
    }
    if (this.isNew_ || this.imReplacing_ && !this.imUploading_) {
      this.upload_.classList.remove(this.CssClasses_.HIDE);
      this.external_.classList.remove(this.CssClasses_.HIDE);
    }
    if (this.imReplacing_ && this.isExternal_) {
      this.external_.classList.remove(this.CssClasses_.HIDE);
    }
    if (this.imReplacing_ || this.imEditing_ || this.imUploading_) {
      this.cancel_.classList.remove(this.CssClasses_.HIDE);
    }
  };

  /**
  * Initialize the element
  */
  FieloPhotoUpload.prototype.init = function() {
    if (this.element_) {
      this.initData_();
      this.initImages_();
      this.initExternalElements_();
      this.initButtons_();
      this.initActions_();
      this.initSteps_();
      this.setListeners_();
      this.getImageCaption_();
      // All set now ...
      this.showElements_();
    }
  };

  // The component register by itself
  // Assumes the componentHandler is enable at the global scope
  componentHandler.register({
    constructor: FieloPhotoUpload,
    classAsString: 'FieloPhotoUpload',
    cssClass: 'fielosf-photo-upload',
    widget: true
  });
})();
