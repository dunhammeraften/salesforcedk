/**
 *
 * @author Frederik
 *
 * @author Mujahid (qet9252)
 * @description QueueablePOQ will get the available opportunites and chunk teh address in to default 50 records chunks and send to POQ API, which will then validate the information provided.
 */
public without sharing class QueueablePOQ implements Queueable, Database.AllowsCallouts {
	private List<List<Location_Line__c>> listOfLocationLineListsToCallout;
	private List<Location_Line__c> theLines; // quick fix because VS code was confused
	private List<System_Log__c> errorsList = new List<System_Log__c>();
	private final String ERROR_FIELDS = ' Fields that affected this error: ';
	private final String QUEUEABLE_ERROR = 'QueueablePOQ Error : ';
	private final String ERROR_ADDITIONAL_INFO = 'QueueablePOQ';
	private final String ERROR_ORIGIN = 'Apex';
	// reference here: https://salesforce.stackexchange.com/a/181235/78049
	@TestVisible
	private static Boolean doChainJob = true;

	// Constructor
	public QueueablePOQ(List<String> qualifyingOpportunityIds) {
		List<List<Location_Line__c>> lineChunks = new List<List<Location_Line__c>>();
		List<Location_Line__c> currentChunk = new List<Location_Line__c>();
		List<Location_Line__c> locationLines = new List<Location_Line__c>();
		POQ_batch_chunks__c batchChunks = POQ_batch_chunks__c.getOrgDefaults();

		Integer chunkSize = Test.isRunningTest() ? 1 : batchChunks.Full_Qualification_Batch_Size__c.intValue();

		for (Location_Line__c line : [
			SELECT
				Id,
				Name,
				addressWash_Category__c,
				ZIP_Code__c,
				City__c,
				Door__c,
				Number__c,
				Floor__c,
				Street_Name__c,
				Employee_ID__c,
				Address__c,
				Subscription_product__c,
				OTC_product__c,
				VAS_product__c,
				Opportunity__c,
				Address_ID__c,
				POQ_Item_Created__c,
				Address_Wash_Status__c,
				Street_Code__c,
				Municipality_Code__c,
				POQ_ProductOfferingQualificationItemId__c,
				POQ_ProductOfferingId__c
			FROM Location_Line__c
			WHERE Opportunity__c IN :qualifyingOpportunityIds
			ORDER BY Id
		]) {
			if (currentChunk.size() < chunkSize) {
				currentChunk.add(line);
			} else {
				lineChunks.add(currentChunk);
				currentChunk = new List<Location_Line__c>{ line };
			}
			locationLines.add(line);
		}

		if (!currentChunk.isEmpty()) {
			lineChunks.add(currentChunk);
		}
		this.theLines = locationLines;
		this.listOfLocationLineListsToCallout = lineChunks;
	}

	public void execute(QueueableContext context) {
		Set<String> oppIds = new Set<String>();
		for (Location_Line__c line : this.theLines) {
			oppIds.add(line.Opportunity__c);
		}
		System.debug('oppIds in QueablePOQ = ' + oppIds);

		Integer sentCount = 0;
		Boolean hitLimit = false;
		System.debug('start execute');
		// Process as many as possible in this transaction, based on limits
		for (List<Location_Line__c> lines : listOfLocationLineListsToCallout) {
			// String failMsg = '';

			if (sentCount == 1) {
				hitLimit = true;
				break;
			}

			// Do your callout
			List<List<Location_Line__c>> outerLines = new List<List<Location_Line__c>>();
			outerLines.add(lines);

			// The call to product offering qualification which will make the second poq call. The exceptions will be handle in the main method itself.
			ProductOfferingQualification.main(outerLines, true);

			if ((listOfLocationLineListsToCallout.size() == 1)) {
				List<Opportunity> oppsToUpdate = new List<Opportunity>();
				for (Opportunity opp : [SELECT POQ_Status__c FROM Opportunity WHERE Id IN :oppIds]) {
					opp.POQ_Status__c = 'Done';
					oppsToUpdate.add(opp);
				}
				if (!system.isFuture() && !system.isBatch()) {
					Database.SaveResult[] oppsUpdateResult = Database.update(oppsToUpdate, false);
					for (Database.SaveResult sr : oppsUpdateResult) {
						if (!sr.isSuccess()) {
							for (Database.Error err : sr.getErrors()) {
								String errorMsg =
									this.QUEUEABLE_ERROR +
									err.getStatusCode() +
									': ' +
									err.getMessage() +
									', ' +
									this.ERROR_FIELDS +
									err.getFields();
								this.errorsList.add(createErrorLog(errorMsg));
							}
						}
					}
				}
				if (this.errorsList.size() > 0) {
					insert this.errorsList;
				}
			}
			// Track how many have been processed
			sentCount++;
		}

		if (hitLimit) {
			System.debug('hitLimit !!!');
			// Need to chain this queueable to finish processing. First clean up
			// the list of leads needing a callout, removing all those that have
			// been sent already
			for (Integer index = 0; index < sentCount; index++) {
				listOfLocationLineListsToCallout.remove(0);
			}

			// Now ensure the remainder get processed by simply re-enqueuing this
			// queueable with its adjusted state
			if (doChainJob) {
				System.enqueueJob(this);
			}
		}
	}

	@TestVisible
	private System_Log__c createErrorLog(String errorMsg) {
        System.debug('errorMsg = ' + errorMsg);
		System_Log__c errorLog = new System_Log__c(
			Origin__c = this.ERROR_ORIGIN,
			Error_Body__c = errorMsg,
			Additional_Information__c = this.ERROR_ADDITIONAL_INFO
		);
		return errorLog;
	}

	public class queueablePOQexception extends Exception {
	}
}