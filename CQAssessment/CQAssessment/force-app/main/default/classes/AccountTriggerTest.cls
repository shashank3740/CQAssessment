@isTest
public class AccountTriggerTest {
    @testSetUp
    Static void testSetup()
    {
        Profile p = [select id from profile where name='System Administrator'];
        Account acc = new Account(Name='Test Account', Type='Customer', Active__c=false);
        insert acc;
        User u = new User(
            alias = 'esk',
            email='test@email.com',
            emailencodingkey='UTF-8',
            lastname='User',
            languagelocalekey='en_US',
            localesidkey='en_GB',
            profileid = p.Id,
            timezonesidkey='Europe/London',
            username='testuhh1@gmail.com'
        );
        insert u;
    }
    @isTest
    static void afterInsertNoSummary() {
            Account acc = new Account(Name='Test Account 1', Type='Customer', Active__c=true);
            Test.startTest();
        	Database.SaveResult result = Database.insert(acc, false);
            Test.stopTest();
            System.assert(!result.isSuccess());
            System.assertEquals(Label.ErrorMessage, result.getErrors()[0].getMessage());
        }
    @isTest
    static void afterInsertCreateContact() {
        Account acc = new Account(Name='Test Account 2', Type='Customer', Active__c=true, Account_Activation_Summary__c='Test Summary');
        Test.startTest();
        insert acc;
        Test.stopTest();
        List<Contact> Contacts = [SELECT Id FROM Contact WHERE AccountId = :acc.Id];
        System.assertEquals(1, Contacts.size());
    }
    @isTest
    static void afterUpdateCreateContact() {
        Account acc = [SELECT Id,Active__c,Account_Activation_Summary__c FROM Account WHERE Name = 'Test Account'][0];
        acc.Active__c = true;
        acc.Account_Activation_Summary__c='Test Summary';
        Test.startTest();
        update acc;
        Test.stopTest();
        List<Contact> Contacts = [SELECT Id FROM Contact WHERE AccountId = :acc.Id];
        System.assertEquals(1, Contacts.size());
    }
    @isTest
    static void nonAccountManagerUser()
    {
        User u = [SELECT id FROM User WHERE username = 'testuhh1@gmail.com'];
        Test.startTest();
        System.runAs(u){
            Account acc = [SELECT Id,Active__c,Account_Activation_Summary__c FROM Account WHERE Name = 'Test Account'][0];
            acc.Active__c = true;
            acc.Account_Activation_Summary__c='Test Summary';
            Database.SaveResult result = Database.update(acc, false);
            System.assert(!result.isSuccess());
            System.assertEquals('Only Account Manager can edit/create the account', result.getErrors()[0].getMessage());
        }
        Test.stopTest();
    }
}