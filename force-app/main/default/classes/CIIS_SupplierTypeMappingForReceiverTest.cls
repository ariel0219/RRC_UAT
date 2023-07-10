@isTest
public class CIIS_SupplierTypeMappingForReceiverTest {
    static testMethod void testGetSupplerType(){
        try{
            String receiverType='Pipeline';
            List<String> supplerTypeList = CIIS_SupplierTypeMappingForReceiver.getSupplerType(receiverType);
            System.debug('supplerTypeList:'+supplerTypeList);
            
        }catch(Exception e){
            System.debug('Exception :'+e);
        }
    }
    
    static testMethod void testGetSupplerTypeError(){
        try{
            String receiverType='XYZ';
            List<String> supplerTypeList = CIIS_SupplierTypeMappingForReceiver.getSupplerType(receiverType);
            System.debug('supplerTypeList:'+supplerTypeList);
            
        }catch(Exception e){
            System.debug('Exception :'+e);
        }
    }
    
}