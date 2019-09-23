({
    doInit : function(component, event, helper) {
        
        var config = component.get('v.config');
        var layout = config.layout || 'bar';
        component.set('v.layout', layout);
        var record = component.get('v.record');
        var fieldName = component.get('v.fieldName');
                
        var percentage = Math.min(360, (Number(record[fieldName]) * 360 / 100));
        if(layout == 'gauge'){            
            
            percentage = (Math.min(100, Number(record[fieldName])) * 180 / 100) - 180;
            /*
            var range = component.get('v.range');
            var lowrangeMarker = (Math.min(Number(range[2]), Number(range[0])) * 180 / 100) - 90;
            var highrangeMarker = (Math.min(Number(range[2]), Number(range[1])) * 180 / 100) - 90;
            
            
            var markerLow = '-webkit-transform: rotate(' + lowrangeMarker + 'deg);-moz-transform: rotate(' + lowrangeMarker + 'deg);-ms-transform: rotate(' + lowrangeMarker + 'deg);   -o-transform: rotate(' + lowrangeMarker + 'deg);transform: rotate(' + lowrangeMarker + 'deg);';
            var markerHigh = '-webkit-transform: rotate(' + highrangeMarker + 'deg);-moz-transform: rotate(' + highrangeMarker + 'deg);-ms-transform: rotate(' + highrangeMarker + 'deg);   -o-transform: rotate(' + highrangeMarker + 'deg);transform: rotate(' + highrangeMarker + 'deg);';
            component.set('v.lowrangeStyle', markerLow);
            component.set('v.highrangeStyle', markerHigh);
            
            var dataLow = '-webkit-transform: rotate(' + (lowrangeMarker - 90) + 'deg);-moz-transform: rotate(' + (lowrangeMarker - 90) + 'deg);-ms-transform: rotate(' + (lowrangeMarker - 90) + 'deg);   -o-transform: rotate(' + (lowrangeMarker - 90) + 'deg);transform: rotate(' + (lowrangeMarker - 90) + 'deg);';
            var dataHigh = '-webkit-transform: rotate(' + (highrangeMarker - 90) + 'deg);-moz-transform: rotate(' + (highrangeMarker - 90) + 'deg);-ms-transform: rotate(' + (highrangeMarker - 90) + 'deg);   -o-transform: rotate(' + (highrangeMarker - 90) + 'deg);transform: rotate(' + (highrangeMarker - 90) + 'deg);';
            component.set('v.lowdataStyle', dataLow);
            component.set('v.highdataStyle', dataHigh);
            */
        }else{
            if(Number(record[fieldName]) > 50){
                component.set('v.percentage', 'over50');
            }    
        }
        
        var style = '-webkit-transform: rotate(' + percentage + 'deg);-moz-transform: rotate(' + percentage + 'deg);-ms-transform: rotate(' + percentage + 'deg);   -o-transform: rotate(' + percentage + 'deg);transform: rotate(' + percentage + 'deg);';
        component.set('v.percentageStyle', style);
        component.set('v.value', record[fieldName]);
        
    }
})