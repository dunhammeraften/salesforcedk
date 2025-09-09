/*************************************************************************************************
 * This file is part of the Nebula Logger project, released under the MIT License.               *
 * See LICENSE file or go to https://github.com/jongpie/NebulaLogger for full license details.   *
 *                                                                                               *
 * Nikhil - I've taken the component from nebula repository and adapted it to our Logger.        *
 ************************************************************************************************/

import { LightningElement } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { subscribe, unsubscribe } from 'lightning/empApi';
export default class LogEntryEventStream extends LightningElement {
    unfilteredEvents = [];

    logEntryEvents = [];
    isExpanded = false;
    isStreamEnabled = true;

    // Filters
    loggedByFilter;
    messageFilter;
    traceIdFilter;
    logLevelFilter;
    originFilter;
    maxEventsToDisplay = 50;
    maxEventsToStream = 500;

    _channel;
    _subscription = {};
    // Count of events delivered since the stream was most recently started
    _currentEventsDelivered = 0;
    // Count of events delivered to the component since it's been loaded
    _totalEventsDelivered = 0;

    async connectedCallback() {
        this._channel = '/event/Debug_Event__e'
        this.createSubscription();
    }

    disconnectedCallback() {
        this.cancelSubscription();
    }

    get title() {
        let logEntryString = ' Matching Log Entry Events';
        let startingTitle =
            this.logEntryEvents.length + logEntryString + ' | ' + this._totalEventsDelivered + ' Total Streamed Events';
        return startingTitle;
    }

    get eventDeliveryUsageSummary() {
        return (
            this._currentEventsDelivered +
            ' Platform Events Delivered to Stream | ' +
            this.maxEventsToStream +
            ' Max Currently Configured'
        );
    }

    get eventDeliveryPercent() {
        if (this._currentEventsDelivered === 0) {
            return 0;
        } else if (this._currentEventsDelivered >= this.maxEventsToStream) {
            return 100;
        }
        return (this._currentEventsDelivered / this.maxEventsToStream) * 100;
    }

    get eventDeliveryProgressVariant() {
        if (!this.isStreamEnabled) {
            return 'active-step';
        } else if (this.eventDeliveryPercent < 50) {
            return 'base';
        } else if (this.eventDeliveryPercent >= 50 && this.eventDeliveryPercent < 75) {
            return 'warning';
        }
        return 'expired';
    }

    get maxEventsToStreamHelp() {
        return (
            "Streaming platform events counts towards your org's daily allocation for Event Delivery." +
            ' \n\nTo minimize usage of the daily allocation, this field controls the max number of LogEntryEvent__e records to deliver to your stream before the stream auto-pauses.' +
            ' \n\nFor more information on platform event allocations, see https://developer.salesforce.com/docs/atlas.en-us.platform_events.meta/platform_events/platform_event_limits.htm'
        );
    }

    get streamButtonVariant() {
        return this.isStreamEnabled ? 'success' : 'brand';
    }

    async createSubscription() {
        this._currentEventsDelivered = 0;
        this._subscription = await subscribe(this._channel, -1, (event) => {
            if (!this.isStreamEnabled) {
                return;
            }

            if (this._currentEventsDelivered >= this.maxEventsToStream) {
                this.onToggleStream();
                return;
            }

            this._currentEventsDelivered++;
            this._totalEventsDelivered++;

            const logEntryEvent = JSON.parse(JSON.stringify(event.data.payload));
            let cleanedLogEntryEvent = {};
            this.unfilteredEvents.unshift(logEntryEvent);
            this._filterEvents();
        });
    }

    cancelSubscription() {
        unsubscribe(this._subscription);
    }

    handleFilterChange(event) {
        this[event.target.dataset.id] = event.target.value;
        this._filterEvents();
    }

    handleMaxEventsStreamedChange(event) {
        this.maxEventsToStream = event.target.value;
    }

    handleMaxEventsToDisplayChange(event) {
        this.maxEventsToDisplay = event.target.value;
        this._filterEvents();
    }

    onClear() {
        this.logEntryEvents = [];
        this.unfilteredEvents = [];
    }

    onToggleExpand() {
        let consoleBlock = this.template.querySelector('[data-id="event-stream-console"]');
        consoleBlock.className = this.isExpanded ? 'slds-card ' : 'slds-card expanded';
        this.isExpanded = !this.isExpanded;
    }

    onToggleStream() {
        this.isStreamEnabled = !this.isStreamEnabled;
        // eslint-disable-next-line
        this.isStreamEnabled ? this.createSubscription() : this.cancelSubscription();
    }

    // Private functions
    _filterEvents() {
        while (this.unfilteredEvents.length > this.maxEventsToDisplay) {
            this.unfilteredEvents.pop();
        }

        this.logEntryEvents = this.unfilteredEvents.filter(
            (logEntryEvent) =>
                this._meetsLoggedByFilter(logEntryEvent) &&
                this._meetsLogLevelFilter(logEntryEvent) &&
                this._meetsMessageFilter(logEntryEvent) &&
                this._meetsTraceIdFilter(logEntryEvent) &&
                this._meetsOriginFilter(logEntryEvent)
        );
    }

    _meetsOriginFilter(logEntryEvent) {
        return this._matchesTextFilter(this.originFilter, logEntryEvent.Log_Location__c);
    }


    _meetsLogLevelFilter(logEntryEvent) {
        return this._matchesTextFilter(this.logLevelFilter, logEntryEvent.Log_Level__c);
    }

    _meetsLoggedByFilter(logEntryEvent) {
        return this._matchesTextFilter(this.loggedByFilter, logEntryEvent.CreatedById);
    }

    _meetsTraceIdFilter(logEntryEvent) {
        return this._matchesTextFilter(this.traceIdFilter, logEntryEvent.Trace_Id__c);
    }

    _meetsMessageFilter(logEntryEvent) {
        return this._matchesTextFilter(this.messageFilter, logEntryEvent.Log_Lines__c);
    }

    _matchesTextFilter(filterCriteria = '', text = '') {
        let matches = false;
        if (!filterCriteria || text.includes(filterCriteria) || text.match(filterCriteria)) {
            matches = true;
        }
        return matches;
    }

    _handleError = (error) => {
        const errorMessage = error.body ? error.body.message : error.message;
        /* eslint-disable-next-line no-console */
        console.error(errorMessage, error);
        this.dispatchEvent(
            new ShowToastEvent({
                mode: 'sticky',
                title: errorMessage,
                variant: 'error'
            })
        );
    };
}