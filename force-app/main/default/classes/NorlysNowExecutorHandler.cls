/**
 * @description This class is an event handler that processes events for the Norlys Now integration.
 *              It uses a strategy pattern to delegate the processing of different event types
 *              to specific integration strategy classes.
 *
 * -----------------------------------------------------------------------------
 * @author Developer           Date            Description
 * -----------------------------------------------------------------------------
 * @author Esben Hovgaard        18/09/2025      Class, method and inline documentation
 * -----------------------------------------------------------------------------
 */
public with sharing class NorlysNowExecutorHandler implements IEventExecutableHandler {
	private final NorlysNowService norlysNowService;
	private final EventExecutorService eventExecutorService;
	private final Map<String, INorlysNowIntegrationStrategy> strategies;

	/**
	 * @description Default constructor that initializes the required services and strategies
	 *              using the SingletonFactory.
	 */
	public NorlysNowExecutorHandler() {
		this(SingletonFactory.getFactory());
	}

	/**
	 * @description Private constructor for dependency injection.
	 * @param singletonFactory The SingletonFactory instance to use for creating dependencies.
	 */
	private NorlysNowExecutorHandler(SingletonFactory singletonFactory) {
		this.norlysNowService = (NorlysNowService) singletonFactory.getOrRegisterSingleton(
			NorlysNowService.class
		);
		this.eventExecutorService = (EventExecutorService) singletonFactory.getOrRegisterSingleton(
			EventExecutorService.class
		);
		// Initialize the strategy map with all supported integration strategies.
		this.strategies = new Map<String, INorlysNowIntegrationStrategy>{
			'NorlysNow_Case__c' => (NorlysNowCaseStrategy) singletonFactory.getOrRegisterSingleton(
				NorlysNowCaseStrategy.class
			),
			'FeedItem' => (NorlysNowFeedItemStrategy) singletonFactory.getOrRegisterSingleton(
				NorlysNowFeedItemStrategy.class
			),
			'ContentDocumentLink' => (NorlysNowContentDocumentLinkStrategy) singletonFactory.getOrRegisterSingleton(
				NorlysNowContentDocumentLinkStrategy.class
			)
		};
	}

	/**
	 * @description This is the main execution method for the event handler. It determines the event type,
	 *              selects the appropriate strategy, and executes it. If the strategy indicates
	 *              that a retry is needed, it publishes a new event to re-process the failed items.
	 * @param event The platform event to be processed.
	 */
	public void execute(EventExecutor__e event) {
		Logger.logInfo(String.format('execute( {0} )', new List<Object>{ event }));
		norlysNowService.Parameters params = norlysNowService.getParameters(
			event.Parameters__c
		);
		String type = params.type;
		// Select the appropriate strategy based on the event type.
		INorlysNowIntegrationStrategy strategy = strategies.get(type);

		if (strategy != null) {
			// Execute the strategy and get the set of record Ids that need to be retried.
			Set<Id> recordIds = strategy.toExecute(event);

			// If there are any remaining record Ids, publish a new event to retry the process.
			if (!recordIds.isEmpty()) {
				params.recordIds = recordIds;
				EventExecutor__e retryEventExecutor = new EventExecutor__e();
				retryEventExecutor.Parameters__c = JSON.serialize(params);
				retryEventExecutor.Executor__c = event.Executor__c;
				retryEventExecutor.RetryCount__c = event.RetryCount__c + 1;
				retryEventExecutor.LastEventExecutorException__c = 'Events failed try to rerun!';
				retryEventExecutor.LastEventExecutorUuid__c = event.EventUuid;
				retryEventExecutor.LastEventExecutorReplayId__c = event.ReplayId;

				eventExecutorService.publish(retryEventExecutor);
			} else {
				Logger.logInfo('No recordIds found for retry: ' + recordIds);
			}
		} else {
			Logger.logError('No strategy found for type: ' + type);
		}
	}
}
