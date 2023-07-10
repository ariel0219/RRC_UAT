public class EEM_FilesShareAndDeleteHandler{
    public static void shareFiles(List<ContentDocumentLink> cdlList1){
        String name;
        for(ContentDocumentLink cd:cdlList1 ){
            System.debug('EmailTemplate'+cd.LinkedEntityId);
            String id = cd.LinkedEntityId;
            if (id.substring(0,3) == '00X') {
                name = [SELECT Id,Name  FROM EmailTemplate where Id = :id].get(0).Name;
                System.debug('name'+name);
            } 
        }
        if(name=='EEM Certificate for Conferences'){
            Set<Id> documentIdsForUsr = new Set<Id>();
            Set<Id> newDocumentIds = new Set<Id>();
            List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>();
            // id userId = '005r0000007XjOB';
            String uid=Userinfo.getUserId();
            Set<Id>userids=new Set<Id>();
            List<PermissionSetAssignment>copusers=[SELECT AssigneeId FROM PermissionSetAssignment WHERE PermissionSet.Name = 'EEM_RRC_Events_Management_COP_Admin'];
            System.debug('copusers'+copusers);
            for(PermissionSetAssignment psa: copusers){
                userids.add(psa.AssigneeId);
                
            }
            System.debug('users'+userids);
            userids.remove(uid);
            
            
            List<ContentDocumentLink> cdl=[SELECT id,LinkedEntityId,LinkedEntity.Name,ContentDocument.title,ContentDocumentId,ContentDocument.OwnerId FROM ContentDocumentLink WHERE LinkedEntityId IN:userids ];
            
            
            for(ContentDocumentLink cdLink:cdl){  
                documentIdsForUsr.add(cdLink.ContentDocumentId);  
            } 
            
            for(ContentDocumentLink cdLink:cdlList1){  
                
                newDocumentIds.add(cdLink.ContentDocumentId);  
            }
            
            
            
            for(ID id : newDocumentIds){
                
                if(!documentIdsForUsr.contains(id)){     
                    
                    for(Id us:userids){
                        ContentDocumentLink cd = new ContentDocumentLink();
                        cd.ContentDocumentId = id;
                        cd.LinkedEntityId = us;
                        cd.ShareType = 'C';
                        cd.Visibility = 'Allusers';
                        cdlList.add(cd); 
                        system.debug('New Assignment Is being Created');
                    }
                    
                }
                
            }
            insert cdlList;
        }
    
    }
}