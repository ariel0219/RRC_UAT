/**
 * @description       :
 * @author            : cmckee@sensecorp.com
 * @group             :
 * @last modified on  : 07-08-2020
 * @last modified by  : cmckee@sensecorp.com
 * Modifications Log
 * Ver   Date         Author                 Modification
 * 1.0   07-07-2020   cmckee@sensecorp.com   Initial Version
 *
 * IETRS_Task_UpdateWhatsId batchJob = new IETRS_Task_UpdateWhatsId();
 * ID jobID = Database.executeBatch(batchJob,200);
 *
 **/
global class IETRS_Task_UpdateWhatsId implements Database.Batchable<sObject>{
	global final String Query = 'Select ' + 
									'Event_ID_External__c' + 
									',IETRS_Primary_Account__c' + 
									',IETRS_Weekly_Work_Report__c' + 
									',IETRS_Inspection_Package__c' + 
									',IETRS_Incident__c ' + 
								'From Task ' + 
								'Where Event_ID_External__c != null and WhatId = null';
	global IETRS_Task_UpdateWhatsId(){
		System.debug('IETRS_Task_UpdateWhatsId: Constructer');
	}

	global Database.QueryLocator start(Database.BatchableContext BC){
		System.debug('IETRS_Task_UpdateWhatsId: Start');
		System.debug(Query);
		return Database.getQueryLocator(Query);
	}

	global void execute(Database.BatchableContext BC, List<Task> scope){
		System.debug('IETRS_Task_UpdateWhatsId: Excute');
		List<Task> taskToUpdate = new List<Task>();
		for (Task t : scope){
			String taskType = t.Event_ID_External__c.substringBefore('-');
			switch on taskType{

				when 'SYSTEM', 'ORG', 'UNIT'{
					System.debug('SYSTEM, ORG, UNIT');
					t.WhatId = t.IETRS_Primary_Account__c;
					taskToUpdate.add(t);
				}
				when 'WEEKLY_REPORT'{
					System.debug('WEEKLY_REPORT');
					t.WhatId = t.IETRS_Weekly_Work_Report__c;
					taskToUpdate.add(t);
				}
				when 'IP'{
					System.debug('IP');
					t.WhatId = t.IETRS_Inspection_Package__c;
					taskToUpdate.add(t);
				}
				when 'INCIDENT'{
					System.debug('INCIDENT');
					t.WhatId = t.IETRS_Incident__c;
					taskToUpdate.add(t);
				}
			}
		}
		update taskToUpdate;
	}

	global void finish(Database.BatchableContext BC){
		System.debug('IETRS_Task_UpdateWhatsId: Finish');
	}
}