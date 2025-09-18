/**
 * @description Provides a fluent builder pattern for creating complex, reusable test data scenarios.
 *              This utility is the preferred method for creating test data for new unit tests,
 *              as it centralizes data creation logic and ensures consistency.
 *              It replaces the need for older TDF_ (Test Data Factory) utilities.
 *
 * @group SUnit
 *
 * @example
 * // Basic usage to create a full sales-to-fulfillment scenario
 * NorlysTestScenarios.ScenarioResult scenario = NorlysTestScenarios.newBuilder()
 *     .withCvr('11223344')
 *     .withProducts(3)
 *     .build();
 * // You can now access all created records from the `scenario` variable, e.g., scenario.account, scenario.quoteLines
 */
@isTest
public class NorlysTestScenarios {

    /**
     * @description Custom exception for the test scenarios framework.
     *              Thrown when the builder is configured in an invalid way.
     */
    public class NorlysTestScenariosException extends Exception {}

    /**
     * @description A container for all the records created by a scenario build.
     *              An instance of this class is the return value of the `build()` method,
     *              providing easy access to any record created during the scenario setup.
     */
    public class ScenarioResult {
        /** @description The running User for the test context. */
        public User owner;
        /** @description The primary Account record. */
        public Account account;
        /** @description The primary Opportunity record, linked to the Account. */
        public Opportunity opportunity;
        /** @description The primary Case record, linked to the Account and Opportunity. */
        public Case caseRecord;
        /** @description The primary SBQQ__Quote__c record, linked to the Opportunity. */
        public SBQQ__Quote__c quote;
        /** @description A list of all Product2 records created. */
        public List<Product2> products;
        /** @description A list of all PricebookEntry records created. */
        public List<PricebookEntry> pricebookEntries;
        /** @description A list of all SBQQ__QuoteLine__c records created. */
        public List<SBQQ__QuoteLine__c> quoteLines;
        /** @description A list of all Activation__c records created. */
        public List<Activation__c> activations;
        /** @description A list of all Activation_Line__c records created. */
        public List<Activation_Line__c> activationLines;
        /** @description A reference to the primary quote, useful for activation-related scenarios. */
        public SBQQ__Quote__c activationQuote;
        /** @description A list of all Account_Phone_Number_Assignment__c records created. */
        public List<Account_Phone_Number_Assignment__c> phoneNumberAssignments;
        /** @description A list of all Activation_Assignment_Junction__c records created. */
        public List<Activation_Assignment_Junction__c> activationAssignmentJunctions;
        /** @description A list of product features created when using the advanced bundle scenario. */
        public List<SBQQ__ProductFeature__c> productFeatures;
        /** @description A list of product options created when using the advanced bundle scenario. */
        public List<SBQQ__ProductOption__c> productOptions;
        /** @description The primary Contract record created when using `withContractAndSubscription`. */
        public Contract contract;
        /** @description A list of all SBQQ__Subscription__c records created. */
        public List<SBQQ__Subscription__c> subscriptions;
        /** @description A list of all NorlysNow_Case__c records created. */
        public List<NorlysNow_Case__c> norlysNowCases;
        /** @description A list of all FeedItem records created. */
        public List<FeedItem> feedItems;
        /** @description A list of all ContentDocumentLink records created. */
        public List<ContentDocumentLink> contentDocumentLinks;
    }

    /**
     * @description A configuration object to define a phone number series and its assignments.
     *              Used internally by the ScenarioBuilder to manage the creation of phone number-related records.
     */
    public class SeriesConfig {
        public String location;
        public String numberGroup;
        public Integer assignmentCount;
        public Integer junctionCount;
        public SeriesConfig(String location, String numberGroup, Integer assignmentCount, Integer junctionCount) {
            this.location = location;
            this.numberGroup = numberGroup;
            this.assignmentCount = assignmentCount;
            this.junctionCount = junctionCount;
        }
    }

    /**
     * @description A fluent builder for creating complex test data scenarios.
     *              Chain `with...` methods to configure the scenario, and then call `build()` to create the records.
     *              This is the main entry point for using the framework.
     */
    public class ScenarioBuilder {
        // Configuration properties for the scenario
        private Integer numProducts = 1;
        private Integer numNoActionProducts = 0;
        private String cvr = '12345678';
        private Boolean createCaseAndActivations = true;
        private String phoneNumberStatus;
        private String phoneNoStatusOnActivationLine;
        private List<SeriesConfig> seriesConfigs = new List<SeriesConfig>();
        private String mobileNumber;
        private Boolean buildForNumberHandlingOnly = false;
        private Integer numActivationLines = 0;
        private List<Integer> activationLineCounts = new List<Integer>();
        private Integer numActivations = 1;
        private Integer numFeatures = 0;
        private Integer numOptions = 0;
        private String caseRootBan;
        private Boolean customerHasTouchpoint;
        private Decimal quoteLineDiscount;
        private Boolean createFokusCampaignAndDiscount = false;
        private Map<String, Object> activationLineCustomizations;
        private Boolean createQuoteLineDetails = false;
        private Boolean createContractAndSubscription = false;
        private Boolean createStandardVoiceAndHomeOffice = false;
        private List<Product2> customProducts = new List<Product2>();
        private List<Integer> customProductQuantities = new List<Integer>();
        private Boolean buildForNorlysNowCaseHandling = false;
        private Integer numNorlysNowCases = 0;
        private Integer numFeedItems = 0;
        private Integer numFilesToAttach = 0;

        /**
         * @description Sets the number of files to attach to the generated NorlysNow_Case__c.
         *              This method is intended to be used with `forNorlysNowCaseHandling`.
         *              The files will be attached to the first NorlysNow_Case__c created.
         * @param count The number of files to create and attach.
         * @return The ScenarioBuilder instance for chaining.
         */
        public ScenarioBuilder withAttachedFiles(Integer count) {
            this.numFilesToAttach = count;
            return this;
        }

        /**
         * @description Sets the number of FeedItem records to create.
         *              This method is intended to be used with `forNorlysNowCaseHandling`.
         * @param count The number of FeedItem records to create.
         * @return The ScenarioBuilder instance for chaining.
         */
        public ScenarioBuilder withFeedItems(Integer count) {
            this.numFeedItems = count;
            return this;
        }

        /**
         * @description Configures the builder to create a lightweight scenario for NorlysNow Case handling.
         *              This creates a parent Case and a specified number of child NorlysNow_Case__c records.
         * @return The ScenarioBuilder instance for chaining.
         */
        public ScenarioBuilder forNorlysNowCaseHandling() {
            this.buildForNorlysNowCaseHandling = true;
            this.createCaseAndActivations = false; // Ensure we don't build the other heavy scenarios
            return this;
        }

