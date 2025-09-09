@isTest
private class SObjectDeepCloneTests {

    //TODO: khp fix unittest
    // @isTest static void accountWithContacts() {
    //     Account acc = TDF_AccountUtils.creatActiveAccountWithCVRAndOwner();
    //     insert acc;

    //     Map<String, Contact> contactsByName = new Map<String,Contact>();
    //     for(Integer i = 0; i < 5; i++){
    //         Contact c = createContact(acc.Id, 'Contact' +i, String.valueOf(i), i);
    //         contactsByName.put(String.valueOf(i), c);
    //     }

    //     insert contactsByName.values();

    //     //pass opportunities just to test query gen on multiple children
    //     SObjectDeepClone cloner = new SObjectDeepClone(acc.Id, new Set<String>{'contacts', 'opportunities'},true);
    //     String cloneName = acc.name;
    //     Account toBeCloned = (Account) cloner.clone;
    //     toBeCloned.Name = cloneName;   //change name
    //     Id clonedId = cloner.save();
    //     System.assertNotEquals(null, clonedId);
    //     System.assertNotEquals(acc.Id, clonedId);

    //     Account queriedClonedAccount = [SELECT Name, (SELECT FirstName, LastName FROM Contacts) FROM Account WHERE Id = :clonedId];

    //     System.assertEquals(true,queriedClonedAccount.Name.contains(cloneName));
    //     System.assertEquals(contactsByName.size(), queriedClonedAccount.Contacts.size());
    //     for(contact c : queriedClonedAccount.Contacts){
    //         Contact orgContact = contactsByName.get(c.LastName);
    //         System.assertNotEquals(null, orgContact);
    //     }
    // }

    // private static Contact createContact(Id accId, String firstName, String lastName, Integer seed){
    //     return new Contact(
    //             AccountId = accId,
    //             FirstName = firstName + seed,
    //             LastName = lastName + seed,
    //             Email = 'kk'  + seed + '@kk.dk'
    //     );
    // }
}