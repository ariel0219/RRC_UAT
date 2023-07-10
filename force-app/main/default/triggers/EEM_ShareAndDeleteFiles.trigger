trigger EEM_ShareAndDeleteFiles on ContentDocumentLink (After insert, After Update) {

    If(trigger.IsInsert && trigger.IsAfter){  
        System.debug('Calling Share files Method');
        EEM_FilesShareAndDeleteHandler.shareFiles(trigger.new);
          }
   
 }