public class ProgramService {
	private static Map<Id, FieloPLT__Program__c> programMap;
	
	public static FieloPLT__Program__c getActiveProgram(){
        // Busca el id del Program Activo
        FieloPLT__Settings__c settings;
        // SR: CRUD Check
        if (Schema.sObjectType.FieloPLT__Settings__c.isAccessible()) {
            settings = FieloPLT__Settings__c.getInstance(UserInfo.getUserId());
        } else {
            throw new FieloPLT.FieloException(String.format(Label.security_error_object_not_readable, new List<String>{'FieloPLT__Settings__c'}));
        }

        // SR: FLS Check
        if ( !Schema.sObjectType.FieloPLT__Settings__c.fields.FieloPLT__CurrentProgramId__c.isAccessible() ) {
            throw new FieloPLT.FieloException(String.format(Label.security_error_field_not_readable, new List<String>{'FieloPLT__Settings__c', 'FieloPLT__CurrentProgramId__c'}));
        }

        if(!String.isEmpty(settings.FieloPLT__CurrentProgramId__c)){
            try{
                FieloPLT__Program__c program = getProgram(settings.FieloPLT__CurrentProgramId__c);
                if(program != null){
                    return program;
                }
            }catch(Exception e){
                // Si falla por que el Id esta mal guardado continua

            }
        }
        // Si el usuario no tiene ninguno activo entonces activa el primero
        FieloPLT__Program__c program;
        if(hasPrograms()){
            program = hasPrograms() ? getPrograms().values().get(0) : null;
            settings.FieloPLT__CurrentProgramId__c = program.Id;
        }
        return program;
    }

    public static Boolean hasPrograms(){
        return getPrograms().size() > 0;
    }

    public static Map<Id,FieloPLT__Program__c> getPrograms(){

        if(programMap == null){
            if( Schema.sObjectType.FieloPLT__Program__c.isAccessible()) {
                programMap = new Map<Id, FieloPLT__Program__c>([SELECT Id, Name FROM FieloPLT__Program__c limit 5000]);
            }
        }
        return programMap;
    }

    public static FieloPLT__Program__c getProgram(Id programId){
        if(programId != null && getPrograms().containsKey(programId)){
            return getPrograms().get(programId);
        }
        return null;
    }

    public static List<SelectOption> getProgramsLandingSelectOptions(){
        Map<Id, FieloPLT__Program__c> programsMap = getPrograms();

        List<SelectOption> options = new List<SelectOption>();
        for(FieloPLT__Program__c program: programsMap.values()){
            options.add(new SelectOption(program.Id, program.Name));
        }
        sortSelectOptions(options);
        return options;
    }

    public static void sortSelectOptions(List<SelectOption> records){
        Map<String, Selectoption> mapping = new Map<String, Selectoption>();

        // Suffix to avoid duplicate values like same labels or values are in inbound list
        Integer suffix = 1;

        for (Selectoption opt : records) {
            mapping.put((opt.getLabel() + suffix++), opt);
        }

        List<String> sortKeys = new List<String>();
        sortKeys.addAll(mapping.keySet());

        sortKeys.sort();

        // clear the original collection to rebuilt it
        records.clear();

        for (String key : sortKeys) {
            records.add(mapping.get(key));
        }
    }

    public static void selectProgram(Id programId){
        FieloPLT__Settings__c settings = FieloPLT__Settings__c.getInstance(UserInfo.getUserId());
        if( Schema.sObjectType.FieloPLT__Settings__c.fields.FieloPLT__CurrentProgramId__c.isCreateable() && Schema.sObjectType.FieloPLT__Settings__c.fields.FieloPLT__CurrentProgramId__c.isUpdateable()  ){
            settings.FieloPLT__CurrentProgramId__c = programId;
        }

        if(Schema.sObjectType.FieloPLT__Settings__c.isUpdateable() && Schema.sObjectType.FieloPLT__Settings__c.isCreateable()){
            upsert settings;
        }else{
            throw new FieloPLT.FieloException(Label.CannotInsertUpdateRecords);
        }
    }
}