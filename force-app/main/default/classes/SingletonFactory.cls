public with sharing class SingletonFactory {
    
    /**
     * Private map storing singleton instances keyed by their types.
     * Ensures one instance per type exists in the system.
     */
    private final Map<Type, Object> singletonTypeToInstance = new Map<Type, Object>();
    
    /**
     * Private static reference to the single factory instance.
     * Enforces Singleton pattern at class level.
     */
    private static SingletonFactory singletonFactory;
    
    /**
     * Returns the single instance of the factory class.
     * Creates a new instance if none exists.
     *
     * @return SingletonFactory instance
     */
    public static SingletonFactory getFactory() {
        if (singletonFactory == null) {
            singletonFactory = new SingletonFactory();
        }
        return singletonFactory;
    }
    
    /**
     * Retrieves or creates a singleton instance for the specified type.
     * If an instance exists, returns the cached version; otherwise creates and stores a new instance.
     *
     * @param instanceType Type of object to retrieve/create
     * @return Existing or newly created instance of the specified type
     */
    public Object getOrRegisterSingleton(Type instanceType) {
        if (this.singletonTypeToInstance.containsKey(instanceType)) {
            return this.singletonTypeToInstance.get(instanceType);
        }
        
        Object discreteInstance = instanceType.newInstance();
        
        this.singletonTypeToInstance.put(instanceType, discreteInstance);

        return discreteInstance;
    }
}