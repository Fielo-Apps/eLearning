/**
 * @brief       Script to create 200 members from static resource
 *             
 * @details     There should be already 1 program in the org
 *              The script will create 1 account (if it does not exist) and
 *              200 members assigned to it
 */

List<FieloPLT__Program__c> programs = [SELECT Id FROM FieloPLT__Program__c];
if (programs.isEmpty()) {
    programs.add(new FieloPLT__Program__c(
        Name = 'Default',
        FieloPLT__OnlineTransactionProcessing__c = true//,
    ));
    insert programs;
}
StaticResource defaultResource = [Select  s.Body From StaticResource s where s.Name LIKE 'memberNames'];
blob tempB = defaultResource.Body;
String contentFile = tempB.toString();
List<String> filelines = contentFile.split('\n');
List<FieloPLT__Member__c> members = new List<FieloPLT__Member__c>();
List<String> inputvalues;

List<Account> fieloAcc = [SELECT Id FROM Account WHERE Name = 'Fielo Members'];

if (fieloAcc.isEmpty()) {
    fieloAcc.add(new Account(Name='Fielo Members'));
    insert fieloAcc;
}


for (Integer i=0;i<filelines.size();i++) {
    inputvalues = filelines[i].split(',');
    members.add(
        new FieloPLT__Member__c(
            Name = inputValues[0] + ' ' + inputValues[1],
            FieloPLT__Email__c = (inputValues[0] + '.' + inputValues[1]).trim().replace(' ','') + '@email.com',
            FieloPLT__Program__c = programs.get(0).Id,
            FieloPLT__Account__c = fieloAcc.get(0).Id
        )
    );
}
if (!members.isEmpty()) {
    insert members;
}