        /**
         * @description Sets the number of NorlysNow_Case__c records to create.
         *              This method is intended to be used with `forNorlysNowCaseHandling`.
         * @param count The number of NorlysNow_Case__c records to create.
         * @return The ScenarioBuilder instance for chaining.
         */
        public ScenarioBuilder withNorlysNowCases(Integer count) {
            this.numNorlysNowCases = count;
            return this;
        }

        /**
         * @description Provides a custom Product2 record to be used in the scenario.
         *              This allows for testing with specific product configurations that are not
         *              covered by the standard builder options. The provided product will be
         *              inserted and a corresponding Quote Line will be created.
         * @param customProduct The Product2 record to use. It should have all required fields set.
         * @param quantity The quantity for the corresponding quote line. Defaults to 1.
         * @return The ScenarioBuilder instance for chaining.
         */
        public ScenarioBuilder withCustomProduct(Product2 customProduct, Integer quantity) {
            this.customProducts.add(customProduct);
            this.customProductQuantities.add(quantity);
            return this;
        }

        /**
         * @description Overloaded method for `withCustomProduct` that defaults the quantity to 1.
         * @param customProduct The Product2 record to use.
         * @return The ScenarioBuilder instance for chaining.
         */
        public ScenarioBuilder withCustomProduct(Product2 customProduct) {
            return withCustomProduct(customProduct, 1);
        }

        /**
         * @description Creates a standard set of one 'Voice' and one 'Home office' product,
         *              and links them to the first two quote lines of the scenario.
         *              This is a convenience method for a common test data pattern.
         * @return The ScenarioBuilder instance for chaining.
         */
        public ScenarioBuilder withStandardVoiceAndHomeOfficeProducts() {
            this.createStandardVoiceAndHomeOffice = true;
            return this;
        }

        /**
         * @description Instructs the builder to create a Contract and corresponding Subscriptions
         *              for the generated Quote Lines. This is useful for testing amendment and renewal scenarios.
         * @return The ScenarioBuilder instance for chaining.
         */
        public ScenarioBuilder withContractAndSubscription() {
            this.createContractAndSubscription = true;
            return this;
        }

        /**
         * @description Instructs the builder to create a `Quote_Line_Detail__c` for each generated `SBQQ__QuoteLine__c`.
         * @return The ScenarioBuilder instance for chaining.
         */
        public ScenarioBuilder withQuoteLineDetails() {
            this.createQuoteLineDetails = true;
            return this;
        }

        /**
         * @description Sets the `Root_BAN__c` field on the generated `Case` record.
         * @param ban The BAN to set on the Case.
         * @return The ScenarioBuilder instance for chaining.
         */
        public ScenarioBuilder withCaseRootBan(String ban) {
            this.caseRootBan = ban;
            return this;
        }

        /**
         * @description Sets the `Customer_has_Touchpoint__c` field on the generated `Account` record.
         * @param hasTouchpoint The boolean value to set.
         * @return The ScenarioBuilder instance for chaining.
         */
        public ScenarioBuilder withCustomerHasTouchpoint(Boolean hasTouchpoint) {
            this.customerHasTouchpoint = hasTouchpoint;
            return this;
        }

        /**
         * @description Applies a discount to all generated `SBQQ__QuoteLine__c` records.
         * @param discount The discount percentage to apply.
         * @return The ScenarioBuilder instance for chaining.
         */
        public ScenarioBuilder withQuoteLineDiscount(Decimal discount) {
            this.quoteLineDiscount = discount;
            return this;
        }

        /**
         * @description Instructs the builder to create related `Fokus_Campaign__c` and `Fokus_Discount__c` records.
         * @return The ScenarioBuilder instance for chaining.
         */
        public ScenarioBuilder withFokusCampaignAndDiscount() {
            this.createFokusCampaignAndDiscount = true;
            return this;
        }

        /**
         * @description Applies a map of custom field values to the first generated `Activation_Line__c`.
         *              This is useful for setting many specific fields required for a particular test.
         * @param customizations A map where the key is the field API name and the value is the value to set.
         * @return The ScenarioBuilder instance for chaining.
         */
        public ScenarioBuilder withActivationLineCustomizations(Map<String, Object> customizations) {
            this.activationLineCustomizations = customizations;
            return this;
        }

        /**
         * @description Sets the number of activations to create in a lightweight scenario.
         *              This method is intended to be used with `forNumberCaseHandling`.
         * @param count The number of activations to create.
         * @return The ScenarioBuilder instance for chaining.
         */
        public ScenarioBuilder withActivations(Integer count) {
            this.numActivations = count;
            return this;
        }

        /**
         * @description Sets the number of Activation_Line__c records to create for each activation, based on a list of counts.
         *              This method is intended to be used with `forNumberCaseHandling`.
         * @param counts A list of integers, where each integer is the number of lines for the corresponding activation.
         * @return The ScenarioBuilder instance for chaining.
         */
        public ScenarioBuilder withActivationLines(List<Integer> counts) {
            this.activationLineCounts = counts;
            return this;
        }

        /**
         * @description Sets the number of product features to create for the primary product.
         *              This enables the "Advanced (Bundle)" scenario type.
         * @param count The number of features.
         * @return The ScenarioBuilder instance for chaining.
         * @example .withProductFeatures(1)
         */
        public ScenarioBuilder withProductFeatures(Integer count) {
            this.numFeatures = count;
            return this;
        }

        /**
         * @description Sets the number of product options to create for the primary product.
         *              Requires `withProductFeatures` to also be called. The created options will be linked to the first feature.
         * @param count The number of options.
         * @return The ScenarioBuilder instance for chaining.
         * @example .withProductFeatures(1).withProductOptions(1)
         */
        public ScenarioBuilder withProductOptions(Integer count) {
            this.numOptions = count;
            return this;
        }

        /**
         * @description Configures the builder to create a lightweight scenario, skipping heavy CPQ objects.
         *              This is ideal for tests that only need to operate on Cases, Activations, and related number handling objects.
         * @return The ScenarioBuilder instance for chaining.
         * @example
         *  NorlysTestScenarios.newBuilder()
         *      .forNumberCaseHandling()
         *      .withActivationLines(5)
         *      .build();
         */
        public ScenarioBuilder forNumberCaseHandling() {
            this.buildForNumberHandlingOnly = true;
            this.createCaseAndActivations = true; // Ensure case and activations are created
            return this;
        }

