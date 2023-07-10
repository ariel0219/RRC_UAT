/**
 * @File Name          : EmailHandlerActionTest.trigger
 * @Description        : 
 * @Author             : Ronald Stewart
 * @Group              : 
 * @Last Modified By   : Ronald Stewart
 * @Last Modified On   : 12/10/2020
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author                    Modification
 *==============================================================================
 * 1.0        12/10/2020               Ronald Stewart             Initial Version
**/
@isTest
public class EmailHandlerActionTest {
	@isTest
    public static void testSendEmailToParties(){
        List<List<String>> emailInfoList = new List<List<String>>();
        List<String> emailInfo = new List<String>{'ronald.stewart@rrc.texas.gov','Test Subject','Test Body'};           
        emailInfoList.add(emailInfo);
        
        Test.startTest();
        EmailHandlerAction.sendEmailToParties(emailInfoList);
        Test.stopTest();
    }
}