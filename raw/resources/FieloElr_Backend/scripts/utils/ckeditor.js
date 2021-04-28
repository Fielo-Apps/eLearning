/**
 * Init of CKEDITOR
 */

function upgradeCKEditor() {
  if (typeof CKEDITOR !== 'undefined') {
    // Search if there is any CKEDITOR available
    for (var i in CKEDITOR.instances) {
      var name = CKEDITOR.instances[i].name;
      CKEDITOR.instances[name].on('instanceReady', function() {
        CKEDITOR.instances[name].destroy();
        CKEDITOR.replace(name, {
          baseHref: protocolAndHost + '/ckeditor/ckeditor-4.x/rel/',
          customConfig: 'sfdc-config.js?t=4.11.2.22',
          height: '425',
          sfdcLabels: {
            CkeMediaEmbed: {
              title: 'Embed Multimedia Content',
              description: 'Use &lt;iframe&gt; code from DailyMotion,' +
                ' Vimeo, and Youtube.',
              subtitle: 'Paste &amp;lt;iframe&amp;gt; code here:',
              exampleTitle: 'Example:',
              example: '\n\n&lt;iframe width=\&quot;560\&quot; ' +
                'height=\&quot;315\&quot; src=\&quot;' +
                'https://www.youtube.com/embed/KcOm0TNvKBA\&quot; ' +
                'frameborder=\&quot;0\&quot; allowfullscreen&gt;&lt;' +
                '/iframe&gt;\n\n',
              iframeMissing: 'Invalid &lt;iframe&gt; element. Please ' +
                'use valid code from the approved sites.'
            },
            sfdcSwitchToText: {
              sfdcSwitchToTextAlt: 'Use plain text'
            },
            CkeImageDialog: {
              uploadTab: 'Upload Image',
              infoTab_url: 'URL', // eslint-disable-line camelcase
              error: 'Error:',
              uploadTab_desc_info: 'Enter a description of the image ' + // eslint-disable-line camelcase
                'for visually impaired users',
              uploadTab_desc: 'Description', // eslint-disable-line camelcase
              infoTab_url_info: 'Example: ' + // eslint-disable-line camelcase
                'http://www.mysite.com/myimage.jpg',
              btn_insert: 'Insert', // eslint-disable-line camelcase
              defaultImageDescription: 'User-added image',
              missingUrlError: 'You must enter a URL',
              uploadTab_file: 'Select Image', // eslint-disable-line camelcase
              infoTab_desc: 'Description', // eslint-disable-line camelcase
              btn_upadte: 'Update', // eslint-disable-line camelcase
              wrongFileTypeError: 'You can insert only .gif .jpeg and ' +
                '.png files.',
              btn_update_tooltip: 'Update Image', // eslint-disable-line camelcase
              infoTab: 'Web Address',
              btn_insert_tooltip: 'Insert Image', // eslint-disable-line camelcase
              title: 'Insert Image',
              infoTab_desc_info: 'Enter a description of the image for ' + // eslint-disable-line camelcase
                'visually impaired users',
              imageUploadLimit_info: 'Max number of upload images ' + // eslint-disable-line camelcase
                'exceeded',
              uploadTab_file_info: 'Maximum size 1 MB. Only png, gif or' + // eslint-disable-line camelcase
                ' jpeg',
              btn_update: 'Update' // eslint-disable-line camelcase
            },
            CkeImagePaste: {
              CkeImagePasteWarning: 'Pasting an image is not working ' +
                'properly with Firefox, please use ' +
                '[Copy Image location] instead.'
            }
          },
          disableNativeSpellChecker: true,
          language: 'en-us',
          // allowIframe: false,
          sharedSpaces: {
            top: 'cke_topSpace',
            bottom: ' cke_bottomSpace'
          },
          filebrowserImageUploadUrl: '/_ui/common/request/servlet/' +
            'RtaImageUploadServlet',
          // Custom config overrides salesforce
          toolbarCanCollapse: true,
          resize_enabled: true, // eslint-disable-line camelcase
          enterMode: CKEDITOR.ENTER_BR,
          shiftEnterMode: CKEDITOR.ENTER_P,
          forcePasteAsPlainText: true,
          forceSimpleAmpersand: false,
          pasteFromWordRemoveFontStyles: true,
          pasteFromWordRemoveStyles: true,
          imageUploadAllowedExtensions: '.(jpg|gif|jpeg|png|bmp|' +
            'jfif|jpe|pjpeg)$',
          imageUploadDeniedExtensions: '',
          extraAllowedContent: [
            'div{*}(*); span{*}(*); p{*}(*); br{*}(*); hr{*}(*);',
            'iframe{*}(*);',
            'h1{*}(*); h2{*}(*); h3{*}(*); h4{*}(*); h5{*}(*); ' +
              'h6{*}(*);',
            'a[*]{*}(*);',
            'img[!src,alt,width,height,border]{*}(*);',
            'font[face,size,color];',
            'strike; s; b; em; strong; i; big; small; sub; sup; ' +
              'blockquote; ins; kbd; pre{*}(*); tt;',
            'abbr; acronym; address; bdo; caption; cite; code; ' +
              'col; colgroup;',
            'dd; del; dfn; dl; dt; q; samp; var;',
            'table{*}(*)[align,border,cellpadding,cellspacing,' +
              'summary];',
            'caption{*}(*); tbody{*}(*); thead{*}(*); tfoot{*}(*);',
            'th{*}(*)[scope,colspan,rowspan,align,valign]; ' +
              'tr{*}(*)[align,valign]; td{*}(*)[scope,colspan,' +
              'rowspan,align,valign];'
          ],
          coreStyles_strike: { // eslint-disable-line camelcase
            element: 'strike'
          },
          coreStyles_bold: { // eslint-disable-line camelcase
            element: 'b'
          },
          coreStyles_italic: { // eslint-disable-line camelcase
            element: 'i'
          },
          toolbar_Full: [ // eslint-disable-line camelcase
            {
              name: 'document',
              items: [
                'Source', '-', 'Save', 'Preview', 'Print', '-', 'Templates'
              ]
            },
            {
              name: 'clipboard',
              items: [
                'Cut', 'Copy', 'Paste', 'PasteText', 'PasteFromWord', '-',
                'Undo', 'Redo'
              ]
            },
            {
              name: 'editing',
              items: [
                'Find', 'Replace', '-', 'SelectAll', '-'
              ]
            },
            '/',
            {
              name: 'basicstyles',
              items: [
                'Bold', 'Italic', 'Underline', 'Strike', '-',
                'RemoveFormat'
              ]
            },
            {
              name: 'paragraph',
              items: [
                'NumberedList', 'BulletedList', '-', 'Outdent', 'Indent',
                '-', 'Blockquote', '-', 'JustifyLeft', 'JustifyCenter',
                'JustifyRight', 'JustifyBlock', '-', 'BidiLtr', 'BidiRtl'
              ]
            },
            '/',
            {
              name: 'links',
              items: [
                'Link', 'Unlink', 'Anchor'
              ]
            },
            {
              name: 'insert',
              items: [
                'sfdcImage', 'Table', 'HorizontalRule', 'Smiley',
                'SpecialChar', 'PageBreak'
              ]
            },
            '/',
            {
              name: 'styles',
              items: [
                'Format', 'FontSize'
              ]
            },
            {
              name: 'colors',
              items: [
                'TextColor', 'BGColor'
              ]
            },
            {
              name: 'tools',
              items: [
                'Maximize'
              ]
            }
          ],
          toolbar: 'Full',
          removePlugins: 'elementspath, image',
          extraPlugins: 'sfdcImage,sfdcMediaEmbed,sfdcSmartLink,' +
          'sfdcCodeBlock,sfdcTable,sfdcVfAjax4J',
          removeDialogTabs: '',
          plugins: 'about,a11yhelp,basicstyles,bidi,blockquote,' +
          'clipboard,colorbutton,colordialog,contextmenu,' +
          'dialogadvtab,div,elementspath,enterkey,entities,' +
          'filebrowser,find,flash,floatingspace,font,format,' +
          'forms,horizontalrule,htmlwriter,image,iframe,' +
          'indentlist,indentblock,justify,language,link,list,' +
          'liststyle,magicline,maximize,newpage,pagebreak,' +
          'pastefromword,pastetext,preview,print,removeformat,' +
          'resize,save,selectall,showblocks,showborders,smiley,' +
          'sourcearea,specialchar,stylescombo,tab,table,' +
          'tabletools,templates,toolbar,undo,wysiwygarea'
        });
      });
    }
  }
}

window.fielo.util.upgradeCKEditor = upgradeCKEditor;
