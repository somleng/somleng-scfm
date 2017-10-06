# Usage

## Concepts and Terminology

Somleng SCFM is build around the following key concepts.

### Contacts

A [contact](https://github.com/somleng/somleng-scfm/blob/master/app/models/contact.rb) represents a person who has a [msisdn (aka: phone number)](https://en.wikipedia.org/wiki/MSISDN). A Phone Number has another meaning within the context of Somleng SCFM so we'll refer to a contact's phone number as their msisdn from now on to avoid confusion. Contacts are uniquely indexed by their msisdn. You cannot create two contacts with the same msisdn.

### Callouts

A [callout](https://github.com/somleng/somleng-scfm/blob/master/app/models/callout.rb) represents a collection of phone numbers that need to be called for a particular purpose. A callout has a status and can be *started*, *stopped*, *paused* or *resumed*.

### Phone Numbers

A [phone number](https://github.com/somleng/somleng-scfm/blob/master/app/models/phone_number.rb) (not to be confused with a msisdn) represents a contact who needs to be called for a particular callout. Phone numbers have multiple phone calls. Phone numbers are uniquely indexed by the callout and contact. You cannot create two phone numbers with the same callout and contact.

### Phone Calls

A [phone call](https://github.com/somleng/somleng-scfm/blob/master/app/models/phone_call.rb) represents a single attempt at a phone call. A phone call has a status which represents the outcome of the phone call. There may be muliple phone calls for single phone number on a callout.

## Rake Tasks

### Callouts

The [callouts task](https://github.com/somleng/somleng-scfm/blob/master/app/tasks/callouts_task.rb) performs various operations on callouts.

#### task:callouts:create

Creates a new callout and prints the callout id. If `CALLOUTS_TASK_CREATE_METADATA` is set to a JSON string the callout will be created with the specified metadata.

```
$ CALLOUTS_TASK_CREATE_METADATA='{}' bundle exec rake task:callouts:create
```

#### task:callouts:populate

Populates a callout with phone numbers. If `CALLOUTS_TASK_POPULATE_METADATA` is set to a JSON string the resulting phone numbers will be created with the specified metadata. If `CALLOUTS_TASK_CALLOUT_ID` is specified then the callout with the specified id will be populated. If `CALLOUTS_TASK_CALLOUT_ID` is not specified it's assumed there is only one callout in the database. If there are multiple an exception is raised.

By default callouts are populated with all the contacts in the Contacts table. Override the `contacts_to_populate_with` in the [callouts task](https://github.com/somleng/somleng-scfm/blob/master/app/tasks/callouts_task.rb) to modify this behavior.

```
$ CALLOUTS_TASK_POPULATE_METADATA='{}' CALLOUTS_TASK_CALLOUT_ID= bundle exec rake task:callouts:populate
```

#### task:callouts:run

*start*, *stop*, *pause* or *resume* a callout given a valid `CALLOUTS_TASK_ACTION`. If `CALLOUTS_TASK_CALLOUT_ID` is specified then the callout with the specified id will be actioned. If `CALLOUTS_TASK_CALLOUT_ID` is not specified then it's assumed there is only one callout in the database. If there are multiple an exception is raised.

```
$ CALLOUTS_TASK_ACTION='start|stop|pause|resume' CALLOUTS_TASK_CALLOUT_ID= bundle exec rake task:callouts:run
```

#### task:callouts:statistics

Prints statistics for a given callout. If `CALLOUTS_TASK_CALLOUT_ID` is specified then statistics for the callout with the specified id will be printed. If `CALLOUTS_TASK_CALLOUT_ID` is not specified then it's assumed there is only one callout in the database. If there are multiple an exception is raised.

```
$ CALLOUTS_TASK_CALLOUT_ID= bundle exec rake task:callouts:statistics
```

### Enqueue Calls

The [enqueue calls task](https://github.com/somleng/somleng-scfm/blob/master/app/tasks/enqueue_calls_task.rb) handles enqueuing calls

#### task:enqueue_calls:run

Remotely enqueues phone calls on [Somleng](https://github.com/somleng/twilreapi) or [Twilio](https://www.twilio.com/)

##### Configuration

`ENQUEUE_CALLS_TASK_MAX_CALLS_TO_ENQUEUE` configures the maximum number of calls to enqueue (defaults to nil). If `ENQUEUE_CALLS_TASK_MAX_CALLS_TO_ENQUEUE=30` the maximum number of calls that will be enqueued by running this task will be 30. If `ENQUEUE_CALLS_TASK_MAX_CALLS_TO_ENQUEUE` is not specified then there is no maximum (the task will try to enqueue as many as it can).

`ENQUEUE_CALLS_TASK_ENQUEUE_STRATEGY` configures the strategy for enqueuing calls. If `ENQUEUE_CALLS_TASK_ENQUEUE_STRATEGY=optimistic` (default). The maximum number of calls that will be enqueued by running this task will be equal to `ENQUEUE_CALLS_TASK_MAX_CALLS_TO_ENQUEUE`.

If `ENQUEUE_CALLS_TASK_ENQUEUE_STRATEGY=pessimistic` the maximum number of calls that will be enqueued by running this task will be the difference between `ENQUEUE_CALLS_TASK_MAX_CALLS_TO_ENQUEUE` and the amount of calls that are awaiting completion. For example, suppose `ENQUEUE_CALLS_TASK_MAX_CALLS_TO_ENQUEUE=30` and `ENQUEUE_CALLS_TASK_ENQUEUE_STRATEGY=pessimistic` and there are `10` phone calls awaiting completion. In this case the maximum number of phone calls that will be enqueued by running this task would be `30 - 10 = 20`.

`ENQUEUE_CALLS_TASK_PESSIMISTIC_MIN_CALLS_TO_ENQUEUE` configures the minimum number of calls to enqueue if `ENQUEUE_CALLS_TASK_ENQUEUE_STRATEGY=pessimistic` (defaults to 1). Using the example above let's say there are actually `30` phone calls awaiting completion. Using logic described above the maximum number of phone calls that will be enqueued by running this task would be `30 - 30 = 0`. Setting `ENQUEUE_CALLS_TASK_PESSIMISTIC_MIN_CALLS_TO_ENQUEUE` to `1` would ensure that even though all calls are awaiting completion, 1 call would still be enqueued by running this task.

`ENQUEUE_CALLS_TASK_MAX_CALLS_PER_PERIOD` configures the maximum number of calls to enqueue in a given period (defaults to nil). Where the period is configured by `ENQUEUE_CALLS_TASK_MAX_CALLS_PER_PERIOD_HOURS` (or is 24 hours by default). For example suppose you set `ENQUEUE_CALLS_TASK_MAX_CALLS_PER_PERIOD=1000`. This would set a maximum number of calls to be enqueued to 1000 per 24 hour period. Setting `ENQUEUE_CALLS_TASK_MAX_CALLS_PER_PERIOD_HOURS=36` would apply this maximum to a 3 day period instead.

`ENQUEUE_CALLS_TASK_REMOTE_CALL_PARAMS` configures the default request params that will be sent to Somleng (or Twilio) when enqueuing a call (defaults to nil). Setting `ENQUEUE_CALLS_TASK_REMOTE_CALL_PARAMS="{'from':'1234','url':'http://demo.twilio.com/docs/voice.xml','method':'GET'}"` would send these params to Somleng (or Twilio) when enqueuing a phone call. These params are default params only and can be overriden in [the task](https://github.com/somleng/somleng-scfm/blob/master/app/tasks/enqueue_calls_task.rb).
```

```
$ ENQUEUE_CALLS_TASK_MAX_CALLS_TO_ENQUEUE=30 ENQUEUE_CALLS_TASK_ENQUEUE_STRATEGY=optimistic ENQUEUE_CALLS_TASK_PESSIMISTIC_MIN_CALLS_TO_ENQUEUE=1 ENQUEUE_CALLS_TASK_MAX_CALLS_PER_PERIOD= ENQUEUE_CALLS_TASK_MAX_CALLS_PER_PERIOD_HOURS=24 ENQUEUE_CALLS_TASK_REMOTE_CALL_PARAMS="{'from':'1234','url':'http://demo.twilio.com/docs/voice.xml','method':'GET'}" bundle exec rake task:enqueue_calls:run
```

