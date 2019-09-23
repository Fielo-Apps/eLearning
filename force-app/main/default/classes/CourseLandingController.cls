/**
* @description Class to Control the Incentives Landing Page.
*/
public with sharing class CourseLandingController extends PageSettingsSetController {

    public String currentView {get;set;}
    public FieloPLT__PageSettings__c newCourse {get;set;}
    public FieloPLT__PageSettings__c landingCourse {get;set;}
    public static String secondaryParameters {get;set;}
    public static String saveController {get;set;}
    private PageReference retURL {get;set;}

    public FieloPLT__Program__c currentProgram { get {
        if (currentProgram == null && ProgramService.hasPrograms()) {
            currentProgram = ProgramService.getActiveProgram();
        }
        return currentProgram;
    }set;}

    public CourseLandingController() {
        
        //Verify if a program was already created. If not, redirect to ProgramLanding page
        if(currentProgram != null)
        {      
            String standardTools  = '';
            String standardButtons = '';

            PageReference exportPage = Page.JSONExport;
            exportPage.getParameters().put( 'retURL', System.currentPageReference().getUrl() );
            exportPage.getParameters().put( 'type', 'courses' );
            PageReference importPage = Page.JSONImport;
            importPage.getParameters().put( 'retURL', System.currentPageReference().getUrl() );
            importPage.getParameters().put( 'type', 'courses' );

            standardTools = '{"Label": "Export", "Type": "Link", "Action": "' + exportPage.getUrl() + '" }';
            standardTools += ',{"Label": "Import", "Type": "Link", "Action": "' + importPage.getUrl() + '" }';

            // initPageSettings( 'FieloELR__Course__c', standardButtons, standardTools, 'utility-sprite/svg/symbols.svg#people' );

            initPageSettings( 'FieloELR__Course__c', standardButtons, standardTools, 'utility-sprite/svg/symbols.svg#people', null);

            newCourse = newSettings.clone();
            landingCourse = landingSettings;

            newCourse.FieloPLT__Sections__c = getSectionsWithSegmentWhereCondition(newCourse.FieloPLT__Sections__c);

            if ( Apexpages.currentPage().getParameters().containsKey('view') ) {
                currentView = Apexpages.currentPage().getParameters().get('view');
            } else {
                currentView = 'Draft';
            }
        }
    }
    
    //Verify if a program was already created. If not, redirect to ProgramLanding page
    public PageReference verifyProgram(){
        PageReference retURL;
        if(!ProgramService.hasPrograms()){
            retURL = Page.FieloPLT__ProgramLanding;
            retURL.setRedirect(true);
        }
      return retURL;
    }

    public class Section {
        public String Name{get;set;}
        public List<List<FormField>> Rows{get;set;}
        public String CssClass{get;set;}
    }

    public class FormField {
        public String Type{get;set;}
        public String MetaField{get;set;}
        public String Name{get;set;}
        public String onchange{get;set;}
        public String Label{get;set;}
        public String Value{get;set;}
        public String WhereCondition{get;set;}
        public Boolean Required{get;set;}

        public String getRequiredValue () {
            if ( Required != null ) {
                return Required ? 'true' : 'false';
            }
            return '';
        }
    }

    public static String getSectionsWithSegmentWhereCondition(String sectionsString){
        
        //saveController = 'CourseLandingController.createCourseWithoutSegments';
        saveController = 'CourseLandingController.createCourse';
        secondaryParameters = 'modelId,FieloELR__Segment__c';


        List<Section> sections = (List<Section>) JSON.deserialize( sectionsString, List<CourseLandingController.Section>.class );
        for ( Section s :sections ) {
          for ( List<FormField> r :s.rows ) {
            for ( FormField f :r ) {
              if(f.Name != null) {
                if(f.Name == 'FieloELR__Segment__c') {
                    f.WhereCondition = ' FieloPLT__Program__c IN ( //, /' + ProgramService.getActiveProgram().Id + '/ ) AND RecordType.Name <> /Metasegment/ ';
                    //secondaryParameters = 'FieloELR__Segment__c';
                    //saveController = 'CourseLandingController.createCourseWithSegments';
                }
              }
            }
          }
        }
        return JSON.serialize(sections);
    }

    public static List<SelectOption> getStatusViews(){
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('Draft', 'Draft'));
        options.add(new SelectOption('Active', 'Active'));
        options.add(new SelectOption('Inactive', 'Inactive'));
        options.add(new SelectOption('Scheduled', 'Scheduled'));
        options.add(new SelectOption('Completed', 'Completed'));
        return options;
    }

    private static Set<String> getViewStatus(String currentView) {
        return new Set<String> {currentView};
    }

    @RemoteAction
    public static List<FieloELR__Course__c> getCourses( String objectName, String fields, Integer offset, String orderBy, String filter, Integer recordsPerPage, String whereClause ) {
        Set<String> fieldset = new Set<String> { 'Name', 'SubscriptionMode__c', 'Status__c', 'Program__r.Name' };
        Map<String,Object> jsonObject = (Map<String, Object>) JSON.deserializeUntyped( filter);
        Id programId = (String)jsonObject.get('Program__c');
        String currentView =  (String)jsonObject.get('viewName');
        if ( orderBy == null ) {
            orderBy = 'LastModifiedDate DESC';
        }
        
        List<FieloELR__Course__c> records = new List<FieloELR__Course__c>();

        // SR: CRUD Check
        if ( Schema.sObjectType.Course__c.isAccessible() && Schema.sObjectType.FieloPLT__Program__c.isAccessible()) {
            // SR: FLS Check
            if ( Schema.sObjectType.Course__c.fields.Name.isAccessible() && Schema.sObjectType.Course__c.fields.SubscriptionMode__c.isAccessible() && Schema.sObjectType.Course__c.fields.Status__c.isAccessible() && Schema.sObjectType.Course__c.fields.Program__c.isAccessible() && Schema.sObjectType.FieloPLT__Program__c.fields.Name.isAccessible() && Schema.sObjectType.Course__c.fields.LastModifiedDate.isAccessible()) {
                records = CourseService.getCourses( fieldset, getViewStatus(currentView), programId, recordsPerPage,  offset, orderBy);
            } else {
                throw new FieloPLT.FieloException(String.format(Label.security_error_field_not_readable, new List<String>{'Course__c,FieloPLT__Program__c', 'Course__c.Name, Course__c.SubscriptionMode__c, Course__c.Status__c, Course__c.Program__c, Course__c.LastModifiedDate, FieloPLT__Program__c.Name'}));
            }
        } else {
            throw new FieloPLT.FieloException(String.format(Label.security_error_object_not_readable, new List<String>{'Course__c,FieloPLT__Program__c'}));
        }
        
        return records != null ? records : new List<FieloELR__Course__c>();
    }

    /*
        Create Courses Method
    */
    @RemoteAction
    public static RemoteActionResult createCourse(sObject objectRecord, List<String> nullFields, String modelId, List<String> segments) {
        Savepoint sp;
        RemoteActionResult result = new RemoteActionResult();
		Map<String,Schema.SObjectField> objectFieldsMap = Schema.sObjectType.Course__c.fields.getMap();

        try{
            Course__c record = (Course__c) objectRecord;
            sp = Database.setSavepoint();
            // nullFields is not used becouse its an insert
            // Si tiene mas de un Segmento pasa por Metasegments

            if (Schema.sObjectType.Course__c.fields.Segment__c.isCreateable() && Schema.sObjectType.Course__c.fields.Segment__c.isUpdateable()) {
                if ( segments.size() == 1 ) {
                    record.segment__c = segments.get(0);
                } else if ( segments.size() > 1 ) {
                    record.segment__c = SegmentService.getMetaSegmentId( segments, record.Program__c ) ;
                } else {
                record.segment__c = null;
                }
            } else {
                throw new FieloPLT.FieloException(String.format(Label.security_error_field_not_insertable, new List<String>{'Course__c', 'Segment__c'}));
            }
            //TODO Change to ELR Create API

            Set<String> courseFieldset = new Set<String>(record.getPopulatedFieldsAsMap().keySet());
            if (nullFields != null && !nullFields.isEmpty()) {
			    courseFieldset.addAll(nullFields);
            }

            // SR: Dynamic FLS Check
            for ( String fieldName : courseFieldset ) {
                if ( fieldName != 'Id' && ( !objectFieldsMap.get(fieldName).getDescribe().isUpdateable() || !objectFieldsMap.get(fieldName).getDescribe().isCreateable()) ) {
                    throw new FieloPLT.FieloException(String.format(Label.security_error_field_not_readable, new List<String>{'Course__c', fieldName}));
                }
            }

            if ( String.isBlank( modelId )  ) {
                // SR: CRUD Check
                if( Schema.sObjectType.Course__c.isUpdateable() && Schema.sObjectType.Course__c.isCreateable() && Schema.sObjectType.Course__c.fields.Segment__c.isCreateable() && Schema.sObjectType.Course__c.fields.Segment__c.isUpdateable()) {
                    insert record;
                }else{
                    throw new FieloPLT.FieloException(String.format(Label.security_error_object_not_insertable, new List<String>{'Course__c'}));
                }
            } else {
                CourseService.createFromModel( record, modelId );
                result.addMessage(new RemoteActionResult.RemoteActionMessage( ApexPages.Severity.Confirm, Label.CourseCreated) );
            }


            //TODO Crear Label DataSavedSuccessfully
            if ( record.Id != null ) {
                result.addMessage(new RemoteActionResult.RemoteActionMessage( ApexPages.Severity.Confirm, Label.CourseCreated) );
                result.redirectURL = '/' + record.Id;
            }
        }catch(DmlException e){
            if(sp != null){
                Database.rollback(sp);
            }
            result.addMessage(new RemoteActionResult.RemoteActionMessage( ApexPages.Severity.ERROR,e.getDmlMessage(0)));
        }catch(Exception e){
            if(sp != null){
                Database.rollback(sp);
            }
            result.addMessage(new RemoteActionResult.RemoteActionMessage(e));
        }

        return result;
    }

    @RemoteAction
    public static List<SObject> getSegments( String programId ) {
        List<SObject> records;
        if ( Schema.sObjectType.FieloPLT__Segment__c.isAccessible() ) {
            if ( Schema.sObjectType.FieloPLT__Segment__c.fields.Name.isAccessible() ) {
                records = new SegmentsSelector(new Set<String>{'Id','Name'}).selectByProgramAndWithoutProgramWithCriteria(programId, new Set<String>{'Id','Name'});
            } else {
                throw new FieloPLT.FieloException(String.format(Label.security_error_field_not_readable, new List<String>{'FieloPLT__Segment__c', 'Name'}));
            }
        } else {
            throw new FieloPLT.FieloException(String.format(Label.security_error_object_not_readable, new List<String>{'FieloPLT__Segment__c'}));
        }
        return records;
    }
}