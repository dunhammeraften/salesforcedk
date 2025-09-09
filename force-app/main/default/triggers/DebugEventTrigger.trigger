/**
 * Trigger that react to inserts into the Debug event platform event.
 * It is the responsibility of this trigger to initiate the handler of the platform events
 * @log:
 *  -----------------------------------------------------------------------------
 *  Developer            Date            Description
 *  -----------------------------------------------------------------------------
 *  Sergio Pedro         18/03/2025      Initial version 
 * 
 * @author Sergio Pedro
 * @date 18/03/2025
 */
trigger DebugEventTrigger on Debug_Event__e (after insert) {
    new DebugEventTriggerHandler().run();
}