public class ConvertFileToAttachment {

    public class DocClass {

        @InvocableVariable(label='F&C Id' description='F&C Id')

        public String FilesCorrespondenceID;
        
        @InvocableVariable(label='Original File Name' description='Original File Name')

        public String OriginalFileName;
        

    }

    @invocableMethod(label='Convert Files to Attachements')

    public static List<String> convertFiles(List<DocClass> docList) {

        system.debug('docList is : ' + docList);

        for (DocClass doc : docList) {

            List<ContentDocumentLink> docLinks = [Select ContentDocumentId, LinkedEntityID From ContentDocumentLink Where LinkedEntityID =:doc.FilesCorrespondenceID];

            system.debug(docLinks);

            for (ContentDocumentLink doc_link : docLinks){

                ContentVersion cv = [select ContentDocumentId, VersionData from ContentVersion where ContentDocumentId =:doc_link.ContentDocumentId];

                ContentDocument cd = [select id, title from ContentDocument where id =:cv.ContentDocumentId];

                Attachment attc = new Attachment();

                attc.Body = (cv.VersionData);

                attc.ParentId = doc.FilesCorrespondenceID;

                attc.Name = doc.OriginalFileName;

                insert attc;

                delete doc_link;

            }

        }

        return new List<String>{ 'Error: No record found' };

    }

}