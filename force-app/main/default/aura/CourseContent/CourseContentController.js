({
    doInit: function(component, event, helper) {
        try{
            var config = JSON.parse(component.get('v.config'));
            var record = component.get('v.record');
            if (record.FieloELR__Image__c) {
                if (config.orgId && config.communityURL) {
                    var imageURL = config.communityURL + 'servlet/servlet.ImageServer?id=' + record.FieloELR__Image__c + '&oid=' + config.orgId;
                    component.set('v.imageURL', imageURL);
                }
            }
        } catch(e) {
            console.log(e);
        }
    }
})