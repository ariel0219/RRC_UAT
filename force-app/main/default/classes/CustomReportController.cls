public class CustomReportController {
    @AuraEnabled
    public static List<String> getRegionNames() 
    {
        IETRS_Coutries__c Regions=[select id,Country_Names__c from IETRS_Coutries__c limit 1];
        return Regions.Country_Names__c.split(';');
    }
    @AuraEnabled
    public static List<String> getCountyNames() 
    {
        List<String> countyList=new List<String>();
        for(IETRS_County__c county:[select id, name from IETRS_County__c])
        {
            countyList.add(county.name);
        }
        return countyList;
        
    }
    @AuraEnabled
    public static List<String> getSystemTypes() 
    {
        //List<String> types =[select id,SystemType_Name__c from IETRS_SystemType__c limit 1].SystemType_Name__c.split(';');
        List<String> types=new List<String>();
        Set<String> temp=new Set<String>();
        for(Account acc:[select Type from Account where RecordType.Name='Unit'])
        {
            if(acc.Type!=null)
            {
                temp.add(acc.Type);
            }
        }
        types.addAll(temp);
        return types;
        
    }
}