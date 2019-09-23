({
    doInit: function(component, event, helper) {
        try{
            if (!component.get('v.doneAdjust')) {
                var el = component.getElement();
                if (el) {
                    if (el.innerHTML) {
                        var wordArray = el.innerHTML.split(' ');
                        while(el.scrollHeight > el.offsetHeight) {
                            wordArray.pop();
                            el.innerHTML = wordArray.join(' ') + '...';
                        }
                        component.set('v.doneAdjust', true);
                    }    
                }
            }
        } catch(e) {
            console.log(e);
        }
    }
})