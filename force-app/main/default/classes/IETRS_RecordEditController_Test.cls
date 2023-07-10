/**
 * @File Name          : IETRS_RecordEditController_Test.cls
 * @Description        :
 * @Author             : Mark Frizzell
 * @Group              :
 * @Last Modified By   : Mark Frizzell
 * @Last Modified On   : 8/21/2019, 2:04:00 AM
 * @Modification Log   :
 *==============================================================================
 * Ver         Date                     Author      		      Modification
 *==============================================================================
 * 1.0    8/2/2019, 4:36:14 PM   Mark Frizzell     Initial Version
 **/
@IsTest
private class IETRS_RecordEditController_Test {
    @IsTest
    static void testLoadPageLayoutFields() {
        Case testCase = new Case();
        insert testCase;

        Test.startTest();
        List<IETRS_RecordEditController.LayoutSection> results1 = IETRS_RecordEditController.loadPageLayoutFields(
            testCase.Id,
            null,
            null
        );
        List<IETRS_RecordEditController.LayoutSection> results2 = IETRS_RecordEditController.loadPageLayoutFields(
            null,
            null,
            'Case'
        );
        Test.stopTest();
        // System.assert(results1.size() > 0);
        // System.assert(results2.size() > 0);
    }
}