        /**
         * @description Sets the number of Activation_Line__c records to create in a lightweight scenario.
         *              This method is intended to be used with `forNumberCaseHandling`.
         * @param count The number of activation lines to create.
         * @return The ScenarioBuilder instance for chaining.
         */
        public ScenarioBuilder withActivationLines(Integer count) {
            this.numActivationLines = count;
            return this;
        }

        /**
         * @description Sets the Mobile_No__c for the created Activation_Line__c records.
         * @param mobileNumber The mobile number to set.
         * @return The ScenarioBuilder instance for chaining.
         * @example .withActivationLineMobileNumber('11223344')
         */
        public ScenarioBuilder withActivationLineMobileNumber(String mobileNumber) {
            this.mobileNumber = mobileNumber;
            return this;
        }

        /**
         * @description Sets the phone_no_status__c for the created Activation_Line__c records.
         * @param status The status to set.
         * @return The ScenarioBuilder instance for chaining.
         * @example .withPhoneNoStatusOnActivationLine('Nyt nummer')
         */
        public ScenarioBuilder withPhoneNoStatusOnActivationLine(String status) {
            this.phoneNoStatusOnActivationLine = status;
            return this;
        }

        /**
         * @description A convenience method to create an equal number of products and phone number assignments.
         *              This will create one default phone number series with no "in-use" numbers (junctions).
         * @param count The number of products and assignments to create.
         * @return The ScenarioBuilder instance for chaining.
         * @example .withProductsAndAssignments(5)
         */
        public ScenarioBuilder withProductsAndAssignments(Integer count) {
            this.numProducts = count;
            if (seriesConfigs.isEmpty()) {
                seriesConfigs.add(new SeriesConfig('BRZ', 'P', count, 0));
            } else {
                seriesConfigs[0].assignmentCount = count;
            }
            return this;
        }

        /**
         * @description (Deprecated) Use withNumberSeries instead.
         */
        public ScenarioBuilder withNumberSeriesLocation(String location) {
            return this;
        }

        /**
         * @description (Deprecated) Use withNumberSeries instead.
         */
        public ScenarioBuilder withNumberGroup(String numberGroup) {
            return this;
        }

        /**
         * @description Sets the CTN_Number_Status__c for all created Account_Phone_Number_Assignment__c records.
         * @param status The status to set, e.g., 'AR'.
         * @return The ScenarioBuilder instance for chaining.
         * @example .withPhoneNumberStatus('AR')
         */
        public ScenarioBuilder withPhoneNumberStatus(String status) {
            this.phoneNumberStatus = status;
            return this;
        }

        /**
         * @description The primary method for creating phone number assignments. Defines one series and its children.
         *              Call this method multiple times to create multiple series with different configurations.
         * @param location The Number_Location__c for the Account_Phone_Number_Series__c.
         * @param numberGroup The Number_Group__c for the Account_Phone_Number_Series__c.
         * @param assignmentCount The number of Account_Phone_Number_Assignment__c records to create for this series.
         * @param junctionCount The number of those assignments that should be linked to an Activation_Line__c via a junction record, marking them as "in-use".
         * @return The ScenarioBuilder instance for chaining.
         * @example
         *  // Creates 10 total assignments, 2 of which are linked to activation lines.
         *  .withNumberSeries('SAL', 'P', 10, 2)
         */
        public ScenarioBuilder withNumberSeries(String location, String numberGroup, Integer assignmentCount, Integer junctionCount) {
            seriesConfigs.add(new SeriesConfig(location, numberGroup, assignmentCount, junctionCount));
            return this;
        }

        /**
         * @description (Deprecated) Junction creation is now controlled by `withNumberSeries`.
         */
        public ScenarioBuilder withActivationAssignmentJunctions(Integer count) {
            return this;
        }

        /**
         * @description Skips the creation of Case, Activation, and Activation Line records.
         *              Useful for tests that only need Account, Opportunity, or Quote data (e.g., pre-fulfillment logic).
         * @return The ScenarioBuilder instance for chaining.
         * @example
         *  NorlysTestScenarios.newBuilder()
         *      .withProducts(3)
         *      .withoutCaseAndActivations()
         *      .build();
         */
        public ScenarioBuilder withoutCaseAndActivations() {
            this.createCaseAndActivations = false;
            return this;
        }

        /**
         * @description Sets the CVR__c field on the Account.
         * @param cvr The CVR number to use.
         * @return The ScenarioBuilder instance for chaining.
         * @example .withCvr('87654321')
         */
        public ScenarioBuilder withCvr(String cvr) {
            this.cvr = cvr;
            return this;
        }

        /**
         * @description Sets the number of products (and associated records like Quote Lines) to create.
         * @param count The number of products.
         * @return The ScenarioBuilder instance for chaining.
         * @example .withProducts(3)
         */
        public ScenarioBuilder withProducts(Integer count) {
            this.numProducts = count;
            return this;
        }

        /**
         * @description Sets the number of products that do NOT trigger an activation.
         * @param count The number of "no action" products.
         * @return The ScenarioBuilder instance for chaining.
         * @example .withNoActionProducts(2)
         */
        public ScenarioBuilder withNoActionProducts(Integer count) {
            this.numNoActionProducts = count;
            return this;
        }

        /**
         * @description (Deprecated) Use withNumberSeries instead. Creates assignments without linking them via junctions.
         */
        public ScenarioBuilder withPhoneNumberAssignments(Integer count) {
            if (seriesConfigs.isEmpty()) {
                seriesConfigs.add(new SeriesConfig('BRZ', 'P', count, 0));
            } else {
                seriesConfigs[0].assignmentCount = count;
            }
            return this;
        }

