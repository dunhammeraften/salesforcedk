//test by Jessie Rymph included with unmanaged package Unsubscribe Link from AppExchange & Salesforce Labs.
// June 15, 2021
// This test is based on these instructions for working with Custom Metadatatypes in Test.
// https://developer.salesforce.com/blogs/engineering/2015/05/testing-custom-metadata-types.html

@isTest
public class jrsl_ul_UnsubscribeControllerTest {
    
    @isTest public static void testTheRealRecord () {
        //set the value of our variable testcase
        jrsl_ul_TestContext.testcase='';
        //This test looks at the Unsubscribe actual record to see if the whole process will work.
        //For the real record, the test case field is blank.
        Test.startTest();
        system.debug('If the test fails with the error "List has no rows for assignment to SObject", then you are missing a Custom Metadatatype of Unsubscribe Link with Test_Case__c="". This is for the unmanaged package Unsubscribe Link.');       
        //instantiate the controller
        jrsl_ul_UnsubscribeController controller = new jrsl_ul_UnsubscribeController();
        if(controller.booly==true)
        {system.assertEquals('Thank you. You have successfully unsubscribed. You will receive a confirmation email shortly.',
                             controller.displayText);
         system.debug('The unsubscribe cmdt is set to yes, send the email. So the visualforce page says you will receive a confirmation email shortly');
        }    
        else if (controller.booly==false)
            //If the boolean is set to false, do not mention the email.
        {system.assertEquals('Thank you. You have successfully unsubscribed.',
                             controller.displayText);
         system.debug('The unsubscribe cmdt is set to no, do not send the email. So no text appears about the email.');} 
        else 
            //Otherwise, display an error to show that the Unsubscribe Link mdt is missing.
        {system.assertEquals('ERROR: There is an error with the Unsubscribe Link package. The Custom Metadata Type jrsl_ul_Unsubscribe_Link__mdt is missing a record whose Test_Case__c is null.',
                             controller.displayText);}
        
        test.stopTest();
    }
    
    @isTest public static void testMyController1 () {
        //This test is for a scenario in which we do want to send the confirmation email.
        jrsl_ul_TestContext.testcase='Yes';
        Test.startTest();
        system.debug('If the test fails with the error "List has no rows for assignment to SObject", then you are missing a Custom Metadatatype of Unsubscribe Link with Test_Case__c = " ". This is for the unmanaged package Unsubscribe Link.');   
        //instantiate the controller
        jrsl_ul_UnsubscribeController controller = new jrsl_ul_UnsubscribeController();
        Test.stopTest();
        
        system.assertEquals('Thank you. You have successfully unsubscribed. You will receive a confirmation email shortly.',
                            controller.displayText);
        system.debug('The unsubscribe cmdt is set to yes, send the email. So the visualforce page says you will receive a confirmation email shortly');
        
        
        
    }
    @isTest public static void testMyController2 () {
        jrsl_ul_TestContext.testcase='No';
        
        Test.startTest();
        //instantiate the controller
        jrsl_ul_UnsubscribeController controller = new jrsl_ul_UnsubscribeController();
        Test.stopTest();
        system.assertEquals('Thank you. You have successfully unsubscribed.',
                            controller.displayText);
        system.debug('The unsubscribe cmdt is set to no, do not send the email. So no text appears about the email.');
        
    }
    @isTest public static void testMyController3 () {
        jrsl_ul_TestContext.testcase='None';
        
        Test.startTest();
        //instantiate the controller
        jrsl_ul_UnsubscribeController controller = new jrsl_ul_UnsubscribeController();
        Test.stopTest();
        system.assertEquals('Thank you. You have successfully unsubscribed.',
                            controller.displayText);
        system.debug('The unsubscribe cmdt is set to none, do not send the email. So no text appears about the email.');
        
    } 
    @isTest public static void testMyController4 () {
        jrsl_ul_TestContext.testcase='Fake';
        
        Test.startTest();
        //instantiate the controller
        jrsl_ul_UnsubscribeController controller = new jrsl_ul_UnsubscribeController();
        Test.stopTest();
        system.assertEquals('ERROR: There is an error with the Unsubscribe Link package. The Custom Metadata Type jrsl_ul_Unsubscribe_Link__mdt is missing a record whose Test_Case__c is null.',
                            controller.displayText);
        system.debug('An error was expected and returned.');
        
    } 
}