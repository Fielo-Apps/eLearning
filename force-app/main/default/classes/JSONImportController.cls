public with sharing class JSONImportController {

    public Attachment inputFile {get; set;}
    
    public String type {get; set;}
    private Id programId;

    public JSONImportController(){
        inputFile = new Attachment();
        type = String.escapeSingleQuotes(ApexPages.currentPage().getParameters().get('type'));
    }

    public pageReference importFile() {
        
        //checks whether the file exist
        if(inputFile.body == null){  
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Label.FieloPLT.RewardErrorFileNull));
            inputFile = new Attachment();
            return null;
        }
        
        if(!inputFile.Name.contains('.')){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Label.FieloPLT.RewardErrorFormatFile));
            inputFile = new Attachment();
            return null;
        }

        String fileExt = inputFile.Name.subString(inputFile.Name.lastIndexOf('.'));
        if(!fileExt.equalsIgnoreCase('.json')){ //checks the file format
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Label.FieloPLT.RewardErrorFormatFile));
            inputFile = new Attachment();
            return null;
        }

        if(type == 'Courses'){            
            //try{
                List<ExportService.MultiSegmentRelation> multiSegmentRelations = new List<ExportService.MultiSegmentRelation>();
                SObjectUnitOfWork uow = ExportService.importData(inputFile.body.toString(), multiSegmentRelations);
                ExportService.saveData(uow, multiSegmentRelations);
            /*}catch(DMLException e){
                String errorMsge = '';
                for(Integer i = 0; i < e.getNumDML(); i++){
                    errorMsge += e.getDMLMessage(i) + ' ';  
                }    
                ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, String.format(label.FieloPLT.AuditError, new List<String>{string.valueOf(errorMsge)})));
                return null;
            }catch(Exception e){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, String.format(label.FieloPLT.AuditError, new List<String>{string.valueOf(e.getMessage())})));
                return null;
            }*/
        }
        ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.CONFIRM, Label.FieloPLT.ImportSuccess));            
        
        inputFile = new Attachment();
        return null;
    }
    
}