        /**
         * @description The terminal method that executes the build process and creates all configured records.
         * @return A ScenarioResult object containing all the created records.
         */
        public ScenarioResult build() {
            if (this.buildForNumberHandlingOnly) {
                return buildForNumberHandling();
            }
            if (this.buildForNorlysNowCaseHandling) {
                return buildForNorlysNowCaseHandling();
            }

            ScenarioResult result = new ScenarioResult();
            
            // Step 1: Create a running User and a parent Account.
            Profile prof = ProfileSelector.getProfileByProfileName(ProfileConstants.SYSTEM_ADMINISTRATOR);
            result.owner = (User) NorlysSUnit.newFactory().create('User')
                .set('Alias', 'standt')
                .set('Email', 'standarduser@testorg.com')
                .set('EmailEncodingKey', 'UTF-8')
                .set('LastName', 'Testing')
                .set('LanguageLocaleKey', 'en_US')
                .set('LocaleSidKey', 'en_US')
                .set('ProfileId', prof.Id)
                .set('TimeZoneSidKey', 'America/Los_Angeles')
                .set('UserName', StringUtils.makeRandomStringNoNumerics(10) + '@testorg.com')
                .insertRecord();

            System.runAs(result.owner) {
                NorlysSUnitDataFactory accountFactory = NorlysSUnit.newFactory().create('Account')
                    .set('Name', 'Test Scenario Account ' + this.cvr)
                    .set('CVR__c', this.cvr)
                    .set('Status__c', 'Active')
                    .set('OwnerId', result.owner.Id);

                if (this.customerHasTouchpoint != null) {
                    accountFactory.set('Customer_has_Touchpoint__c', this.customerHasTouchpoint);
                }

                result.account = (Account) accountFactory.insertRecord();

                // Step 2: Create Phone Number Series and Assignments based on SeriesConfig list.
                result.phoneNumberAssignments = new List<Account_Phone_Number_Assignment__c>();
                List<Account_Phone_Number_Assignment__c> assignmentsForJunctions = new List<Account_Phone_Number_Assignment__c>();
                Integer phoneCounter = 0;

                if (!seriesConfigs.isEmpty()) {
                    for (SeriesConfig config : seriesConfigs) {
                        Account_Phone_Number_Series__c series = (Account_Phone_Number_Series__c) NorlysSUnit.newFactory()
                            .create('Account_Phone_Number_Series__c')
                            .set('Account__c', result.account.Id)
                            .set('Number_Group__c', config.numberGroup)
                            .set('Number_Location__c', config.location)
                            .set('Product_Type__c', 'GSM')
                            .insertRecord();

                        List<Account_Phone_Number_Assignment__c> seriesAssignments = new List<Account_Phone_Number_Assignment__c>();
                        for (Integer i = 0; i < config.assignmentCount; i++) {
                            Account_Phone_Number_Assignment__c newAssignment = (Account_Phone_Number_Assignment__c) NorlysSUnit.newFactory()
                                .create('Account_Phone_Number_Assignment__c')
                                .set('Account__c', result.account.Id)
                                .set('Account_Phone_Number_Series__c', series.Id)
                                .set('Phone_Number__c', '4511223' + phoneCounter)
                                .set('CTN_Number_Status__c', this.phoneNumberStatus)
                                .getRecord();
                            seriesAssignments.add(newAssignment);
                            phoneCounter++;
                        }
                        insert seriesAssignments;
                        result.phoneNumberAssignments.addAll(seriesAssignments);

                        // Collect assignments that need to be linked to an activation line.
                        Integer currentJunctionCount = 0;
                        for(Account_Phone_Number_Assignment__c assignment : seriesAssignments) {
                            if (currentJunctionCount < config.junctionCount) {
                                assignmentsForJunctions.add(assignment);
                                currentJunctionCount++;
                            }
                        }
                    }
                }

                // Step 3: Create core sales objects (Opportunity, Products, PricebookEntries).
                result.opportunity = (Opportunity) NorlysSUnit.newFactory().create('Opportunity')
                    .set('Name', 'Test Opp for ' + result.account.Name)
                    .set('AccountId', result.account.Id)
                    .set('Type', 'New Business')
                    .set('CloseDate', Date.Today() + 5)
                    .set('StageName', 'Proposal')
                    .set('Pricebook2Id', Test.getStandardPricebookId())
                    .insertRecord();

                result.products = new List<Product2>();
                for (Integer i = 0; i < this.numProducts; i++) {
                    result.products.add(
                        (Product2) NorlysSUnit.newFactory().create('Product2')
                            .set('Name', 'Test Product ' + i)
                            .set('IsActive', true)
                            .set('Activation_Record_Type__c', 'Voice')
                            .getRecord()
                    );
                }
                if (this.numNoActionProducts > 0) {
                    for (Integer i = 0; i < this.numNoActionProducts; i++) {
                        result.products.add(
                            (Product2) NorlysSUnit.newFactory().create('Product2')
                                .set('Name', 'No Action Product ' + i)
                                .set('IsActive', true)
                                .set('Activation_Record_Type__c', NorlysConstants.NO_ACTIVATION_NEEDED)
                                .getRecord()
                        );
                    }
                }
                insert result.products;

                // Insert custom products if they have been provided
                if (!this.customProducts.isEmpty()) {
                    // Ensure custom products are active
                    for (Product2 p : this.customProducts) {
                        p.IsActive = true;
                    }
                    insert this.customProducts;
                    result.products.addAll(this.customProducts);
                }

                // Step 3a: Create Product Features and Options for the primary product if configured.
                if (this.numFeatures > 0) {
                    result.productFeatures = new List<SBQQ__ProductFeature__c>();
                    for (Integer i = 0; i < this.numFeatures; i++) {
                        result.productFeatures.add(
                            (SBQQ__ProductFeature__c) NorlysSUnit.newFactory().create('SBQQ__ProductFeature__c')
                                .set('Name', 'Feature ' + i)
                                .set('SBQQ__Number__c', i + 1)
                                .set('SBQQ__ConfiguredSKU__c', result.products[0].Id)
                                .getRecord()
                        );
                    }
                    insert result.productFeatures;
                }

                if (this.numOptions > 0 && result.productFeatures != null && !result.productFeatures.isEmpty()) {
                    result.productOptions = new List<SBQQ__ProductOption__c>();
                    for (Integer i = 0; i < this.numOptions; i++) {
                        result.productOptions.add(
                            (SBQQ__ProductOption__c) NorlysSUnit.newFactory().create('SBQQ__ProductOption__c')
                                .set('SBQQ__ConfiguredSKU__c', result.products[0].Id)
                                .set('SBQQ__OptionalSKU__c', result.products[0].Id) // Option points to the same product for simplicity
                                .set('SBQQ__Feature__c', result.productFeatures[0].Id)
                                .set('SBQQ__Number__c', i + 1)
                                .getRecord()
                        );
                    }
                    insert result.productOptions;
                }

                result.pricebookEntries = new List<PricebookEntry>();
                Id standardPbId = Test.getStandardPricebookId();
                for (Product2 p : result.products) {
                    result.pricebookEntries.add(
                        (PricebookEntry) NorlysSUnit.newFactory().create('PricebookEntry')
                            .set('IsActive', true)
                            .set('Pricebook2Id', standardPbId)
                            .set('Product2Id', p.Id)
                            .set('UnitPrice', 100)
                            .getRecord()
                    );
                }
                insert result.pricebookEntries;

                Map<Id, Id> productToPbeMap = new Map<Id, Id>();
                for(PricebookEntry pbe : result.pricebookEntries) {
                    productToPbeMap.put(pbe.Product2Id, pbe.Id);
                }
                
                // Step 4: Create Quote and Quote Lines.
                result.quote = (SBQQ__Quote__c) NorlysSUnit.newFactory().create('SBQQ__Quote__c')
                    .set('SBQQ__Account__c', result.account.Id)
                    .set('SBQQ__Opportunity2__c', result.opportunity.Id)
                    .set('SBQQ__Primary__c', true)
                    .set('SBQQ__PricebookId__c', standardPbId)
                    .insertRecord();
                
                result.opportunity.SBQQ__PrimaryQuote__c = result.quote.Id;
                update result.opportunity;

                result.quoteLines = new List<SBQQ__QuoteLine__c>();
                Integer productCounter = 0;
                for (Product2 p : result.products) {
                    SBQQ__QuoteLine__c ql = (SBQQ__QuoteLine__c) NorlysSUnit.newFactory().create('SBQQ__QuoteLine__c')
                        .set('SBQQ__Quote__c', result.quote.Id)
                        .set('SBQQ__Product__c', p.Id)
                        .set('SBQQ__PricebookEntryId__c', productToPbeMap.get(p.Id))
                        .set('SBQQ__Quantity__c', 2)
                        .set('SBQQ__NetPrice__c', 200)
                        .set('cross_sale__c', true)
                        .set('upsale__c', false)
                        .set('SBQQ__Discount__c', this.quoteLineDiscount)
                        .getRecord();
                    
                    // If this is the primary product and we have created options, link the first one.
                    if (productCounter == 0 && result.productOptions != null && !result.productOptions.isEmpty()) {
                        ql.SBQQ__ProductOption__c = result.productOptions[0].Id;
                    }

                    result.quoteLines.add(ql);
                    productCounter++;
                }

                // Create quote lines for custom products
                if (!this.customProducts.isEmpty()) {
                    for (Integer i = 0; i < this.customProducts.size(); i++) {
                        Product2 p = this.customProducts[i];
                        Integer quantity = this.customProductQuantities[i];
                        SBQQ__QuoteLine__c ql = (SBQQ__QuoteLine__c) NorlysSUnit.newFactory().create('SBQQ__QuoteLine__c')
                            .set('SBQQ__Quote__c', result.quote.Id)
                            .set('SBQQ__Product__c', p.Id)
                            .set('SBQQ__PricebookEntryId__c', productToPbeMap.get(p.Id))
                            .set('SBQQ__Quantity__c', quantity)
                            .set('SBQQ__NetPrice__c', 200)
                            .set('cross_sale__c', true)
                            .set('upsale__c', false)
                            .set('SBQQ__Discount__c', this.quoteLineDiscount)
                            .getRecord();
                        result.quoteLines.add(ql);
                    }
                }
                insert result.quoteLines;

                if (this.createStandardVoiceAndHomeOffice) {
                    Product2 voiceProduct = new Product2(
                        ProductAPI_Telia_Product_Id__c = 'CORFRI10G',
                        name = 'Corporate Fri tale EU 10 GB',
                        SBQQ__SubscriptionType__c = 'Renewable',
                        isActive = true,
                        Activation_Record_Type__c = 'Voice',
                        activate_with_other_products__c = false
                    );
                    
                    Product2 homeOfficeProduct = new Product2(
                        ProductAPI_Telia_Product_Id__c = 'CORFRI20G',
                        name = 'Home office',
                        SBQQ__SubscriptionType__c = 'Renewable',
                        isActive = true,
                        Activation_Record_Type__c = 'Home office',
                        activate_with_other_products__c = false,
                        ProductCode = '3100',
                        address_required__c = true
                    );
                    insert new List<Product2>{ voiceProduct, homeOfficeProduct };
                    result.products.addAll(new List<Product2>{ voiceProduct, homeOfficeProduct });

                    if (result.quoteLines.size() >= 2) {
                        result.quoteLines[0].Additional_Quantity__c = 3;
                        result.quoteLines[0].SBQQ__Product__c = voiceProduct.Id;
                        result.quoteLines[0].SBQQ__SegmentIndex__c = 1;
                        result.quoteLines[0].Address_filled_on_activation_lines__c = false;

                        result.quoteLines[1].Additional_Quantity__c = 3;
                        result.quoteLines[1].SBQQ__Product__c = homeOfficeProduct.Id;
                        result.quoteLines[1].SBQQ__SegmentIndex__c = 1;
                        result.quoteLines[1].Address_filled_on_activation_lines__c = false;
                        update result.quoteLines;
                    }
                }

                if (this.createQuoteLineDetails) {
                    List<Quote_Line_Detail__c> detailsToInsert = new List<Quote_Line_Detail__c>();
                    for (SBQQ__QuoteLine__c ql : result.quoteLines) {
                        detailsToInsert.add(new Quote_Line_Detail__c(
                            Quote_Line__c = ql.Id,
                            Manual_Product__c = ql.SBQQ__Product__c,
                            Description__c = 'Test Detail'
                        ));
                    }
                    insert detailsToInsert;
                }

                // Step 5: Optionally create the fulfillment objects (Case, Activations).
                if (this.createCaseAndActivations) {
                    result.caseRecord = (Case) NorlysSUnit.newFactory().create('Case')
                        .set('AccountId', result.account.Id)
                        .set('Opportunity__c', result.opportunity.Id)
                        .set('Subject', 'Order_Fulfilment_Case')
                        .set('RecordTypeId', Schema.sObjectType.Case.getRecordTypeInfosByDeveloperName().get('Order_Fulfilment_Case').getRecordTypeId())
                        .set('Root_BAN__c', this.caseRootBan)
                        .insertRecord();
                    
                    result.opportunity.Case__c = result.caseRecord.Id;
                    update result.opportunity;

                    if (this.createFokusCampaignAndDiscount) {
                        Fokus_Campaign__c fc = new Fokus_Campaign__c(
                            Product_Id__c = 'CORFRI10G',
                            Campaign_Value__c = 36,
                            Campaign_Id__c = 'CORFRI10G_36',
                            Product_Campaign_Composite_Key__c = 'CORFRI10G.CORF10G36'
                        );
                        insert fc;

                        Fokus_Discount__c fd = new Fokus_Discount__c(
                            Product_Id__c = 'CORFRI10G',
                            Discount_Percentage__c = 5,
                            Discount_Id__c = 'CORFRI10G36',
                            Product_Discount_Composite_Key__c = 'CORFRI10G.R132_5'
                        );
                        insert fd;
                    }
                    
                    result.activations = new List<Activation__c>();
                    result.activationLines = new List<Activation_Line__c>();
                    Map<String, Id> activationRecordTypes = new Map<String, Id>();
                    for(RecordTypeInfo rti : Activation__c.SObjectType.getDescribe().getRecordTypeInfos()) {
                        if(!rti.isMaster()) activationRecordTypes.put(rti.getName(), rti.getRecordTypeId());
                    }
                    Map<String, Id> activationLineRecordTypes = new Map<String, Id>();
                    for(RecordTypeInfo rti : Activation_Line__c.SObjectType.getDescribe().getRecordTypeInfos()) {
                        if(!rti.isMaster()) activationLineRecordTypes.put(rti.getName(), rti.getRecordTypeId());
                    }

                    Map<String, Activation__c> activationMap = new Map<String, Activation__c>();
                    Map<Id, Product2> productMap = new Map<Id, Product2>([SELECT Id, Activation_Record_Type__c FROM Product2 WHERE Id IN :result.products]);
                    for (SBQQ__QuoteLine__c ql : result.quoteLines) {
                        Product2 prod = productMap.get(ql.SBQQ__Product__c);
                        if (prod != null && String.isNotBlank(prod.Activation_Record_Type__c) && prod.Activation_Record_Type__c != NorlysConstants.NO_ACTIVATION_NEEDED) {
                            String activationRecordTypeName = prod.Activation_Record_Type__c + ' activation';
                            if (!activationMap.containsKey(activationRecordTypeName) && activationRecordTypes.containsKey(activationRecordTypeName)) {
                                Activation__c newActivation = (Activation__c) NorlysSUnit.newFactory().create('Activation__c')
                                    .set('Name', prod.Activation_Record_Type__c)
                                    .set('Case__c', result.caseRecord.Id)
                                    .set('RecordTypeId', activationRecordTypes.get(activationRecordTypeName))
                                    .getRecord();
                                activationMap.put(activationRecordTypeName, newActivation);
                            }
                        }
                    }
                    if(!activationMap.isEmpty()) {
                        insert activationMap.values();
                        result.activations = activationMap.values();
                    }

                    for (SBQQ__QuoteLine__c ql : result.quoteLines) {
                        Product2 prod = productMap.get(ql.SBQQ__Product__c);
                        String activationRecordTypeName = prod.Activation_Record_Type__c + ' activation';
                        ql.Activation__c = activationMap.get(activationRecordTypeName)?.Id;
                    }
                    update result.quoteLines;
                    
                    for (SBQQ__QuoteLine__c ql : result.quoteLines) {
                         Product2 prod = productMap.get(ql.SBQQ__Product__c);
                         if (prod != null && String.isNotBlank(prod.Activation_Record_Type__c) && prod.Activation_Record_Type__c != NorlysConstants.NO_ACTIVATION_NEEDED) {
                             String lineRecordTypeName = prod.Activation_Record_Type__c + ' activation line';
                             if(activationLineRecordTypes.containsKey(lineRecordTypeName)) {
                                 result.activationLines.add(
                                     (Activation_Line__c) NorlysSUnit.newFactory().create('Activation_Line__c')
                                        .set('Activation__c', ql.Activation__c)
                                        .set('Quote_Line__c', ql.Id)
                                        .set('RecordTypeId', activationLineRecordTypes.get(lineRecordTypeName))
                                        .set('Mobile_No__c', this.mobileNumber)
                                        .set('phone_no_status__c', this.phoneNoStatusOnActivationLine)
                                        .getRecord()
                                 );
                             }
                         }
                    }
                    if(!result.activationLines.isEmpty()) {
                        insert result.activationLines;

                        if (this.activationLineCustomizations != null) {
                            Activation_Line__c lineToUpdate = result.activationLines[0];
                            for (String fieldName : this.activationLineCustomizations.keySet()) {
                                lineToUpdate.put(fieldName, this.activationLineCustomizations.get(fieldName));
                            }
                            update lineToUpdate;
                        }
                    }

                    // Step 6: Create junctions between Activation Lines and Phone Number Assignments.
                    if (!assignmentsForJunctions.isEmpty()) {
                        result.activationAssignmentJunctions = new List<Activation_Assignment_Junction__c>();
                        Integer maxJunctions = Math.min(assignmentsForJunctions.size(), result.activationLines.size());

                        for (Integer i = 0; i < maxJunctions; i++) {
                            result.activationAssignmentJunctions.add(
                                (Activation_Assignment_Junction__c) NorlysSUnit.newFactory().create('Activation_Assignment_Junction__c')
                                    .set('Activation_Line__c', result.activationLines[i].Id)
                                    .set('Account_Phone_Number_Assignment__c', assignmentsForJunctions[i].Id)
                                    .getRecord()
                            );
                        }
                        insert result.activationAssignmentJunctions;
                    }
                }

                result.activationQuote = result.quote;

                if (this.createContractAndSubscription) {
                    result.contract = new Contract(
                        AccountId = result.account.Id,
                        Total_Contract_value__c = 6000,
                        Migrated_Contract__c = true,
                        Pricebook2Id = Test.getStandardPricebookId(),
                        SBQQ__AmendmentPricebookId__c = Test.getStandardPricebookId(),
                        SBQQ__RenewalPricebookId__c = Test.getStandardPricebookId(),
                        SBQQ__AmendmentRenewalBehavior__c = 'Latest End Date',
                        Product_s_in_scope__c = 'Voice',
                        SBQQ__RenewalTerm__c = 36,
                        Mobile_Part_of_Contract__c = true,
                        SBQQ__RenewalForecast__c = false,
                        SBQQ__Quote__c = result.quote.id,
                        Status = 'Draft',
                        StartDate = Date.today()
                    );
                    insert result.contract;

                    result.contract.Status = 'Activated';
                    result.contract.SBQQ__RenewalForecast__c = false;
                    result.contract.ContractTerm = 36;
                    update result.contract;

                    result.opportunity.SBQQ__AmendedContract__c = result.contract.Id;
                    update result.opportunity;

                    result.subscriptions = new List<SBQQ__Subscription__c>();
                    for (SBQQ__QuoteLine__c ql : result.quoteLines) {
                        result.subscriptions.add(new SBQQ__Subscription__c(
                            SBQQ__Contract__c = result.contract.Id,
                            SBQQ__Product__c = ql.SBQQ__Product__c,
                            SBQQ__Quantity__c = ql.SBQQ__Quantity__c,
                            SBQQ__Account__c = result.account.Id,
                            SBQQ__QuoteLine__c = ql.Id
                        ));
                    }
                    insert result.subscriptions;
                }
            }
            
            return result;
        }

