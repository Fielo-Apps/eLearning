/**
* @brief Class Used to upload a photo as attach to a specific record
*/
global with sharing class PhotoUploadController {


/* Manejo del Folder */
    public String folderUniqueName {get; set;}
    public Id folderId {get {
        if ( folderId == null ) {
            Folder folder;
            List<String> folderNames = folderUniqueName.split( '__' );
            // SR: CRUD Check
            if ( Schema.sObjectType.Folder.isAccessible() ) {
                // SR: FLS Check
                if ( Schema.sObjectType.Folder.fields.DeveloperName.isAccessible() ) {
                    if ( folderNames.size() == 1 ) {
                        folder = [SELECT Id FROM Folder WHERE DeveloperName =: folderUniqueName];
                    } else {
                        folder = [SELECT Id FROM Folder WHERE DeveloperName =: folderNames.get(1) AND NamespacePrefix = :folderNames.get(0)];
                    }
                } else {
                    throw new FieloPLT.FieloException(String.format(Label.security_error_field_not_readable, new List<String>{'Folder', 'DeveloperName'}));
                }
            } else {
                throw new FieloPLT.FieloException(String.format(Label.security_error_object_not_readable, new List<String>{'Folder'}));
            }
            folderId = folder.Id;
        }
        return folderId;
    } set;}

    public List<PicklistController.Entry>  existingDocuments { get {
        if ( existingDocuments == null ) {
            existingDocuments = new List<PicklistController.Entry>();
            // SR: CRUD Check
            if ( Schema.sObjectType.Document.isAccessible() ) {
                // SR: FLS Check
                if ( Schema.sObjectType.Document.fields.Name.isAccessible() && Schema.sObjectType.Document.fields.FolderId.isAccessible() && Schema.sObjectType.Document.fields.LastModifiedDate.isAccessible() ) {
                    for ( Document d : [SELECT Id, Name FROM Document WHERE folderId = :folderId ORDER BY LastModifiedDate DESC LIMIT 255] ) {
                        existingDocuments.add( new PicklistController.Entry(d.Id, d.Name));
                    }
                } else {
                    throw new FieloPLT.FieloException(String.format(Label.security_error_field_not_readable, new List<String>{'Document', 'Name, FolderId, LastModifiedDate'}));
                }
            } else {
                throw new FieloPLT.FieloException(String.format(Label.security_error_object_not_readable, new List<String>{'Document'}));
            }
        }
        return existingDocuments;
    } set;}

    //component attributes
    public SObject recordObject {get; set; }
    public String fieldNameObject {get; set;}
    public String externalURLNameObject {get; set;}
    public String getEncImage(){
        String base64 = '';
        List<Document> doc;
        // SR: CRUD Check
        if ( Schema.sObjectType.Document.isAccessible() ) {
            // SR: FLS Check
            if ( Schema.sObjectType.Document.fields.Body.isAccessible() && Schema.sObjectType.Document.fields.ContentType.isAccessible() ) {
                doc = [select body, ContentType from Document where id =: ((Id)recordObject.get(fieldNameObject)) limit 1];
            } else {
                throw new FieloPLT.FieloException(String.format(Label.security_error_field_not_readable, new List<String>{'Document', 'Body, ContentType'}));
            }
        } else {
            throw new FieloPLT.FieloException(String.format(Label.security_error_object_not_readable, new List<String>{'Document'}));
        }
        if( !doc.isEmpty() ){
            base64 = EncodingUtil.Base64Encode(doc.get(0).Body);
            String contentType = doc.get(0).ContentType;
            return ( base64 == '' ) ? '': 'data:' + contentType +  ';base64,' + base64;
        }
        return null;
    }

    public Boolean hasImage {get{
        if(hasImage == null){
            String encImage = getEncImage();
            if( encImage == null && recordObject.get(fieldNameObject) == null && recordObject.get(externalURLNameObject) == null ){
                return false;
            } else if( encImage == null && recordObject.get(fieldNameObject) == null && recordObject.get(externalURLNameObject) != null ){
                return true;
            } else if( encImage == null && recordObject.get(fieldNameObject) != null && recordObject.get(externalURLNameObject) != null ){
                return false;
            } else if( encImage != null && recordObject.get(fieldNameObject) != null && recordObject.get(externalURLNameObject) != null ){
                return true;
            }
        }
        return false;
    } set;}


/*
    Metodo Save
    status: internal, external, existing
*/
    @RemoteAction
    global static RemoteActionResult save( sObject record, String folderId, String objectName, String fieldName, String externalURLField, String status, String photoBase64, String instance){
        Savepoint sp;
        RemoteActionResult result = new RemoteActionResult();
        try{
            sp = Database.setSavepoint();
            DescribeSObjectResult objectDescribe = Schema.describeSObjects(new String[]{objectName})[0];
            DescribeSObjectResult recordObjectDescribe = record.getSObjectType().getDescribe();
            Map<String, Schema.SObjectField> fieldsMap = objectDescribe.fields.getMap();
            Map<String, Schema.SObjectField> recordFieldsDescribe = recordObjectDescribe.fields.getMap();
            Map<String, Schema.SObjectField> documentFieldsMap = Schema.sObjectType.Document.fields.getMap();

            String documentId = null;

            if ( status == 'external' || status == 'existing' ) {
                // SR: CRUD Check
                if (recordObjectDescribe.isUpdateable() && recordObjectDescribe.isCreateable() ) {
                    // SR: FLS Check
                    for ( String f : record.getPopulatedFieldsAsMap().keySet() ) {
                        if ( f != 'Id' && !recordFieldsDescribe.get(f).getDescribe().isCreateable() ) {
                            throw new FieloPLT.FieloException(String.format(Label.security_error_field_not_insertable, new List<String>{recordObjectDescribe.getName(), f}));
                        }
                        if ( f != 'Id' && !recordFieldsDescribe.get(f).getDescribe().isUpdateable() ) {
                            throw new FieloPLT.FieloException(String.format(Label.security_error_field_not_updateable, new List<String>{recordObjectDescribe.getName(), f}));
                        }
                    }
                    upsert record;
                } else {
                    throw new FieloPLT.FieloException(String.format(Label.security_error_field_not_updateable, new List<String>{recordObjectDescribe.getName()}));
                }
            } else {
                Id recordId = record.Id;
                Document currentDocument = new Document();
                if ( status == 'internal' ) {
                    // Vuelve a hacer el query por si sube varias veces en la misma page
                    sObject existingRecord;

                    // SR: CRUD Check
                    if ( objectDescribe.isAccessible() ) {
                        // SR: FLS Check
                        if ( fieldsMap.get(fieldName).getDescribe().isAccessible() ) {
                            existingRecord = Database.query('SELECT ' + fieldName + ' FROM ' + objectName + ' WHERE Id =: recordId');
                        } else {
                            throw new FieloPLT.FieloException(String.format(Label.security_error_field_not_readable, new List<String>{objectName, fieldName}));
                        }
                    } else {
                        throw new FieloPLT.FieloException(String.format(Label.security_error_object_not_readable, new List<String>{objectName}));
                    }

                    documentId = (String) existingRecord.get(fieldName);
                    // Si No es un Documento Nuevo y esta siendo usado => Lo clona para no cropear el original
                    if( !String.isBlank(documentId) ){
                        List<Document> documents;
                        // SR: CRUD Check
                        if ( Schema.sObjectType.Document.isAccessible()) {
                            // SR: FLS Check
                            if ( Schema.sObjectType.Document.fields.Body.isAccessible() && Schema.sObjectType.Document.fields.ContentType.isAccessible() && Schema.sObjectType.Document.fields.LastModifiedDate.isAccessible()) {
                                documents = [SELECT Id, Body, ContentType, LastModifiedDate FROM Document WHERE Id =: documentId  LIMIT 1];
                            } else {
                                throw new FieloPLT.FieloException(String.format(Label.security_error_field_not_readable, new List<String>{'Document', 'Body, ContentType, LastModifiedDate'}));
                            }
                        } else {
                            throw new FieloPLT.FieloException(String.format(Label.security_error_object_not_readable, new List<String>{'Document'}));
                        }

                        if ( documents.size() != 0 ) {
                            currentDocument = documents.get(0);
                        } else { // En caso que hayan borrado el documento
                            documentId = null;
                        }

                        List<SObject> whereIsUsed;

                        // SR: CRUD Check
                        if ( objectDescribe.isAccessible() ) {
                            // SR: FLS Check
                            if ( fieldsMap.get(fieldName).getDescribe().isAccessible() ) {
                                whereIsUsed = Database.query('SELECT Id FROM ' + objectName + ' WHERE ' + fieldName + ' = :documentId  AND Id != :recordId ');
                            } else {
                                throw new FieloPLT.FieloException(String.format(Label.security_error_field_not_readable, new List<String>{objectName, fieldName}));
                            }
                        } else {
                            throw new FieloPLT.FieloException(String.format(Label.security_error_object_not_readable, new List<String>{objectName}));
                        }

                        Boolean isUsed = !whereIsUsed.isEmpty();

                        if(isUsed && currentDocument != null ) {
                            currentDocument = currentDocument.clone(false, false, false, false);
                        }
                    }
                }

                // Si uso Croppper reemplazo el Body
                if(!String.isBlank(photoBase64)) {
                    Integer firstComma = photoBase64.indexOf(',');
                    photoBase64 = photoBase64.substring(firstComma + 1, photoBase64.length() - 1);
                    currentDocument.put('Body', EncodingUtil.Base64Decode(photoBase64));
                }

                if(currentDocument.Id != null){
                    // SR: CRUD Check
                    if (currentDocument.getSObjectType().getDescribe().isUpdateable()) {
                        // SR: FLS Check
                        for ( String f : currentDocument.getPopulatedFieldsAsMap().keySet() ) {
                            if ( f != 'Id' && !documentFieldsMap.get(f).getDescribe().isUpdateable() ) {
                                throw new FieloPLT.FieloException(String.format(Label.security_error_field_not_updateable, new List<String>{'Document', f}));
                            }
                        }
                        update currentDocument;
                    } else {
                        throw new FieloPLT.FieloException(String.format(Label.security_error_object_not_updateable, new List<String>{currentDocument.getSObjectType().getDescribe().getName()}));
                    }
                } else {
                    currentDocument.put('Name', (String)record.get('Name') );
                    // TODO: Ver Description, Keywords, Unique Name (DeveloperName), File Extension (Type + ContentType)
                    // TODO: Ver width y height
                    currentDocument.put('FolderId', folderId);
                    currentDocument.put('IsPublic', true);

                     // SR: FLS Check
                    for ( String f : currentDocument.getPopulatedFieldsAsMap().keySet() ) {
                        if ( f != 'Id' && !documentFieldsMap.get(f).getDescribe().isUpdateable() ) {
                            throw new FieloPLT.FieloException(String.format(Label.security_error_field_not_updateable, new List<String>{'Document', f}));
                        }
                        if ( f != 'Id' && !documentFieldsMap.get(f).getDescribe().isCreateable() ) {
                            throw new FieloPLT.FieloException(String.format(Label.security_error_field_not_insertable, new List<String>{'Document', f}));
                        }
                    }

                    if ( Schema.sObjectType.Document.isUpdateable() && Schema.sObjectType.Document.isCreateable() ) {
                        upsert currentDocument;
                    } else {
                        throw new FieloPLT.FieloException(String.format(Label.security_error_object_not_insertable, new List<String>{'Document'}));
                    }

                    record.put( fieldName, currentDocument.Id );
                }

                documentId = currentDocument.Id;

                result.redirectURL = createURL(currentDocument, instance);
                record.put( externalURLField, result.redirectURL);

                // SR: FLS Check
                for ( String f : record.getPopulatedFieldsAsMap().keySet() ) {
                    if ( f != 'Id' && !recordFieldsDescribe.get(f).getDescribe().isUpdateable() ) {
                        throw new FieloPLT.FieloException(String.format(Label.security_error_field_not_updateable, new List<String>{'Document', f}));
                    }
                    if ( f != 'Id' && !recordFieldsDescribe.get(f).getDescribe().isCreateable() ) {
                        throw new FieloPLT.FieloException(String.format(Label.security_error_field_not_insertable, new List<String>{'Document', f}));
                    }
                }
                if ( recordObjectDescribe.isUpdateable() && recordObjectDescribe.isCreateable() ) {
                    upsert record;
                } else {
                    throw new FieloPLT.FieloException(String.format(Label.security_error_object_not_updateable, new List<String>{'Document'}));
                }
            }

            result.addMessage(new RemoteActionResult.RemoteActionMessage( ApexPages.Severity.Confirm, label.DataSavedSuccessfully) );
            result.recordsId.add(documentId);
        }catch(DmlException e){
            // Agrega las Validation Rules asociadas al Campo
            Database.rollback(sp);
            if(ApexPages.hasMessages()){
                result.redirectURL = '';
                for(ApexPages.Message m : ApexPages.getMessages()){
                    result.addMessage(new RemoteActionResult.RemoteActionMessage(m, record.getSobjectType().getDescribe().getName() ));
                }
            } else {
            result.addMessage(new RemoteActionResult.RemoteActionMessage(e));
            }
        }catch(Exception e){
            if(sp != null){
                Database.rollback(sp);
            }
            result.addMessage(new RemoteActionResult.RemoteActionMessage(e));
        }
        return result;
    }


    @RemoteAction
    global static RemoteActionResult remove( sObject record, String fieldName, String externalURLField){
        Savepoint sp;
        RemoteActionResult result = new RemoteActionResult();
        try{
            DescribeSObjectResult recordObjectDescribe = record.getSObjectType().getDescribe();
            Map<String, Schema.SObjectField> recordFieldsDescribe = recordObjectDescribe.fields.getMap();
            sp = Database.setSavepoint();
            record.put(fieldName ,null);
            record.put(externalURLField ,null);

            // SR: FLS Check
            for ( String f : record.getPopulatedFieldsAsMap().keySet() ) {
                if ( f != 'Id' && !recordFieldsDescribe.get(f).getDescribe().isUpdateable() ) {
                    throw new FieloPLT.FieloException(String.format(Label.security_error_field_not_updateable, new List<String>{recordObjectDescribe.getName(), f}));
                }
                if ( f != 'Id' && !recordFieldsDescribe.get(f).getDescribe().isCreateable() ) {
                    throw new FieloPLT.FieloException(String.format(Label.security_error_field_not_insertable, new List<String>{recordObjectDescribe.getName(), f}));
                }
            }

            // SR: CRUD Check
            if ( !recordObjectDescribe.isUpdateable() ) {
                throw new FieloPLT.FieloException(String.format(Label.security_error_object_not_updateable, new List<String>{recordObjectDescribe.getName()}));
            } else if ( !recordObjectDescribe.isCreateable() ) {
                throw new FieloPLT.FieloException(String.format(Label.security_error_object_not_insertable, new List<String>{recordObjectDescribe.getName()}));
            } else {
                upsert record;
            }
            //TODO REVISAR SI BORRA DOCUMENTOS HUERFANOS
            result.addMessage(new RemoteActionResult.RemoteActionMessage( ApexPages.Severity.Confirm, label.DataRemovedSuccessfully) );

        } catch( DmlException e ){
            // Agrega las Validation Rules asociadas al Campo
            Database.rollback(sp);
            if(ApexPages.hasMessages()){
                result.redirectURL = '';
                for(ApexPages.Message m : ApexPages.getMessages()){
                    result.addMessage(new RemoteActionResult.RemoteActionMessage(m, record.getSobjectType().getDescribe().getName() ));
                }
            } else {
            result.addMessage(new RemoteActionResult.RemoteActionMessage(e));
            }
        }catch(Exception e){
            if(sp != null){
                Database.rollback(sp);
            }
            result.addMessage(new RemoteActionResult.RemoteActionMessage(e));
        }
        return result;
    }

    public static String createURL(Document imageRecord, String instance){
        String url;

        if(instance != null && instance != ''){
            url = 'https://c.' + instance + '.content.force.com/servlet/servlet.ImageServer?id=' + (String)imageRecord.Id + '&oid=' + UserInfo.getOrganizationId();
        }else{
            url = '/servlet/servlet.ImageServer?id=' + (String)imageRecord.Id + '&oid=' + UserInfo.getOrganizationId();
        }
        if(imageRecord.get('LastModifiedDate') != null) {
            url += '&LastModifiedDate=' + String.valueOf(imageRecord.get('LastModifiedDate')).deleteWhitespace();
        }
        return url;
    }

}
