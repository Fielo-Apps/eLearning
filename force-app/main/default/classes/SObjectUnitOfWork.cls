/**
 * Copyright (c), FinancialForce.com, inc
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification,
 *   are permitted provided that the following conditions are met:
 *
 * - Redistributions of source code must retain the above copyright notice,
 *      this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright notice,
 *      this list of conditions and the following disclaimer in the documentation
 *      and/or other materials provided with the distribution.
 * - Neither the name of the FinancialForce.com, inc nor the names of its contributors
 *      may be used to endorse or promote products derived from this software without
 *      specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 *  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 *  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL
 *  THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 *  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 *  OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
 *  OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 *  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
**/

/**
 * Provides an implementation of the Enterprise Application Architecture Unit Of Work, as defined by Martin Fowler
 *   http://martinfowler.com/eaaCatalog/unitOfWork.html
 *
 * "When you're pulling data in and out of a database, it's important to keep track of what you've changed; otherwise,
 *  that data won't be written back into the database. Similarly you have to insert new objects you create and
 *  remove any objects you delete."
 *
 * "You can change the database with each change to your object model, but this can lead to lots of very small database calls,
 *  which ends up being very slow. Furthermore it requires you to have a transaction open for the whole interaction, which is
 *  impractical if you have a business transaction that spans multiple requests. The situation is even worse if you need to
 *  keep track of the objects you've read so you can avoid inconsistent reads."
 *
 * "A Unit of Work keeps track of everything you do during a business transaction that can affect the database. When you're done,
 *  it figures out everything that needs to be done to alter the database as a result of your work."
 *
 * In an Apex context this pattern provides the following specific benifits
 *  - Applies bulkfication to DML operations, insert, update and delete
 *  - Manages a business transaction around the work and ensures a rollback occurs (even when exceptions are later handled by the caller)
 *  - Honours dependency rules between records and updates dependent relationships automatically during the commit
 *
 * Please refer to the testMethod's in this class for example usage
 *
 * TODO: Need to complete the 100% coverage by covering parameter exceptions in tests
 * TODO: Need to add some more test methods for more complex use cases and some unexpected (e.g. registerDirty and then registerDeleted)
 *
 **/
