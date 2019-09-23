public class CourseDependencies extends SObjectDomain{
    
    public CourseDependencies(List<CourseDependency__c> records) {
        super(records);
    }

    public class Constructor implements SObjectDomain.IConstructable {
        public SObjectDomain construct(List<CourseDependency__c> sObjectList) {
            return new CourseDependencies(sObjectList);
        }
    }

    public override void onApplyDefaults(){
        for(CourseDependency__c courseDependency : (List<CourseDependency__c>)records){
            if (courseDependency.Course__c!=null && courseDependency.Predecessor__c!=null) {
                courseDependency.ExternalKey__c = ((string)courseDependency.Course__c) + ((string)courseDependency.Predecessor__c);
            }
        }
    }

    public override void onValidate(Map<Id,SObject> existingRecords) {
        for (CourseDependency__c courseDependency: (List<CourseDependency__c>) records) {
            if (courseDependency.Predecessor__c == null) {
                courseDependency.addError(Label.PredecessorRequired);
            }
            if (courseDependency.Course__c == null) {
                courseDependency.addError(Label.CourseRequiredField);
            }
        }
    }

    public override void onValidate() {
        for (CourseDependency__c courseDependency: (List<CourseDependency__c>) records) {
            if (courseDependency.Predecessor__c == null) {
                courseDependency.addError(Label.PredecessorRequired);
            }
            if (courseDependency.Course__c == null) {
                courseDependency.addError(Label.CourseRequiredField);
            }
        }
    }

    public override void onAfterInsert() {
        SObjectUnitOfWork uow = new SObjectUnitOfWork(new List<Schema.SObjectType>{Course__c.SObjectType});
        
        if(Schema.sObjectType.Course__c.isCreateable() && Schema.sObjectType.Course__c.isUpdateable()){
            updateCourses(records, uow);
            Courses.validateAdminFields = false;
            uow.commitWork();
        }else{
            throw new FieloPLT.FieloException(Label.CannotInsertUpdateRecords);
        }
    }

    public override void onAfterDelete() {
        SObjectUnitOfWork uow = new SObjectUnitOfWork(new List<Schema.SObjectType>{Course__c.SObjectType});

        if(Schema.sObjectType.Course__c.isCreateable() && Schema.sObjectType.Course__c.isUpdateable()){
            updateCourses(records, uow);
            Courses.validateAdminFields = false;
            uow.commitWork();
        } else {
            throw new FieloPLT.FieloException(Label.CannotInsertUpdateRecords);
        }
    }  

    private void updateCourses(List<CourseDependency__c> courseDependencies, SObjectUnitOfWork uow) {

        Set<Id> courseIds = new Set<Id>();
        for(CourseDependency__c coursedependency : courseDependencies) {
            courseIds.add(coursedependency.Course__c);
            courseIds.add(coursedependency.Predecessor__c);
        }
        Map<Id, Course__c> coursesMap = 
                    new Map<Id, Course__c>(new CoursesSelector(new Set<String> {'Id', 'HasDependencies__c', 'KeyDependencies__c','Status__c'}).selectById(courseIds));
        Course__c course;
        String predecessor;
        List<String> Keys;

        for(CourseDependency__c coursedependency : courseDependencies) {
            course = coursesMap.get(coursedependency.Course__c);
            predecessor = String.valueOf(coursedependency.Predecessor__c);
            if(Trigger.IsInsert) {
                // Add key
                if (coursesMap.get(coursedependency.Predecessor__c).Status__c == 'Active') {
                    if(String.IsBlank(course.KeyDependencies__c)) {
                        course.KeyDependencies__c = predecessor;
                    } else {
                        Keys = course.KeyDependencies__c.split(',');
                        Keys.add(predecessor);
                        Keys.sort();            
                        course.KeyDependencies__c = String.join(Keys, ',');
                    }   
                    // If a course dependency is inserted and course has no dependencies yet, the attribute must be updated
                    if(!(course.HasDependencies__c)) {
                        course.HasDependencies__c = true;
                    }
                }
            } else if(Trigger.IsDelete) {
                if(!String.isBlank(course.KeyDependencies__c)){
                    // Remove key
                    course.KeyDependencies__c = course.KeyDependencies__c.replace(predecessor + ',', '').replace(',' + predecessor, '').replace(predecessor, '');
                }
                // If a course dependency is deleted and course has no more dependencies, the attribute must be updated
                if(String.isBlank(course.KeyDependencies__c) && course.HasDependencies__c) {
                    course.HasDependencies__c = false;
                }                
            }
            uow.registerDirty(course); 
        }
    }  
}