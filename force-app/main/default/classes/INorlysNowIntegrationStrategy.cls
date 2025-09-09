public interface INorlysNowIntegrationStrategy {
    Set<Id> toExecute(EventExecutor__e event);
}