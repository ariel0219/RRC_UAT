({

    handleInit : function(cmp, evt, h) {
        cmp.set('v.step', '1');
    },

    handleStepChange : function(cmp, evt, h) {        
        let currentStep = cmp.get('v.step');
        console.log('handleStepChange(' + currentStep + ')');

        switch(currentStep) {
            case '1':
                h.download(cmp);
                break;
            case '2':
                h.send(cmp);
                break;
        }
    },

})