        /**
         * @description Private method to handle the lightweight build path.
         *              Creates a smaller subset of records for number/case handling tests.
         */
        private ScenarioResult buildForNumberHandling() {
            ScenarioResult result = new ScenarioResult();
            
            // Step 1: Create a running User and a parent Account.
            Profile prof = ProfileSelector.getProfileByProfileName(ProfileConstants.SYSTEM_ADMINISTRATOR);
            result.owner = (User) NorlysSUnit.newFactory().create('User')
                .set('Alias', 'standt')
                .set('Email', 'standarduser@testorg.com')
                .set('EmailEncodingKey', 'UTF-8')
                .set('LastName', 'Testing')
                .set('LanguageLocaleKey', 'en_US')
                .set('LocaleSidKey', 'en_US')
                .set('ProfileId', prof.Id)
                .set('TimeZoneSidKey', 'America/Los_Angeles')
                .set('UserName', StringUtils.makeRandomStringNoNumerics(10) + '@testorg.com')
                .insertRecord();

            System.runAs(result.owner) {
                result.account = (Account) NorlysSUnit.newFactory().create('Account')
                    .set('Name', 'Test Scenario Account ' + this.cvr)
                    .set('CVR__c', this.cvr)
                    .set('Status__c', 'Active')
                    .set('OwnerId', result.owner.Id)
                    .insertRecord();

                // Step 2: Create Phone Number Series and Assignments
                result.phoneNumberAssignments = new List<Account_Phone_Number_Assignment__c>();
                List<Account_Phone_Number_Assignment__c> assignmentsForJunctions = new List<Account_Phone_Number_Assignment__c>();
                 if (!seriesConfigs.isEmpty()) {
                    Integer phoneCounter = 0;
                    for (SeriesConfig config : seriesConfigs) {
                        Account_Phone_Number_Series__c series = (Account_Phone_Number_Series__c) NorlysSUnit.newFactory()
                            .create('Account_Phone_Number_Series__c')
                            .set('Account__c', result.account.Id)
                            .set('Number_Group__c', config.numberGroup)
                            .set('Number_Location__c', config.location)
                            .set('Product_Type__c', 'GSM')
                            .insertRecord();

                        List<Account_Phone_Number_Assignment__c> seriesAssignments = new List<Account_Phone_Number_Assignment__c>();
                        for (Integer i = 0; i < config.assignmentCount; i++) {
                            seriesAssignments.add(
                                (Account_Phone_Number_Assignment__c) NorlysSUnit.newFactory()
                                    .create('Account_Phone_Number_Assignment__c')
                                    .set('Account__c', result.account.Id)
                                    .set('Account_Phone_Number_Series__c', series.Id)
                                    .set('Phone_Number__c', '4511223' + phoneCounter)
                                    .set('CTN_Number_Status__c', this.phoneNumberStatus)
                                    .getRecord()
                            );
                            phoneCounter++;
                        }
                        insert seriesAssignments;
                        result.phoneNumberAssignments.addAll(seriesAssignments);

                        // Collect assignments that need to be linked to an activation line.
                        Integer currentJunctionCount = 0;
                        for(Account_Phone_Number_Assignment__c assignment : seriesAssignments) {
                            if (currentJunctionCount < config.junctionCount) {
                                assignmentsForJunctions.add(assignment);
                                currentJunctionCount++;
                            }
                        }
                    }
                }

                // Step 3: Create Case, Activation, and Activation Lines
                result.caseRecord = (Case) NorlysSUnit.newFactory().create('Case')
                    .set('AccountId', result.account.Id)
                    .set('Subject', 'Order_Fulfilment_Case')
                    .set('RecordTypeId', Schema.sObjectType.Case.getRecordTypeInfosByDeveloperName().get('Order_Fulfilment_Case').getRecordTypeId())
                    .insertRecord();

                result.activations = new List<Activation__c>();
                List<Activation__c> activationsToInsert = new List<Activation__c>();
                Id activationRecordTypeId = Schema.SObjectType.Activation__c.getRecordTypeInfosByDeveloperName().get('Voice_activation').getRecordTypeId();

                for (Integer j = 0; j < this.numActivations; j++) {
                    activationsToInsert.add(
                        (Activation__c) NorlysSUnit.newFactory().create('Activation__c')
                            .set('Name', 'Voice ' + (j + 1)) // 1-based naming
                            .set('Case__c', result.caseRecord.Id)
                            .set('RecordTypeId', activationRecordTypeId)
                            .getRecord()
                    );
                }
                if (!activationsToInsert.isEmpty()) {
                    insert activationsToInsert;
                }
                result.activations = activationsToInsert;

                result.activationLines = new List<Activation_Line__c>();
                Id activationLineRecordTypeId = Schema.SObjectType.Activation_Line__c.getRecordTypeInfosByDeveloperName().get('Voice_activation_line').getRecordTypeId();
                List<Activation_Line__c> linesToInsert = new List<Activation_Line__c>();

                if (!this.activationLineCounts.isEmpty()) {
                    // New path: Use the list of counts
                    if (this.numActivations != this.activationLineCounts.size()) {
                        throw new NorlysTestScenariosException(
                            'The number of activations (' + this.numActivations + ') does not match the size of the activation line counts list (' + this.activationLineCounts.size() + ').'
                        );
                    }

                    for (Integer i = 0; i < result.activations.size(); i++) {
                        Activation__c currentActivation = result.activations[i];
                        Integer lineCount = this.activationLineCounts[i];
                        for (Integer j = 0; j < lineCount; j++) {
                            linesToInsert.add(
                                (Activation_Line__c) NorlysSUnit.newFactory().create('Activation_Line__c')
                                    .set('Activation__c', currentActivation.Id)
                                    .set('RecordTypeId', activationLineRecordTypeId)
                                    .set('Mobile_No__c', this.mobileNumber)
                                    .set('phone_no_status__c', this.phoneNoStatusOnActivationLine)
                                    .getRecord()
                            );
                        }
                    }
                } else if (this.numActivationLines > 0) {
                    // Original path: Use the single count for all activations
                    for (Activation__c activation : result.activations) {
                        for (Integer i = 0; i < this.numActivationLines; i++) {
                            linesToInsert.add(
                                (Activation_Line__c) NorlysSUnit.newFactory().create('Activation_Line__c')
                                    .set('Activation__c', activation.Id)
                                    .set('RecordTypeId', activationLineRecordTypeId)
                                    .set('Mobile_No__c', this.mobileNumber)
                                    .set('phone_no_status__c', this.phoneNoStatusOnActivationLine)
                                    .getRecord()
                            );
                        }
                    }
                }

                if (!linesToInsert.isEmpty()) {
                    insert linesToInsert;
                    result.activationLines = linesToInsert;
                }

                // Step 4: Create junctions between Activation Lines and Phone Number Assignments.
                if (!assignmentsForJunctions.isEmpty()) {
                    result.activationAssignmentJunctions = new List<Activation_Assignment_Junction__c>();
                    Integer maxJunctions = Math.min(assignmentsForJunctions.size(), result.activationLines.size());

                    for (Integer i = 0; i < maxJunctions; i++) {
                        result.activationAssignmentJunctions.add(
                            (Activation_Assignment_Junction__c) NorlysSUnit.newFactory().create('Activation_Assignment_Junction__c')
                                .set('Activation_Line__c', result.activationLines[i].Id)
                                .set('Account_Phone_Number_Assignment__c', assignmentsForJunctions[i].Id)
                                .getRecord()
                        );
                    }
                    insert result.activationAssignmentJunctions;
                }
            }
            return result;
        }

