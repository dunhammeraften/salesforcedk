/**
 * @description This interface defines the contract for strategies that handle Norlys Now integration events.
 *              Each strategy is responsible for processing a specific type of event.
 *
 * -----------------------------------------------------------------------------
 * @author Developer           Date            Description
 * -----------------------------------------------------------------------------
 * @author Esben Hovgaard        18/09/2025      Class and method documentation
 * -----------------------------------------------------------------------------
 */
public interface INorlysNowIntegrationStrategy {
	/**
	 * @description Executes the integration logic for a specific event type.
	 * @param event The platform event to be processed.
	 * @return A set of record Ids that need to be retried. If the set is empty,
	 *         it means all records were processed successfully.
	 */
	Set<Id> toExecute(EventExecutor__e event);
}
