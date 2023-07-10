({
    doSelectChange : function(component, event, helper) {
        if(component.get('v.ltngSelectedvalue') == '--Select One--'){
            component.set('v.showButton', false);
            component.set('v.showCard', false);
        }else{ 
            component.set('v.showButton', true);   
            console.log('Test###', component.get('v.ltngSelectedvalue'));}
    },
    onSelect : function(component, event, helper){
        component.set('v.showCard', true);
        if(component.get('v.ltngSelectedvalue') == 'Summary System Scheduling')
        {
            component.set('v.showScheduleFilter', true); 
            component.set('v.showCoastlineAddrFilter', false); 
            component.set('v.showPerformanceQtrFilter', false); 
            component.set('v.showOperatorAddrFilter', false);
            component.set('v.showSystemMilesFilter', false); 
            component.set('v.showNoOfUnitsFilter', false); 
            
        }
        else if(component.get('v.ltngSelectedvalue') == 'Eastern Coastline Addresses')
        {
            component.set('v.showScheduleFilter', false); 
            component.set('v.showCoastlineAddrFilter', true); 
            component.set('v.showPerformanceQtrFilter', false); 
            component.set('v.showOperatorAddrFilter', false);
            component.set('v.showSystemMilesFilter', false); 
            component.set('v.showNoOfUnitsFilter', false); 
            
        }
            else if(component.get('v.ltngSelectedvalue') == 'Performance Quarters report')
            {
                component.set('v.showScheduleFilter', false); 
                component.set('v.showCoastlineAddrFilter', false); 
                component.set('v.showPerformanceQtrFilter', true); 
                component.set('v.showOperatorAddrFilter', false);
                component.set('v.showSystemMilesFilter', false); 
                component.set('v.showNoOfUnitsFilter', false); 
                
            }
                else if(component.get('v.ltngSelectedvalue') == 'Operator Address')
                {
                    component.set('v.showScheduleFilter', false); 
                    component.set('v.showCoastlineAddrFilter', false); 
                    component.set('v.showPerformanceQtrFilter', false); 
                    component.set('v.showOperatorAddrFilter', true);
                    component.set('v.showSystemMilesFilter', false); 
                    component.set('v.showNoOfUnitsFilter', false); 
                    helper.getCounty(component, event, helper);
                    helper.getSystemType(component, event, helper);
                }
                    else if(component.get('v.ltngSelectedvalue') == 'System Miles by Region')
                    {
                        component.set('v.showScheduleFilter', false); 
                        component.set('v.showCoastlineAddrFilter', false); 
                        component.set('v.showPerformanceQtrFilter', false); 
                        component.set('v.showOperatorAddrFilter', false);
                        component.set('v.showSystemMilesFilter', true); 
                        component.set('v.showNoOfUnitsFilter', false); 
                        helper.getRegions(component, event, helper);
                        helper.getSystemType(component, event, helper);
                    }
                        else if(component.get('v.ltngSelectedvalue') == 'Number of Units by Region')
                        {
                            component.set('v.showScheduleFilter', false); 
                            component.set('v.showCoastlineAddrFilter', false); 
                            component.set('v.showPerformanceQtrFilter', false); 
                            component.set('v.showOperatorAddrFilter', false);
                            component.set('v.showSystemMilesFilter', false); 
                            component.set('v.showNoOfUnitsFilter', true); 
                            
                        }
        
        
    },
    generatePDF : function(component, event, helper){
        var isValid=false;
        var selectedReport=component.get('v.ltngSelectedvalue');
        var url;
        if(selectedReport=='Summary System Scheduling')
        {
            isValid=false;
            var regExp=/^[\d]*$/; 
            var selectedYear=component.find("ltngSelectedYear").get('v.value');
            selectedYear=selectedYear.replace(/ /g,'');
            console.log(selectedYear);
            console.log(selectedYear.length);
            if(selectedYear.length!=4){
                alert('Please enter valid year with atleast 4 digits'); 
            }
            else if(!regExp.test(selectedYear))
            {
                alert('Please enter valid year with 4 digits number only'); 
            }
                else
                {
                    isValid=true;
                }
            
            url='/apex/IETRS_Custom_Report_PDF?selectedReport='+ selectedReport+'&Year='+selectedYear
        }
        else if(component.get('v.ltngSelectedvalue') == 'Eastern Coastline Addresses')
        {
            isValid=true;
            // var selectedAddr=component.get('v.ltngSelectedAddr');
            var selectedAddr='None';
            url='/apex/IETRS_Custom_Report_PDF?selectedReport='+ selectedReport+'&addr='+selectedAddr
        }
            else if(component.get('v.ltngSelectedvalue') == 'Performance Quarters report')
            {
                isValid=true;
                var selectedQtr=component.get('v.ltngSelectedQtr');
                var selectedQtrYr=component.get('v.ltngSelectedQtrYr');
                url='/apex/IETRS_Custom_Report_PDF?selectedReport='+ selectedReport+'&Qtr='+selectedQtr+'&QtrYr='+selectedQtrYr
            }
                else if(component.get('v.ltngSelectedvalue') == 'Operator Address')
                {
                    isValid=true;
                    var selectedCtry=component.get('v.ltngSelectedCtry');
                    var selectedSystemType=component.get('v.ltngSelectedType');
                    console.log('selectedCtry'+selectedCtry)
                    url='/apex/IETRS_Custom_Report_PDF?selectedReport='+ selectedReport+'&Ctry='+selectedCtry+'&typ='+selectedSystemType  
                }
                    else if(component.get('v.ltngSelectedvalue') == 'System Miles by Region')
                    {
                        isValid=true;
                       // var selectedReg=component.get('v.ltngSelectedReg');
                       // var selectedSType=component.get('v.ltngSelectedSType');
                        
                       // console.log('selectedReg'+selectedReg);
                       // url='/apex/IETRS_Custom_Report_PDF?selectedReport='+ selectedReport+'&Reg='+selectedReg+'&sTyp='+selectedSType
                        var selectedMile=component.get('v.ltngSelectedMile');
                            url='/apex/IETRS_Custom_Report_PDF?selectedReport='+ selectedReport+'&Mile='+selectedMile   
                    }
                        else if(component.get('v.ltngSelectedvalue') == 'Number of Units by Region')
                        {
                            isValid=true;
                            var selectedUnit=component.get('v.ltngSelectedUnit');
                            url='/apex/IETRS_Custom_Report_PDF?selectedReport='+ selectedReport+'&Unit='+selectedUnit   
                        }
        
        //  var url='/apex/IETRS_Custom_Report_PDF?selectedReport='+ selectedReport+'&Year='+selectedYear+'&addr='+selectedAddr+'&Qtr='+selectedQtr+'&Ctry='+selectedCtry+'&Reg='+selectedReg+'&Unit='+selectedUnit
        if(isValid)
        {
            window.open(url,'_blank')
        }
        
    } 
    
    
    
})