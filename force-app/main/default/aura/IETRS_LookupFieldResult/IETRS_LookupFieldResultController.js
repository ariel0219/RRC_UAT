({
    
    selectRecord : function(cmp, evt, h){      
        var record = cmp.get('v.record');
        console.log('record clicked', JSON.stringify(record, null, 4));
        
        var cmpEvent = cmp.getEvent('recordSelectedEvent');        
        cmpEvent.setParams({
            'selectedRecord' : record 
        });
        cmpEvent.fire();
    },

})