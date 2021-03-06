/**
 * @brief      Clase Result de acciones en JSRemoting
 * @details    La clase contiene metodos y clases para poder devolver como resultado luego de hacer acciones en el sitio por JSRemoting
 */
global class RemoteActionResult {
    global String redirectURL;
    global List<String> recordsId = new List<String>();
    global List<RemoteActionRefresh> refresh = new List<RemoteActionRefresh>();
    private List<RemoteActionMessage> messages = new List<RemoteActionMessage>();
    private Set<String> messagesSet = new Set<String>();

    /**
     * @brief       Metodo para agregar un msj al resultado
     * @details     Dado un remote action message el mismo se agrega a la lista del resultado verificando duplicidad
     * @version     10.0
     * @param       message             informacion del mensaje
     * @returns     Void
     * @test
     * @code          
     *          FieloEE.RemoteActionResult result = new FieloEE.RemoteActionResult();
     *          try{
     *              //CODIGO
     *          }catch(FieloCustomException e){
     *              FieloEE.RemoteActionResult.RemoteActionMessage msg = new FieloEE.RemoteActionResult.RemoteActionMessage(e);
     *              result.addMessage(msg);
     *          }
     * @endcode
     */
    global void addMessage(RemoteActionMessage message){
        if(!messagesSet.contains(message.summary)){
            this.messages.add(message);
            this.messagesSet.add(message.summary);
        }
    }

    /**
     * @brief       Metodo para agregar multiples msjs al resultado
     * @details     Dado una lista de remote action messages estos se agregan a la lista del resultado verificando duplicidad
     * @version     10.0
     * @param       messages             informacion de los mensajes a agregar
     * @returns     Void
     * @test
     * @code          
     *          FieloEE.RemoteActionResult result = new FieloEE.RemoteActionResult();
     *          try{
     *              //CODIGO
     *          }catch(FieloCustomException e){
     *              FieloEE.RemoteActionResult.RemoteActionMessage msg = new FieloEE.RemoteActionResult.RemoteActionMessage(e);
     *              ApexPages.message errorMsg = new ApexPages.message('Error Msg');
     *              result.addMessage(new List<RemoteActionMessage>{msg, new FieloEE.RemoteActionResult.RemoteActionMessage(errorMsg)});
     *          }
     * @endcode
     */
    global void addMessages(List<RemoteActionMessage> messages){
        for(RemoteActionMessage msg : messages){
            addMessage(msg);
        }        
    }

    public List<RemoteActionMessage> getMessages(){
        return new List<RemoteActionMessage>(messages);
    }

    global class RemoteActionRefresh{
        public String name;
        public String value;       

        global RemoteActionRefresh ( String name, String value ) {
            this.name = name;
            this.value = value;
        }
        
    }

    global class RemoteActionMessage {
        public ApexPages.Severity severity;
        public String summary;
        public String detail;
        public String componentId;   
        
        global RemoteActionMessage ( Exception e ) {
            this.severity = ApexPages.Severity.Error;
            this.summary = e.getMessage();            
            this.detail = e.getStackTraceString();
            this.componentId = null;
        }

        global RemoteActionMessage ( DMLException e ) {
            this.severity = ApexPages.Severity.Error;
            this.summary = '';
            for(Integer i = 0; i < e.getNumDML(); i++){
                this.summary += e.getDMLMessage(i) + ' ';  
            }          
            this.detail = e.getStackTraceString();
            this.componentId = null;
        }

        global RemoteActionMessage ( Exception e, Id componentId ) {
            this.severity = ApexPages.Severity.Error;
            this.summary = e.getMessage();            
            this.detail = e.getStackTraceString();
            this.componentId = componentId;
        }

        global RemoteActionMessage ( DMLException e, Id componentId ) {
            this.severity = ApexPages.Severity.Error;
            this.summary = '';
            for(Integer i = 0; i < e.getNumDML(); i++){
                this.summary += e.getDMLMessage(i) + ' ';  
            }            
            this.detail = e.getStackTraceString();
            this.componentId = componentId;
        }
        
        global RemoteActionMessage ( ApexPages.message m, String sObjectName ) {
            this.severity = m.getSeverity();
            this.summary = m.getSummary();            
            this.detail = m.getDetail();
            // Convierte el label en apiname
            if ( m.getComponentLabel() != null && sObjectName != null ) {
                Schema.SobjectType objectType = Schema.getGlobalDescribe().get(sObjectName);
                if ( objectType != null ) {
                    for (Schema.SObjectField f: objectType.getDescribe().fields.getMap().values() ) {
                        DescribeFieldResult field = f.getDescribe();
                        if ( field.getLabel() == m.getComponentLabel() ) {
                            this.componentId = field.getName();
                            break;
                        }
                    }                    
                }
                
            }
        }

        global RemoteActionMessage ( ApexPages.Severity severity, String summary ) {
            this.severity = severity;
            this.summary = summary;            
        }
         
        global RemoteActionMessage( ApexPages.Severity severity, String summary, String detail, String componentId ) {
            this.severity = severity;
            this.summary = summary;
            this.detail = detail;
            this.componentId = componentId;            
        }
    }
}