        /**
         * @description Private method to handle the lightweight NorlysNow Case build path.
         *              Creates a parent Case and child NorlysNow_Case__c records.
         */
        private ScenarioResult buildForNorlysNowCaseHandling() {
            ScenarioResult result = new ScenarioResult();
            
            // Step 1: Create a running User and a parent Account.
            Profile prof = ProfileSelector.getProfileByProfileName(ProfileConstants.SYSTEM_ADMINISTRATOR);
            result.owner = (User) NorlysSUnit.newFactory().create('User')
                .set('Alias', 'standt')
                .set('Email', 'standarduser@testorg.com')
                .set('EmailEncodingKey', 'UTF-8')
                .set('LastName', 'Testing')
                .set('LanguageLocaleKey', 'en_US')
                .set('LocaleSidKey', 'en_US')
                .set('ProfileId', prof.Id)
                .set('TimeZoneSidKey', 'America/Los_Angeles')
                .set('UserName', StringUtils.makeRandomStringNoNumerics(10) + '@testorg.com')
                .insertRecord();

            System.runAs(result.owner) {
                result.account = (Account) NorlysSUnit.newFactory().create('Account')
                    .set('Name', 'Test Scenario Account ' + this.cvr)
                    .set('CVR__c', this.cvr)
                    .set('Status__c', 'Active')
                    .set('OwnerId', result.owner.Id)
                    .insertRecord();

                // Step 2: Create a parent Opportunity and Case record.
                result.opportunity = (Opportunity) NorlysSUnit.newFactory().create('Opportunity')
                    .set('Name', 'Test Opp for ' + result.account.Name)
                    .set('AccountId', result.account.Id)
                    .set('Type', 'New Business')
                    .set('CloseDate', Date.Today() + 5)
                    .set('StageName', 'Proposal')
                    .set('Pricebook2Id', Test.getStandardPricebookId())
                    .insertRecord();

                result.caseRecord = (Case) NorlysSUnit.newFactory().create('Case')
                    .set('AccountId', result.account.Id)
                    .set('Opportunity__c', result.opportunity.Id)
                    .set('Subject', 'Order_Fulfilment_Case')
                    .set('RecordTypeId', Schema.sObjectType.Case.getRecordTypeInfosByDeveloperName().get('Order_Fulfilment_Case').getRecordTypeId())
                    .insertRecord();
                
                // Step 3: Create NorlysNow_Case__c records
                result.norlysNowCases = new List<NorlysNow_Case__c>();
                if (this.numNorlysNowCases > 0) {
                    List<NorlysNow_Case__c> casesToInsert = new List<NorlysNow_Case__c>();
                    for (Integer i = 0; i < this.numNorlysNowCases; i++) {
                        casesToInsert.add(
                            (NorlysNow_Case__c) NorlysSUnit.newFactory().create('NorlysNow_Case__c')
                                .set('Parent_Case__c', result.caseRecord.Id)
                                .set('Account__c', result.account.Id)
                                .set('Status__c', 'New')
                                .set('Sync_Status__c', 'Pending')
                                .getRecord()
                        );
                    }
                    insert casesToInsert;
                    // Re-query to populate relationship fields and formula fields
                    result.norlysNowCases = [
                        SELECT Id, Name, Status__c, Parent_Case__c, Parent_Case__r.Status,
                         Parent_Case__r.OwnerId, Account__c, Sync_Status__c, Priority__c, CreatedBy.Id,
                         Description__c, Title__c, Type__c, NorlysNow_Id__c, Request_Source__c, 
                         Category__c, Technology_Type__c, Technology__c, Sync_Message__c, OneWorkFlow_Id__c
                        FROM NorlysNow_Case__c
                        WHERE Id IN :casesToInsert
                    ];
                }

                // Step 4: Create FeedItem records
                if (this.numFeedItems > 0 && !result.norlysNowCases.isEmpty()) {
                    List<FeedItem> itemsToInsert = new List<FeedItem>();
                    // Create feed items on the first NorlysNow_Case__c
                    Id parentId = result.norlysNowCases[0].Id; 
                    for (Integer i = 0; i < this.numFeedItems; i++) {
                        itemsToInsert.add(new FeedItem(
                            ParentId = parentId,
                            Body = 'Test Feed Item ' + i,
                            IsRichText = false
                        ));
                    }
                    insert itemsToInsert;
                    result.feedItems = itemsToInsert;
                }

                // Step 5: Create ContentDocumentLink records
                if (this.numFilesToAttach > 0 && !result.norlysNowCases.isEmpty()) {
                    List<ContentDocumentLink> linksToInsert = new List<ContentDocumentLink>();
                    Id parentId = result.norlysNowCases[0].Id;
                    for (Integer i = 0; i < this.numFilesToAttach; i++) {
                        ContentVersion cv = TDF_ContentVersionUtils.createContentVersion('Test Doc ' + i, 'txt', 'Test Data');
                        ContentDocument cd = [SELECT Id FROM ContentDocument WHERE LatestPublishedVersionId = :cv.Id];
                        linksToInsert.add(new ContentDocumentLink(
                            LinkedEntityId = parentId,
                            ContentDocumentId = cd.Id,
                            ShareType = 'V'
                        ));
                    }
                    insert linksToInsert;
                    result.contentDocumentLinks = linksToInsert;
                }
            }
            return result;
        }
    }

    /**
     * @description Creates a new instance of the scenario builder.
     * @return A new ScenarioBuilder instance.
     */
    public static ScenarioBuilder newBuilder() {
        return new ScenarioBuilder();
    }
}