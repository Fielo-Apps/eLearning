public with sharing class JSONExportController {

    public String body {get; set;}
    public String contentType {get; set;}

    /**
    * @brief constructor that process the records and export it in a xml file
    */
    public JSONExportController(){
        String type = String.escapeSingleQuotes(ApexPages.currentPage().getParameters().get('type'));

        contentType = 'text/json#export.json';

        // Exporta una Page
        if ( type == 'courses'  ) {
        	Id courseId = ApexPages.currentPage().getParameters().get('courseId');
        	List<Id> courseIds = courseId != null ? new List<Id>{ String.escapeSingleQuotes(courseId) } : null;
            body = ExportService.exportCourses(courseIds);
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, String.format(Label.RequiredArgument, new String[]{'type'} ) ));
        }

    }
}