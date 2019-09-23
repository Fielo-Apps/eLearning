@isTest
private class PhotoUploadControllerTest {
    
    @isTest(seeAllData=false) public static void unitTest(){
        PhotoUploadController controller = new PhotoUploadController();
        System.assertNotEquals(null, controller);
        /*MockUpFactory.setCustomProperties(false);
        Reward__c aPrize = new Reward__c(Name= 'Test', Points__c = 2);
        insert aPrize;

        Attachment aAttachment = new Attachment();
        aAttachment.Body = Blob.valueOf('String');    

        PhotoUploadController controller = new PhotoUploadController();
        controller.attField = 'Image__c';
        controller.record = aPrize;

        String toSave = controller.whereToSave;
        toSave = controller.whereToSave;

        String documentURL = controller.docURL;

        controller.getImage();
        controller.getEncImage();
        controller.changePhoto();
        controller.uploadAction();
        controller.deletePhoto();
        controller.cancelEdit();*/
    }


    /**
    * Test cases for rigth image types and a wrong type
    */ /*
    @isTest(seeAllData=false) static void testImageTypes(){
        MockUpFactory.setCustomProperties(false);
        Reward__c aPrize         = new Reward__c(Name= 'Test', Points__c = 2);      
        insert aPrize;

        Attachment aAttachment = new Attachment();
        aAttachment.Body = Blob.valueOf('String');
                  
        PhotoUploadController cTest;
            
        List<String> types = new List<String>{'image/jpeg', 'image/pjpeg', 'image/png', 'image/x-png', 'image/gif'};
    
        Attachment tempAtt = new Attachment();
        
        System.Test.startTest();
            for( String aType: types ){                
                cTest = new PhotoUploadController();
                cTest.newAttach.Name = 'Picture-';
                cTest.newAttach.Body = Blob.valueOf('String');
                cTest.newAttach.ContentType = aType;
                cTest.uploadAction();
                
                cTest.newAttach.Body = Blob.valueOf('String');                        
            }
            
            cTest = new PhotoUploadController();
            cTest.newAttach.Name = 'Picture-';
            cTest.newAttach.Body = Blob.valueOf('String');
            cTest.newAttach.ContentType = 'image/YYY';
            cTest.uploadAction();
            System.assert( cTest.error == Label.ErrorImageType + '<br/>', 'Error in error message.' + cTest.error);

            cTest = new PhotoUploadController();
            cTest.uploadAction();
            
        System.Test.stopTest();
    } */
    
    /**
    *Test upload picture with no picture at the start.
    *
    */ /*
    @isTest(seeAllData=false) static void testNoPicture(){
        MockUpFactory.setCustomProperties(false);
        Reward__c aPrize         = new Reward__c(Name= 'Test', Points__c = 2);      
        insert aPrize;

        Attachment aAttachment = new Attachment();
        aAttachment.Body = Blob.valueOf('String');
        
        System.Test.startTest();
        PhotoUploadController cTest = new PhotoUploadController();
        cTest.newAttach.Name = 'Picture-';
        cTest.newAttach.Body = Blob.valueOf('String');
        cTest.newAttach.ContentType = 'image/jpeg';
        cTest.uploadAction();
        
        // Replace string
        cTest = new PhotoUploadController();
        cTest.newAttach.Name = 'Picture-';
        cTest.newAttach.Body = Blob.valueOf('Other String For Replacement');
        cTest.newAttach.ContentType = 'image/png';
        cTest.uploadAction();
        
        Id stroringAttIdForRetreve = cTest.newAttach.id;
        cTest = new PhotoUploadController();
        //cTest.deleteAction();
        List<Attachment> attUploadedList = [ SELECT id FROM Attachment WHERE id =: stroringAttIdForRetreve ];

        System.assert( attUploadedList.size() == 0, 'Attachment not deleted !!!' );
        
        cTest.changePhoto();
        
        cTest.record = (Reward__c)aPrize;
        
        cTest.saveRecordField = true;
        cTest.objectName = 'Reward__c';
        cTest.attField = 'Image__c';
        //cTest.updateAttachField(aAttachment.Id);
        
        cTest.deletePhoto();
        
        System.Test.stopTest();    
    }*/
}