public virtual class SObjectUnitOfWork{
    private List<Schema.SObjectType> m_sObjectTypes = new List<Schema.SObjectType>();
    public Map<String, List<SObject>> m_newListByType = new Map<String, List<SObject>>();
    public Map<String, Map<Id, SObject>> m_dirtyMapByType = new Map<String, Map<Id, SObject>>();
    public Map<String, Map<Id, SObject>> m_deletedMapByType = new Map<String, Map<Id, SObject>>();
    private Map<String, Relationships> m_relationships = new Map<String, Relationships>();
    private List<IDoWork> m_workList = new List<IDoWork>();
    private SendEmailWork m_emailWork = new SendEmailWork();
    private List<Approval.ProcessSubmitRequest> approvalRequests = new List<Approval.ProcessSubmitRequest>();
    private List<Approval.ProcessResult> approvalResults;
    private IDML m_dml;
    private Map<String,DatabaseResult> resultsMap = new Map<String,DatabaseResult>();

    public class DatabaseResult{
        public Database.SaveResult[] insertResults;
        public Database.SaveResult[] updateResults;
        public Database.DeleteResult[] deleteResults;

        public DatabaseResult(){
            insertResults = new List<Database.SaveResult>();
            updateResults = new List<Database.SaveResult>();
            deleteResults = new List<Database.DeleteResult>();
        }

        public void addInsertResults(Database.SaveResult[] insertResults){
            if(insertResults != null){
                this.insertResults.addAll(insertResults);
            }
        }

        public void addUpdateResults(Database.SaveResult[] updateResults){
            if(updateResults != null){
                this.updateResults.addAll(updateResults);
            }
        }

        public void addDeleteResults(Database.DeleteResult[] deleteResults){
            if(deleteResults != null){
                this.deleteResults.addAll(deleteResults);
            }
        }
    }

    public DatabaseResult getResults(Schema.SObjectType objType){
        return resultsMap.get(objType.getDescribe().getName());
    }

    /**
     * Interface describes work to be performed during the commitWork method
     **/
    public interface IDoWork{
        void doWork();
    }

    public interface IDML{
        Database.SaveResult[] dmlInsert(List<SObject> objList);
        Database.SaveResult[] dmlUpdate(List<SObject> objList);
        Database.DeleteResult[] dmlDelete(List<SObject> objList);
    }

    public class SimpleDML implements IDML{
        public Database.SaveResult[] dmlInsert(List<SObject> objList){
            insert objList;
            return null;
        }
        public Database.SaveResult[] dmlUpdate(List<SObject> objList){
            update objList;
            return null;
        }
        public Database.DeleteResult[] dmlDelete(List<SObject> objList){
            delete objList;
            return null;
        }
    }

    public class PartialDML implements IDML{
        public Database.SaveResult[] dmlInsert(List<SObject> objList){
            return Database.insert(objList,false);
        }
        public Database.SaveResult[] dmlUpdate(List<SObject> objList){
            return Database.update(objList,false);
        }
        public Database.DeleteResult[] dmlDelete(List<SObject> objList){
            return Database.delete(objList,false);
        }
    }

    /**
     * Constructs a new UnitOfWork to support work against the given object list
     *
     * @param sObjectList A list of objects given in dependency order (least dependent first)
     */
    public SObjectUnitOfWork(List<Schema.SObjectType> sObjectTypes){
        this(sObjectTypes,new SimpleDML());
    }

    public SObjectUnitOfWork(List<Schema.SObjectType> sObjectTypes, Boolean partialDML){
        if(!partialDML){
            this(sObjectTypes,new SimpleDML());
        }else{
            this(sObjectTypes,new PartialDML());
        }
    }

    public SObjectUnitOfWork(List<Schema.SObjectType> sObjectTypes, IDML dml){
        m_sObjectTypes = sObjectTypes.clone();
        for(Schema.SObjectType sObjectType : m_sObjectTypes){
            // register the type
            handleRegisterType(sObjectType);
        }
        m_workList.add(m_emailWork);
        m_dml = dml;
    }

    // default implementations for commitWork events
    public virtual void onRegisterType(Schema.SObjectType sObjectType) {}
    public virtual void onCommitWorkStarting() {}
    public virtual void onDMLStarting() {}
    public virtual void onDMLFinished() {}
    public virtual void onDoWorkStarting() {}
    public virtual void onDoWorkFinished() {}
    public virtual void onCommitWorkFinishing() {}
    public virtual void onCommitWorkFinished(Boolean wasSuccessful) {}

    /**
     * Registers the type to be used for DML operations
     *
     * @param sObjectType - The type to register
     *
     */
    private void handleRegisterType(Schema.SObjectType sObjectType){
        // add type to dml operation tracking
        m_newListByType.put(sObjectType.getDescribe().getName(), new List<SObject>());
        m_dirtyMapByType.put(sObjectType.getDescribe().getName(), new Map<Id, SObject>());
        m_deletedMapByType.put(sObjectType.getDescribe().getName(), new Map<Id, SObject>());
        m_relationships.put(sObjectType.getDescribe().getName(), new Relationships());
        resultsMap.put(sObjectType.getDescribe().getName(), new DatabaseResult());

        // give derived class opportunity to register the type
        onRegisterType(sObjectType);
    }

    /**
     * Register a generic peace of work to be invoked during the commitWork phase
     **/
    public void registerWork(IDoWork work){
        m_workList.add(work);
    }

    /**
     * Registers the given email to be sent during the commitWork
     **/
    public void registerEmail(Messaging.Email email){
        m_emailWork.registerEmail(email);
    }

    /**
     * Register a newly created SObject instance to be inserted when commitWork is called
     *
     * @param record A newly created SObject instance to be inserted during commitWork
     **/
    public void registerNew(SObject record){
        registerNew(record, null, null);
    }

    /**
     * Register a list of newly created SObject instances to be inserted when commitWork is called
     *
     * @param records A list of newly created SObject instances to be inserted during commitWork
     **/
    public void registerNew(List<SObject> records){
        for(SObject record : records){
            registerNew(record, null, null);
        }
    }

    /**
     * Register a newly created SObject instance to be inserted when commitWork is called,
     *   you may also provide a reference to the parent record instance (should also be registered as new separatly)
     *
     * @param record A newly created SObject instance to be inserted during commitWork
     * @param relatedToParentField A SObjectField reference to the child field that associates the child record with its parent
     * @param relatedToParentRecord A SObject instance of the parent record (should also be registered as new separatly)
     **/
    public void registerNew(SObject record, Schema.sObjectField relatedToParentField, SObject relatedToParentRecord){
        if(record.Id != null)
            throw new UnitOfWorkException(label.OnlyNewRecordsRegisteredAsNew);
        String sObjectType = record.getSObjectType().getDescribe().getName();
        if(!m_newListByType.containsKey(sObjectType))
            throw new UnitOfWorkException(String.format(label.NotSupportedByUnitOfWork, new String[] { sObjectType }));
        m_newListByType.get(sObjectType).add(record);
        if(relatedToParentRecord!=null && relatedToParentField!=null)
            registerRelationship(record, relatedToParentField, relatedToParentRecord);
    }

    /**
     * Register a relationship between two records that have yet to be inserted to the database. This information will be
     *  used during the commitWork phase to make the references only when related records have been inserted to the database.
     *
     * @param record An existing or newly created record
     * @param relatedToField A SObjectField referene to the lookup field that relates the two records together
     * @param relatedTo A SOBject instance (yet to be commited to the database)
     */
    public void registerRelationship(SObject record, Schema.sObjectField relatedToField, SObject relatedTo){
        String sObjectType = record.getSObjectType().getDescribe().getName();
        if(!m_newListByType.containsKey(sObjectType))
            throw new UnitOfWorkException(String.format(label.NotSupportedByUnitOfWork, new String[] { sObjectType }));
        if(m_dirtyMapByType.get(sObjectType).containsKey(record.Id)){
            m_relationships.get(sObjectType).add(m_dirtyMapByType.get(sObjectType).get(record.Id), relatedToField, relatedTo);
        }else{
            m_relationships.get(sObjectType).add(record, relatedToField, relatedTo);
        }
    }

    /**
     * Register an existing record to be updated during the commitWork method
     *
     * @param record An existing record
     **/
    public void registerDirty(SObject record){
        registerDirty(record, null, null, null);
    }

    public void registerDirty(SObject record, List<String> fields){
        SObjectType objType = record.getSObjectType();
        Map<String, Schema.SObjectField> fieldsMap = objType.getDescribe().fields.getMap();
        List<Schema.sObjectField> fieldsToEdit = new List<Schema.sObjectField>();
        for(String field : fields){
            fieldsToEdit.add(fieldsMap.get(field));
        }
        registerDirty(record, null, null, fieldsToEdit);
    }

    public void registerDirty(SObject record, List<Schema.sObjectField> fieldsToEdit){
        registerDirty(record, null, null, fieldsToEdit);
    }

    public void registerDirty(SObject record, Schema.sObjectField relatedToParentField, SObject relatedToParentRecord){
        registerDirty(record, relatedToParentField, relatedToParentRecord, null);
    }

    public void registerDirty(SObject record, Schema.sObjectField relatedToParentField, SObject relatedToParentRecord, List<Schema.sObjectField> fieldsToEdit){
        if(record.Id == null)
            throw new UnitOfWorkException(label.RecordCannotBeRegisteredAsDirty);
        String sObjectType = record.getSObjectType().getDescribe().getName();
        if(!m_dirtyMapByType.containsKey(sObjectType))
            throw new UnitOfWorkException(String.format(label.NotSupportedByUnitOfWork, new String[] { sObjectType }));
        if(fieldsToEdit != null && m_dirtyMapByType.get(sObjectType).containsKey(record.Id)){

            for(Schema.sObjectField field : fieldsToEdit){
                m_dirtyMapByType.get(sObjectType).get(record.Id).put(field, record.get(field));
            }
        }else{
            m_dirtyMapByType.get(sObjectType).put(record.Id, record);
        }
        if(relatedToParentRecord!=null && relatedToParentField!=null){
            registerRelationship(record, relatedToParentField, relatedToParentRecord);
        }
    }

    /**
     * Register a list of existing records to be updated during the commitWork method
     *
     * @param records A list of existing records
     **/
    public void registerDirty(List<SObject> records){
        for(SObject record : records){
            this.registerDirty(record);
        }
    }

    /**
     * Register an existing record to be deleted during the commitWork method
     *
     * @param record An existing record
     **/
    public void registerDeleted(SObject record){
        if(record.Id == null)
            throw new UnitOfWorkException(label.NewRecordsCannotRegisteredDeletion);
        String sObjectType = record.getSObjectType().getDescribe().getName();
        if(!m_deletedMapByType.containsKey(sObjectType))
            throw new UnitOfWorkException(String.format(label.NotSupportedByUnitOfWork, new String[] { sObjectType }));
        m_deletedMapByType.get(sObjectType).put(record.Id, record);
    }

    /**
     * Register a list of existing records to be deleted during the commitWork method
     *
     * @param records A list of existing records
     **/
    public void registerDeleted(List<SObject> records){
        for(SObject record : records){
            this.registerDeleted(record);
        }
    }

    public void registerForApproval(Id recordId, String comments){
        Approval.ProcessSubmitRequest request = new Approval.ProcessSubmitRequest();
        if(comments != null)
            request.setComments(comments);
        request.setObjectId(recordId);
        approvalRequests.add(request);
    }

    public void registerForApproval(Approval.ProcessSubmitRequest request){
        approvalRequests.add(request);
    }

    private Map<String, Relationships> relationshipsReprocess = new Map<String, Relationships>();

    /**
     * Takes all the work that has been registered with the UnitOfWork and commits it to the database
     **/
    public void commitWork(){
        // notify we're starting the commit work
        onCommitWorkStarting();

        // Wrap the work in its own transaction
        Savepoint sp = Database.setSavePoint();
        Boolean wasSuccessful = false;
        try{
            // notify we're starting the DML operations
            onDMLStarting();
            // Insert by type
            for(Schema.SObjectType sObjectType : m_sObjectTypes){
                String objName = sObjectType.getDescribe().getName();
                Relationships rels = m_relationships.get(objName);
                rels.resolve();
                if(rels.relationToReProcessHasChilds()){
                    relationshipsReprocess.put(objName,rels.getRelationToReProcess());
                }
                resultsMap.get(objName).addInsertResults(m_dml.dmlInsert(m_newListByType.get(objName)));
                // Update by type
                resultsMap.get(objName).addUpdateResults(m_dml.dmlUpdate(m_dirtyMapByType.get(objName).values()));
            }

            for(String objectName : relationshipsReprocess.keySet()){
                relationshipsReprocess.get(objectName).resolve();
                resultsMap.get(objectName).addUpdateResults(m_dml.dmlUpdate(relationshipsReprocess.get(objectName).getRecords()));
            }

            // Delete by type (in reverse dependency order)
            Integer objectIdx = m_sObjectTypes.size() - 1;
            while(objectIdx>=0){
                SObjectType currentObjectType = m_sObjectTypes[objectIdx--];
                String objName = currentObjectType.getDescribe().getName();
                if(m_deletedMapByType.get(objName).values().isEmpty() || currentObjectType.getDescribe().isDeletable()){
                    resultsMap.get(objName).addDeleteResults(m_dml.dmlDelete(m_deletedMapByType.get(objName).values()));
                }else{
                    throw new UnitOfWorkException(label.CannotDeleteRecords);
                }
            }
            // notify we're done with DML
            onDMLFinished();

            // notify we're starting to process registered work
            onDoWorkStarting();
            // Generic work
            for(IDoWork work : m_workList)
                work.doWork();
            // notify we've completed processing registered work
            onDoWorkFinished();

            // notify we've completed all steps and are in the final stage of completing
            onCommitWorkFinishing();

            //send register for approvals
            try{
                approvalResults = Approval.process(approvalRequests);
            }catch(Exception e){}

            // mark tracker to indicate success
            wasSuccessful = true;
        }catch (Exception e){
            // Rollback
            Database.rollback(sp);
            // Throw exception on to caller
            throw e;
        }finally{
            // notify we're done with commit work
            onCommitWorkFinished(wasSuccessful);
        }
    }

    private class Relationships{
        private List<Relationship> m_relationships = new List<Relationship>();
        private Relationships relationToReProcess;

        public void resolve(){
            // Resolve relationships
            for(Relationship relationship : m_relationships){
                if(relationship.RelatedTo.Id != null){
                    relationship.Record.put(relationship.RelatedToField, relationship.RelatedTo.Id);
                }else{
                    if(relationToReProcess == null){
                        relationToReProcess = new Relationships();
                    }
                    relationToReProcess.add(relationship);
                }
            }
        }

        public List<SObject> getRecords(){
            List<SObject> records = new List<SObject>();
            for(Relationship relationship : m_relationships){
                records.add(relationship.record);
            }
            return records;
        }

        public Boolean hasChilds(){
            return !m_relationships.isEmpty();
        }

        public Boolean relationToReProcessHasChilds(){
            return relationToReProcess != null && relationToReProcess.hasChilds();
        }

        public Relationships getRelationToReProcess(){
            return relationToReProcess;
        }

        public List<Relationship> getRelationships(){
            return m_relationships;
        }

        public void add(Relationship relationship){
            m_relationships.add(relationship);
        }

        public void add(SObject record, Schema.sObjectField relatedToField, SObject relatedTo){
            // Relationship to resolve
            Relationship relationship = new Relationship();
            relationship.Record = record;
            relationship.RelatedToField = relatedToField;
            relationship.RelatedTo = relatedTo;
            m_relationships.add(relationship);
        }
    }

    private class Relationship{
        public SObject Record;
        public Schema.sObjectField RelatedToField;
        public SObject RelatedTo;
    }

    /**
     * UnitOfWork Exception
     **/
    public class UnitOfWorkException extends Exception {}

    /**
     * Internal implementation of Messaging.sendEmail, see outer class registerEmail method
     **/
    private class SendEmailWork implements IDoWork{
        private List<Messaging.Email> emails;

        public SendEmailWork(){
            this.emails = new List<Messaging.Email>();
        }

        public void registerEmail(Messaging.Email email){
            this.emails.add(email);
        }

        public void doWork(){
            if(emails.size() > 0) Messaging.sendEmail(emails);
        }
    }

}
