({
    showRecord: function(component, event, helper){
        var recordEvent = component.getEvent("showRecord");
        var record = component.get('v.record');
        if(recordEvent){
            recordEvent.setParams({'record': record});
            recordEvent.fire();
        }
    }
})