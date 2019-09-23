public class MembersSelector extends SObjectSelector{
    public List<Schema.SObjectField> getSObjectFieldList(){
        return new List<Schema.SObjectField> {
                FieloPLT__Member__c.Id,
                FieloPLT__Member__c.Name,
                FieloPLT__Member__c.FieloPLT__Program__c   
            };
    }

    public MembersSelector(Set<String> fields){
        super(fields);
    }

    public MembersSelector(){
        super();
    }

    public Schema.SObjectType getSObjectType(){
        return FieloPLT__Member__c.sObjectType;
    }

    public List<FieloPLT__Member__c> selectById(Set<Id> MemberIds){
        return (List<FieloPLT__Member__c>) selectSObjectsById(MemberIds);
    }
}