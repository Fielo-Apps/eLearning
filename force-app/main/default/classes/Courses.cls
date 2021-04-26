public  class Courses extends SObjectDomain{

    public static Boolean validateAdminFields = true;
    public static Boolean isDelete = false;

    public Courses(List<Course__c> records) {
        super(records);
    }

    public class Constructor implements SObjectDomain.IConstructable {

        public SObjectDomain construct(List<Course__c> sObjectList) {
            //If has Admin Permission allow "validateAdminFields"
            if(FieloPLT__AdminPermission__c.getInstance(UserInfo.getUserId()) != null && FieloPLT__AdminPermission__c.getInstance(UserInfo.getUserId()).FieloPLT__To__c >= system.now()){
                validateAdminFields = false;
            }
            return new Courses(sObjectList);
        }
    }

    public override void onApplyDefaults() {
        for(Course__c course : (List<Course__c>)records){
            course.ActiveModules__c = 0;
            course.Status__c = 'Draft';
            course.KeyDependencies__c = '';
            if(String.isBlank(course.SubscriptionMode__c)){
                course.SubscriptionMode__c = 'Manual';
            }
        }
    }

    public override void onValidate() {
        if(validateAdminFields){
            for(Course__c course : (List<Course__c>)records){
                if (course.StartDate__c != null) {
                    if (course.StartDate__c < System.today()) {
                        course.addError(Label.CourseFutureDatesNotAllowed);
                    }
                }
                if (course.EndDate__c != null) {
                    if (course.EndDate__c < System.today()) {
                        course.addError(Label.CourseFutureDatesNotAllowed);
                    }
                }
            }
        }
    }

    public override void onValidate(Map<Id,SObject> existingRecords) {
        if(validateAdminFields){
            //before update
            for(Course__c course : (List<Course__c>)records){
                Course__c oldCourse = (Course__c)existingRecords.get(course.Id);
                if(course.ActiveModules__c != oldCourse.ActiveModules__c) {
                    course.ActiveModules__c = oldCourse.ActiveModules__c;
                }

                if(course.Status__c != oldCourse.Status__c) {
                    course.Status__c = oldCourse.Status__c;
                }

               //get PublicSettings field that check if Edit Courses is authorized
               FieloPLT__PublicSettings__c courseSettings = FieloPLT__PublicSettings__c.getInstance();
               Boolean editCourseSettings = courseSettings.EnableEditingWhileActive__c;
               //If the field is true, there is no check
               if(editCourseSettings == false  ){
                    if((oldCourse.Status__c == 'Active' && course.Status__c == 'Active') ||
                        (oldCourse.Status__c == 'Scheduled' && course.Status__c == 'Scheduled') ||
                        (oldCourse.Status__c == 'Completed' && course.Status__c == 'Completed')) {
                        addError(course, Label.ActiveCourseCannotBeEdited);
                    }
                }else if((course.FieloELR__ActiveModules__c != oldCourse.FieloELR__ActiveModules__c) ||
                    (course.FieloELR__HasDependencies__c != oldCourse.FieloELR__HasDependencies__c) ||
                    (course.FieloELR__KeyDependencies__c != oldCourse.FieloELR__KeyDependencies__c)){
                    addError(course,'This field can\'t be edited');
                }

                // Date validation
                if (course.StartDate__c != null) {
                    if (course.StartDate__c < System.today()) {
                        addError(course, Label.CourseFutureDatesNotAllowed);
                    }
                }
                if (course.EndDate__c != null) {
                    if (course.EndDate__c < System.today()) {
                        addError(course, Label.CourseFutureDatesNotAllowed);
                    }
                }
            }
        }
    }

    public override void onBeforeDelete() {
        isDelete = true;

        // Check Courses before delete
        checkCoursesWithStatus((List<Course__c>)records);

        SObjectUnitOfWork uow = new SObjectUnitOfWork(new List<Schema.SObjectType>{CourseDependency__c.SObjectType, Module__c.SObjectType}, true);

        Map<Id,Course__c> coursesMap = new Map<Id, Course__c>((List<Course__c>)records);
        // When the course is deleted, must delete course dependencies.
        deleteCourseDependencies(coursesMap, uow);
        // When the course is deleted, must delete related modules
        deleteCourseModules(coursesMap, uow);

        // SR: It was checking a wrong object (Course__c)
        if(Schema.sObjectType.CourseDependency__c.isDeletable() && Schema.sObjectType.Module__c.isDeletable()){
            uow.commitWork();
        }else{
            throw new FieloPLT.FieloException(Label.CannotInsertUpdateRecords);
        }

        Map<Id,SObject> deletedModules = uow.m_deletedMapByType.get('FieloELR__Module__c');
        for (Database.DeleteResult dr : uow.getResults(Module__c.SObjectType).deleteResults) {
            if (!dr.isSuccess()) {
                // Operation failed, so get all errors
                for(Database.Error err : dr.getErrors()) {
                    coursesMap.get(((Module__c)deletedModules.get(dr.getId())).Course__c).addError(err.getMessage());
                }
            }
        }
    }

    public override void onAfterUpdate(Map<Id,SObject> existingRecords){
        List<Course__c> activatedCourses = new List<Course__c>();
        List<Course__c> inactivatedCourses = new List<Course__c>();

        Course__c oldCourse;

        for(Course__c course : (List<Course__c>)records) {
            oldCourse = (Course__c)(existingRecords.get(course.Id));

            // Select only courses that are being activated
            if(!(oldCourse.Status__c=='Active') && (course.Status__c=='Active' || course.Status__c=='Scheduled') ) {
                activatedCourses.add(course);
            }
            // Select only courses that are being inactivated
            if(oldCourse.Status__c=='Active' && !(course.Status__c=='Active')) {
                inactivatedCourses.add(course);
            }
        }

        if (!activatedCourses.isEmpty()) {
            validateAdminFields = false;
            addCourseDependency(activatedCourses);
        }

        if (!inactivatedCourses.isEmpty()) {
            validateAdminFields = false;
            removeCourseDependency(inactivatedCourses);
        }
    }

    private void removeCourseDependency(List<Course__c> inactivatedCourses) {
        Set<Id> inactiveCoursesIds = new Map<Id,Course__c>(inactivatedCourses).keySet();
        List<Course__c> courses;
        if (Schema.sObjectType.Course__c.isAccessible()) {
            if (Schema.sObjectType.Course__c.fields.KeyDependencies__c.isAccessible()) {
                courses = new CoursesSelector(new Set<String>{'Id','KeyDependencies__c'}).selectByPredecessor(inactiveCoursesIds);
            } else {
                throw new FieloPLT.FieloException(String.format(Label.security_error_field_not_readable, new List<String>{'Course__c','KeyDependencies__c'}));
            }
        } else {
            throw new FieloPLT.FieloException(String.format(Label.security_error_object_not_readable, new List<String>{'Course__c'}));
        }


        Set<String> keySetDependencies;
        List<String> keyDependencies;
        Map<Id,Course__c> coursesMap = new Map<Id,Course__c>();
        for(Course__c course: courses) {
            if (course.KeyDependencies__c != null) {
                if (!coursesMap.containsKey(course.Id)) {
                    coursesMap.put(course.Id, course);
                }
                keySetDependencies = new Set<String>(course.KeyDependencies__c.split(','));

                for (String key: keySetDependencies) {
                    if (inactiveCoursesIds.contains(key)) {
                        keySetDependencies.remove(key);
                    }
                }
                keyDependencies = new List<String>(keySetDependencies);
                keyDependencies.sort();
                coursesMap.get(course.Id).KeyDependencies__c = String.join(keyDependencies,',');
                coursesMap.get(course.Id).HasDependencies__c = coursesMap.get(course.Id).KeyDependencies__c != '' &&
                    coursesMap.get(course.Id).KeyDependencies__c != null;
            }

        }

        if(!coursesMap.values().isEmpty()) {
            SObjectUnitOfWork uow = new SObjectUnitOfWork(new List<Schema.SObjectType>{Course__c.SObjectType});
            uow.registerDirty(coursesMap.values());

            // SR: Added isCreateable
            if(Schema.sObjectType.Course__c.isUpdateable() && Schema.sObjectType.Course__c.isCreateable()) {
                if (Schema.sObjectType.Course__c.fields.KeyDependencies__c.isUpdateable() && Schema.sObjectType.Course__c.fields.KeyDependencies__c.isCreateable() && Schema.sObjectType.Course__c.fields.HasDependencies__c.isUpdateable() && Schema.sObjectType.Course__c.fields.HasDependencies__c.isCreateable()) {
                    uow.commitWork();
                } else {
                    throw new FieloPLT.FieloException(String.format(Label.security_error_field_not_readable, new List<String>{'Course__c','KeyDependencies__c,HasDependencies__c'}));
                }
            } else {
                throw new FieloPLT.FieloException(Label.CannotInsertUpdateRecords);
            }
        }
    }

    private void addCourseDependency(List<Course__c> activatedCourses) {
        Set<Id> activatedCoursesIds = new Map<Id,Course__c>(activatedCourses).keySet();
        List<CourseDependency__c> cds;
        if (Schema.sObjectType.CourseDependency__c.isAccessible() && Schema.sObjectType.Course__c.isAccessible()) {
            if (Schema.sObjectType.CourseDependency__c.fields.Predecessor__c.isAccessible() && Schema.sObjectType.CourseDependency__c.fields.Course__c.isAccessible() && Schema.sObjectType.Course__c.fields.KeyDependencies__c.isAccessible()) {
                cds = new CourseDependenciesSelector(new Set<String>{'Predecessor__c','Course__c','Course__r.KeyDependencies__c'}).selectByPredecessor(activatedCoursesIds);
            } else {
                throw new FieloPLT.FieloException(String.format(Label.security_error_field_not_readable, new List<String>{'CourseDependency__c','Predecessor__c,Course__c,Course__r.KeyDependencies__c'}));
            }
        } else {
            throw new FieloPLT.FieloException(String.format(Label.security_error_object_not_readable, new List<String>{'Course__c,CourseDependency__c'}));
        }

        Set<String> keySetDependencies;
        List<String> keyDependencies;
        Map<Id,Course__c> coursesMap = new Map<Id,Course__c>();
        for(CourseDependency__c cd: cds) {
            if (cd.Course__r.KeyDependencies__c == null) {
                cd.Course__r.KeyDependencies__c = String.valueOf(cd.Predecessor__c);
                cd.Course__r.HasDependencies__c = true;
                coursesMap.put(cd.Course__c, cd.Course__r);
            } else {
                keySetDependencies = new Set<String>(cd.Course__r.KeyDependencies__c.split(','));

                if (!keySetDependencies.contains(String.valueOf(cd.Predecessor__c))) {
                    if (!coursesMap.containsKey(cd.Course__c)) {
                        coursesMap.put(cd.Course__c, cd.Course__r);
                    }

                    keySetDependencies.add(String.valueOf(cd.Predecessor__c));

                    keyDependencies = new List<String>(keySetDependencies);
                    keyDependencies.sort();
                    coursesMap.get(cd.Course__c).KeyDependencies__c = String.join(keyDependencies,',');
                    coursesMap.get(cd.Course__c).HasDependencies__c = true;
                }
            }
        }

        if (!coursesMap.values().isEmpty()) {
            SObjectUnitOfWork uow = new SObjectUnitOfWork(new List<Schema.SObjectType>{Course__c.SObjectType});
            uow.registerDirty(coursesMap.values());

            // SR: Added isCreateable
            if(Schema.sObjectType.Course__c.isUpdateable() && Schema.sObjectType.Course__c.isCreateable()) {
                if (Schema.sObjectType.Course__c.fields.KeyDependencies__c.isUpdateable() && Schema.sObjectType.Course__c.fields.KeyDependencies__c.isCreateable() && Schema.sObjectType.Course__c.fields.HasDependencies__c.isUpdateable() && Schema.sObjectType.Course__c.fields.HasDependencies__c.isCreateable()) {
                    uow.commitWork();
                } else {
                    throw new FieloPLT.FieloException(String.format(Label.security_error_field_not_readable, new List<String>{'Course__c','KeyDependencies__c,HasDependencies__c'}));
                }
            } else {
                throw new FieloPLT.FieloException(Label.CannotInsertUpdateRecords);
            }
        }
    }

    private void deleteCourseModules(Map<Id,Course__c> coursesMap, SObjectUnitOfWork uow){
        Set<Id> courseIds = coursesMap.KeySet();
        courseIds.removeAll(new List<Id>(RecordErrors));

        // Looks up for courses IDs contained in modules
        List<Module__c> modulesToDelete;
        if(Schema.sObjectType.Module__c.isAccessible()) {
            if (Schema.sObjectType.Module__c.fields.Course__c.isAccessible()) {
                modulesToDelete = new ModulesSelector(new Set<String>{'Id','Course__c'}).selectByIdHavingCourses(courseIds);
            } else {
                throw new FieloPLT.FieloException(String.format(Label.security_error_field_not_readable, new List<String>{'Module__c','Course__c'}));
            }
        } else {
            throw new FieloPLT.FieloException(String.format(Label.security_error_object_not_readable, new List<String>{'Module__c'}));
        }

        // Delete related modules
        if (Schema.sObjectType.Module__c.isDeletable()) {
            uow.registerDeleted(modulesToDelete);
        } else {
            throw new FieloPLT.FieloException(String.format(Label.security_error_object_not_deletable, new List<String>{'Course__c'}));
        }
    }

    private void deleteCourseDependencies(Map<Id,Course__c> coursesMap, SObjectUnitOfWork uow){
        Set<Id> courseIds = coursesMap.KeySet();
        courseIds.removeAll(new List<Id>(RecordErrors));

        // Looks up for courses IDs contained in course dependencies and predecessors
        List<CourseDependency__c> dependenciesToDelete;
        if(Schema.sObjectType.CourseDependency__c.isAccessible()) {
            if( Schema.sObjectType.CourseDependency__c.fields.Course__c.isAccessible() && Schema.sObjectType.CourseDependency__c.fields.Predecessor__c.isAccessible() ) {
                dependenciesToDelete = new CourseDependenciesSelector(new Set<String>{'FieloELR__Course__c','FieloELR__Predecessor__c'}).selectDependenciesAndPredecessors(coursesMap.KeySet());
            } else {
                throw new FieloPLT.FieloException(String.format(Label.security_error_field_not_readable, new List<String>{'CourseDependency__c','Course__c,Predecessor__c'}));
            }
        } else {
            throw new FieloPLT.FieloException(String.format(Label.security_error_object_not_readable, new List<String>{'CourseDependency__c'}));
        }


        // Delete related dependencies
        if (Schema.sObjectType.Module__c.isDeletable()) {
            uow.registerDeleted(dependenciesToDelete);
        } else {
            throw new FieloPLT.FieloException(String.format(Label.security_error_object_not_deletable, new List<String>{'CourseDependency__c'}));
        }
    }

    // If the course is active, has at least 1 related course status,
    // and any of the following fields was modified the Course cannot be edited or deleted.
    private void checkCoursesWithStatus(List<Course__c> courses){
        // Map with NEW records
        Map<Id,Course__c> coursesMap = new Map<Id, Course__c>(courses);
        // Course has at least 1 related Course Status
        List<Course__c> coursesWithStatus;
        if(Schema.sObjectType.Course__c.isAccessible()) {
            if (Schema.sObjectType.Course__c.fields.Status__c.isAccessible() && Schema.sObjectType.Course__c.fields.SubscriptionMode__c.isAccessible() && Schema.sObjectType.Course__c.fields.Segment__c.isAccessible() && Schema.sObjectType.Course__c.fields.StartDate__c.isAccessible() && Schema.sObjectType.Course__c.fields.EndDate__c.isAccessible()) {
                coursesWithStatus = new CoursesSelector(new Set<String>{'Id','FieloELR__Status__c','FieloELR__SubscriptionMode__c','FieloELR__Segment__c','FieloELR__StartDate__c','FieloELR__EndDate__c'}).selectByIdHavingCourseStatus(coursesMap.KeySet());
            } else {
                throw new FieloPLT.FieloException(String.format(Label.security_error_field_not_readable, new List<String>{'Course__c','Status__c,SubscriptionMode__c,Segment__c,StartDate__c,EndDate__c'}));
            }
        } else {
            throw new FieloPLT.FieloException(String.format(Label.security_error_object_not_readable, new List<String>{'Course__c'}));
        }

        for (Course__c course : coursesWithStatus){
            if(!course.CoursesStatus__r.isEmpty()){
                coursesMap.get(course.Id).addError(Label.ActiveCourseCannotBeEdited);
            }
        }
    }
}