//Controller by Jessie Rymph included with unmanaged package Unsubscribe Link from AppExchange & Salesforce Labs.
//The Unsubscribe Link Flow ends on Visualforce page jrsl_ul_UnsubscribeFinish that says 'Thank you. You have successfully unsubscribed. You will receive a confirmation email shortly.'
//or it says 'Thank you. You have successfully unsubscribed.'
//The controller tells the visualforce page to display the last sentence by looking at the Custom Metadata Type Unsubscribe Link where the user sets their preference.
//jrsl_ul_TestContext is used to test custom metadata type.
// The page will display an error if an Unsubscribe link mdt record cannot be found.
//June 15, 2021

public with sharing class jrsl_ul_UnsubscribeController {  
    private final jrsl_ul_Unsubscribe_Link__mdt uLmDt;  
    public string displayText {get; set;}
    public boolean booly;
    
    public jrsl_ul_UnsubscribeController(){
        
        //query for the unsubscribe link custom metadata type with a blank TestCase.
        try{
        uLmDt = [SELECT jrsl_ul_Send_Confirmation_Email__c,Test_Case__c
                 FROM jrsl_ul_Unsubscribe_Link__mdt 
                 WHERE Test_Case__c = :jrsl_ul_TestContext.testCase];
        
        if (uLmDt.jrsl_ul_Send_Confirmation_Email__c=='Yes')
        {
            booly = true;
            displayText ='Thank you. You have successfully unsubscribed. You will receive a confirmation email shortly.';
            system.debug('The confirmation email is turned on.');
        }
        
       //if the Send confirmation email field is set to no or none, include no additional text on the VF page. 
        else 
            
        {booly=false;
            displayText = 'Thank you. You have successfully unsubscribed.';
         system.debug('The confirmation email is turned off.');
        }
        
        }
        catch(Exception e) {
                System.debug('The cmdt jrsl_ul_Unsubscribe_Link__mdt is missing a record whose masterlabel is Unsubscribe. Here is the error:' + e.getMessage());
        		displayText= 'ERROR: There is an error with the Unsubscribe Link package. The Custom Metadata Type jrsl_ul_Unsubscribe_Link__mdt is missing a record whose Test_Case__c is null.';    
        
        }
    }
}