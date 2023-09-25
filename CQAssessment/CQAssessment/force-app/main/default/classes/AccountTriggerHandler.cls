public class AccountTriggerHandler {
    
	public static void afterInsert(List<Account> newAccList)
    {
        List<Account> accList = new List<Account>();
        for(Account acc : newAccList)
        {
            
            //Check for Account Activation Summary Filed 
            if(acc.type == 'Customer' && acc.Active__c==true && acc.Account_Activation_Summary__c == null)
            {
                acc.addError(label.ErrorMessage);
            }
            if(acc.type == 'Customer' && acc.Active__c==true && acc.Account_Activation_Summary__c != null)
            {
                accList.add(acc);
            }
            
        }
        if(!accList.isEmpty())
        {
            createContactRecord(accList);
        }
    }
    public static void afterUpdate(List<Account> newAccList,Map<id, Account> oldAccountMap)
    {
        List<Account> accList = new List<Account>();
        for(Account acc : newAccList)
        {
            //Check for Account Activation Summary Filed 
            if(acc.type == 'Customer' && acc.Active__c==true && acc.Account_Activation_Summary__c == null)
            {
                acc.addError(label.ErrorMessage);
            }
            if(acc.type == 'Customer' && (oldAccountMap.get(acc.Id).Active__c!=acc.Active__c && acc.Active__c==true) && acc.Account_Activation_Summary__c != null)
            {
                accList.add(acc);
            }
        }
        
        if(!accList.isEmpty())
        {
            createContactRecord(accList);
        }
    }
    //generic contact creation Method
    public static void createContactRecord(List<Account> accList)
    {
        List<Contact> contactsToInsert = new List<Contact>();
        for(Account accRec : accList)
        {
            Contact contactRec = new Contact();
            contactRec.AccountId = accRec.Id;
            contactRec.FirstName = accRec.Name;
            contactRec.LastName = 'Customer Representative';
            contactRec.Email = accRec.Company_Email__c;
            contactRec.Phone = accRec.Phone;
            contactsToInsert.add(contactRec);
        }
        if(!contactsToInsert.isEmpty())
        {
            Database.insert(contactsToInsert,false);
        }
    }
}