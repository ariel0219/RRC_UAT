public with sharing class RRC_BoxElementsController {
    // Figure out if needs to be repalced with different URL
    public string ltnOrigin {get{ return URL.getOrgDomainUrl().toExternalForm().split('\\.')[0] + '.lightning.force.com';} set;}

    @AuraEnabled(cacheable = true)
    public static string getVFOrigin() {
        string vfOrigin = '';
        string baseURL = URL.getOrgDomainUrl().toExternalForm(); // Expected Format = https://domain.my.salesforce.com
        System.debug('baseURL:'+baseURL);
        // Expected Format for DE, Sandbox & Production ORgs = https://domain--c.visualforce.com
        vfOrigin = baseURL.split('.my.')[0] + '--c.' + 'visualforce.com';
        System.debug('vfOrigin:'+vfOrigin);
        /* ********* Below odd Discrepancy was found while implementing this in a Trailhead Playground ***********
        Organization oOrg = [SELECT InstanceName, IsSandbox, OrganizationType FROM Organization LIMIT 1];
        if(oOrg.OrganizationType == 'Developer Edition'){
        // Expected Format for Trailhead Playground DE Org = https://domain--c.ap4.visual.force.com
        vfOrigin = baseURL.split('.my.')[0]+'--c.'+oOrg.InstanceName.toLowercase()+'.visual.force.com';
        } else {
        // Expected Format for personal DE, Sandbox & Production Orgs = https://domain--c.visualforce.com
        vfOrigin = baseURL.split('.my.')[0]+'--c.'+'visualforce.com';
        }  */

        return vfOrigin;
    }


    @AuraEnabled()
    public static Map<String, String> downscopeToken(String resourceType, String recordId, String folderId, String scopes) {
        
        // Boolean to check if we're in a sandbox
        Boolean isSandbox = [SELECT IsSandbox FROM Organization Limit 1].IsSandbox;

        // Used to set the src for the lwc iframe
        String ltnOrigin;
        
        // Set ltnOrigin based on if we're in production or not
        if(
            isSandbox
        ) {
            ltnOrigin = URL.getOrgDomainUrl().toExternalForm().split('\\.')[0] + '.sandbox.mysite.com';
        } else {
            ltnOrigin = URL.getOrgDomainUrl().toExternalForm().split('\\.')[0] + '.force.com';
        }
        
        // Map for return values
        Map<String, String> buieMap = new Map<String, String>();
        // Call IETRSBox to get our downscope token
        IETRSBox box = new IETRSBox();

    
        // Get userId and folderId from FRUP record
        box__FRUP__c frup;
        if(String.isEmpty(folderId)) {
            frup = [SELECT box__Folder_ID__c, box__Record_ID__c, box__Box_user__c FROM box__FRUP__c WHERE box__Record_ID__c = :recordId LIMIT 1];
            folderId = frup.box__Folder_ID__c;
        }

        // Set folderId and downscoped token to pass back to LWC javascript controller
        buieMap.put('folderId', folderId);
        System.debug('folderId:'+folderId);
        buieMap.put('accessToken', box.api.accessToken); //Empty parameter for file upload token
        System.debug('accessToken:'+box.api.accessToken);
        buieMap.put('ltnOrigin', ltnOrigin);
        System.debug('ltnOrigin:'+ltnOrigin);
        return buieMap;
    }
}