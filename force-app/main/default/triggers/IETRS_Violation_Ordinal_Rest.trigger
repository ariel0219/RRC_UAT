/**
 * @File Name          : IETRS_Violation_Ordinal_Renumber
 * @Description        :
 * @Author             : Paul McCollum
 * @Group              :
 * @Last Modified By   : Sandhya Belur
 * @Last Modified On   : 4/24/2020, 07:36 AM
 * @Modification Log   :
 *==============================================================================
 * Ver           Date                        Author                  Modification
 *==============================================================================
 * 1.0           8/26/2019, 2:24:18 PM       Paul McCollum           Initial Version
 * 1.1           4/24/2020, 07:36 AM         Sandhya Belur           Implement Event History on delete of any record.
 **/

trigger IETRS_Violation_Ordinal_Rest on IETRS_Violation__c(after delete) {
    //on delete from Trigger.Old
    //has inspection number?
    //select all violations with that inspection number. order by datesubmitted
    //join select with has already sent notifications
    //if has sent notifications: stop
    //select Id from IETRS_Files_Correspondence__c
    //where IETRS_Sent_Date_Time__c != null
    //and IETRS_Inspection_Package__c IN (select IETRS_Inspection__c.IETRS_Inspection_Package__c from IETRS_Inspection__c where Id= 'a0s35000000dDo6AAE')
    //else : loop over list and update/re-increment violation numbers

    //select all violations for all inspections in the trigger._new_ array into new array order by inspection
    //start for loop with increment update++ until inspection changes.
    //update.
    //trigger deleted-violationbb b
    //1 -->inspections
    //2     -->inspection packages IN affectedInspections
    //3         -->FC sent packages IN affectedInspectionPackages
    //4             -->FC'd inspections IN FC sent packages
    //5                 -->Inspections IN affectedInspections NOT IN FC sent packages
    //6                     -->all violations IN those inspections
    system.debug('violation start');
    //take trigger violation list and convert to list of inspections
    set<Id> listInspectionIds = new Set<Id>();
    List<Task> lstTask = new List<Task>();

    for (IETRS_Violation__c childItem : Trigger.old) {
        if (childItem.IETRS_Inspection__c != null) {
            listInspectionIds.add(childItem.IETRS_Inspection__c);
            system.debug('Inspection to Reorder ' + childItem.IETRS_Inspection__c + '\n');

            Id WhatId = childItem.IETRS_Inspection__c;
            String note =
                'Violation record deleted with Name ' +
                childItem.Name +
                ' , State : ' +
                childItem.IETRS_State__c +
                ' , Status : ' +
                childItem.IETRS_Status__c +
                ' , Violation Number : ' +
                childItem.IETRS_Violation_Num__c;
            Task objTask = IETRS_Utility.createActivityHistoryRecord(WhatId, note);
            objTask.Description = note;
            objTask.Subject = 'Violation Deleted';
            lstTask.add(objTask);
        }

        if (childItem.IETRS_Inspection_Package__c != null) {
            // code for Event History
            Id WhatId = childItem.IETRS_Inspection_Package__c;
            String note =
                'Violation record Deleted with Name ' +
                childItem.Name +
                ' , State : ' +
                childItem.IETRS_State__c +
                ' , Status : ' +
                childItem.IETRS_Status__c +
                ' , Violation Number : ' +
                childItem.IETRS_Violation_Num__c;
            Task objTask = IETRS_Utility.createActivityHistoryRecord(WhatId, note);
            objTask.Description = note;
            objTask.Subject = 'Violation Deleted';
            lstTask.add(objTask);
        }
    }
    //step 1 may not be necessary. If trigger.Old contains IETRS_Inspection__c
    //1 take inspection list and get all Inspections related to the violation deletions
    List<IETRS_Violation__c> listAllAffectedInspections = [
        SELECT Id, IETRS_Inspection__c
        FROM IETRS_Violation__c
        WHERE IETRS_Inspection__c IN :listInspectionIds
        ORDER BY createdDate
    ];
    set<Id> inspListIds = new Set<Id>();
    for (IETRS_Violation__c childItem : Trigger.old) {
        if (childItem.IETRS_Inspection__c != null) {
            inspListIds.add(childItem.IETRS_Inspection__c);
            system.debug('Inspection to Reorder ' + childItem.IETRS_Inspection__c + '\n');
        }
    }

    //2 get all inspection packages associate to Inspections of Violations
    List<IETRS_Inspection__c> listInspectionPackages = [
        SELECT Id, IETRS_Inspection_Package__c
        FROM IETRS_Inspection__c
        WHERE Id IN :inspListIds
    ];
    set<Id> listInspectionPackageIds = new Set<Id>();
    for (IETRS_Inspection__c I : listInspectionPackages) {
        if (I.IETRS_Inspection_Package__c != null) {
            listInspectionPackageIds.add(I.IETRS_Inspection_Package__c);
        }
    }

    //3 of the packages above(with violations), get the ones that have Files and Sent dates. aka that should not be reordered.
    List<IETRS_Files_Correspondence__c> listInspectionPackageSentRecords = [
        SELECT Id, IETRS_Inspection_Package__c
        FROM IETRS_Files_Correspondence__c
        WHERE IETRS_Sent_Date_Time__c != null AND IETRS_Inspection_Package__c IN :listInspectionPackageIds
    ];
    set<Id> listLockedInspectionPackageIds = new Set<Id>();
    for (IETRS_Files_Correspondence__c L : listInspectionPackageSentRecords) {
        if (L.IETRS_Inspection_Package__c != null) {
            listLockedInspectionPackageIds.add(L.IETRS_Inspection_Package__c);
        }
    }

    //4             -->FC'd inspections IN FC sent packages
    List<IETRS_Inspection__c> listFCdInspectionPackages = [
        SELECT Id
        FROM IETRS_Inspection__c
        WHERE IETRS_Inspection_Package__c IN :listLockedInspectionPackageIds
    ];
    set<Id> setFCdInspectionIds = new Set<Id>();
    for (IETRS_Inspection__c FI : listFCdInspectionPackages) {
        if (FI.Id != null) {
            setFCdInspectionIds.add(FI.Id);
        }
    }
    //5                 -->Inspections IN affectedInspections NOT IN FC sent packages
    List<IETRS_Inspection__c> listInspectionsForReorder = [
        SELECT Id
        FROM IETRS_Inspection__c
        WHERE Id IN :inspListIds AND Id NOT IN :setFCdInspectionIds
    ];
    set<Id> setInspectionIdsForReorder = new Set<Id>();
    for (IETRS_Inspection__c IR : listInspectionsForReorder) {
        if (IR.Id != null) {
            setInspectionIdsForReorder.add(IR.Id);
        }
    }

    //6 get all violations related to the violation deletions
    List<IETRS_Violation__c> allAffectedViolations = [
        SELECT Id, IETRS_Inspection__c, IETRS_Violation_Num__c
        FROM IETRS_Violation__c
        WHERE IETRS_Inspection__c IN :listInspectionsForReorder
        ORDER BY createdDate
    ];

    system.debug('FC count ');

    Integer varViolationCounter = 1;
    String varThisInspection = '';
    if (allAffectedViolations.size() > 0) {
        ID thisInspectionId = allAffectedViolations[0].Id;
        for (IETRS_Violation__c thisViolation : allAffectedViolations) {
            if (thisViolation.IETRS_Inspection__c != thisInspectionId) {
                varViolationCounter = 1;
                thisInspectionId = thisViolation.IETRS_Inspection__c;
            }
            thisViolation.IETRS_Violation_Num__c = varViolationCounter;
            system.debug(thisViolation.IETRS_Violation_Num__c + ' : ' + varViolationCounter);
            varViolationCounter++;
        }

        if (allAffectedViolations.size() > 0) {
            update allAffectedViolations;
        }
    }

    if (!lstTask.isEmpty()) {
        insert lstTask;
    }

}