/**
 * @author Greg Lovelidge - Sense Corp
 * @date 5/29/2020
 *
 * @description Schedulable class. Runs daily to check if current date is the late fee date.
 */
global with sharing class IETRS_I_LateFeesSchedulable implements Schedulable {
    global void execute(SchedulableContext SC) {
        new IETRS_I_LateFees(Date.today());
    }
}