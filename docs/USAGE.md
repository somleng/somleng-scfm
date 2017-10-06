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

## Tasks

Somleng SCFM Tasks are stand alone rake tasks that can be run manually, from cron or from another application.

### Quickstart

This section explains how to get up and running quickly using tasks. Please continue reading the sections below for detailed information on tasks.

If you want to follow this guide without installing anything locally, run the docker examples instead (assumes you have Docker installed).

#### 1. Create the database

```
$ bundle exec rake db:create && bundle exec rake db:migrate
```

or using Docker

```
$ sudo docker run --rm -v /tmp/somleng-scfm/db:/tmp/db -e RAILS_ENV=production dwilkie/somleng-scfm /bin/bash -c 'bundle exec rake db:create && bundle exec rake db:migrate && if [ ! -f /tmp/db/somleng_scfm_production.sqlite3 ]; then cp /usr/src/app/db/somleng_scfm_production.sqlite3 /tmp/db; fi'
```

#### 2. Import contacts

```
$ DUMMY_CONTACT_MSISDN=replace-with-your-phone-number-or-remove-this-env-variable bundle exec rails runner ./examples/import_contacts.rb
```

or using Docker

```
$ sudo docker run --rm -v /tmp/somleng-scfm/db:/usr/src/app/db -e RAILS_ENV=production -e DUMMY_CONTACT_MSISDN=replace-with-your-phone-number-or-remove-this-env-variable dwilkie/somleng-scfm /bin/bash -c 'bundle exec rails runner /usr/src/app/examples/import_contacts.rb'
```

#### 3. Create a callout

```
$ bundle exec rake task:callouts:create
```

or using Docker

```
$ sudo docker run --rm -t -v /tmp/somleng-scfm/db:/usr/src/app/db -e RAILS_ENV=production dwilkie/somleng-scfm /bin/bash -c 'bundle exec rake task:callouts:create'
```

#### 4. Populate the callout

```
$ bundle exec rake task:callouts:populate
```

or using Docker

```
$ sudo docker run --rm -t -v /tmp/somleng-scfm/db:/usr/src/app/db -e RAILS_ENV=production dwilkie/somleng-scfm /bin/bash -c 'bundle exec rake task:callouts:populate'
```

#### 5. Print callout statistics

```
$ bundle exec rake task:callouts:statistics
```

or using Docker

```
$ sudo docker run --rm -t -v /tmp/somleng-scfm/db:/usr/src/app/db -e RAILS_ENV=production dwilkie/somleng-scfm /bin/bash -c 'bundle exec rake task:callouts:statistics'
```

#### 6. Start the callout and print the statistics to see that it's running

```
$ CALLOUTS_TASK_ACTION=start bundle exec rake task:callouts:run && bundle exec rake task:callouts:statistics
```

or using Docker

```
$ sudo docker run --rm -t -v /tmp/somleng-scfm/db:/usr/src/app/db -e RAILS_ENV=production -e CALLOUTS_TASK_ACTION=start dwilkie/somleng-scfm /bin/bash -c 'bundle exec rake task:callouts:run && bundle exec rake task:callouts:statistics'
```

#### 7. Pause the callout and print the statistics to see that it's paused (optional)

```
$ CALLOUTS_TASK_ACTION=pause bundle exec rake task:callouts:run && bundle exec rake task:callouts:statistics
```

or using Docker

```
$ sudo docker run --rm -t -v /tmp/somleng-scfm/db:/usr/src/app/db -e RAILS_ENV=production -e CALLOUTS_TASK_ACTION=pause dwilkie/somleng-scfm /bin/bash -c 'bundle exec rake task:callouts:run && bundle exec rake task:callouts:statistics'
```

#### 8. Resume the callout and print the statistics to see that it's running (optional)

```
$ CALLOUTS_TASK_ACTION=resume bundle exec rake task:callouts:run && bundle exec rake task:callouts:statistics
```

or using Docker

```
$ sudo docker run --rm -t -v /tmp/somleng-scfm/db:/usr/src/app/db -e RAILS_ENV=production -e CALLOUTS_TASK_ACTION=resume dwilkie/somleng-scfm /bin/bash -c 'bundle exec rake task:callouts:run && bundle exec rake task:callouts:statistics'
```

#### 9. Stop the callout and print the statistics to see that it's stopped (optional)

```
$ CALLOUTS_TASK_ACTION=stop bundle exec rake task:callouts:run && bundle exec rake task:callouts:statistics
```

or using Docker

```
$ sudo docker run --rm -t -v /tmp/somleng-scfm/db:/usr/src/app/db -e RAILS_ENV=production -e CALLOUTS_TASK_ACTION=stop dwilkie/somleng-scfm /bin/bash -c 'bundle exec rake task:callouts:run && bundle exec rake task:callouts:statistics'
```

#### 10. Resume the callout again and print the statistics to see that it's running (optional)

```
$ CALLOUTS_TASK_ACTION=resume bundle exec rake task:callouts:run && bundle exec rake task:callouts:statistics
```

or using Docker

```
$ sudo docker run --rm -t -v /tmp/somleng-scfm/db:/usr/src/app/db -e RAILS_ENV=production -e CALLOUTS_TASK_ACTION=resume dwilkie/somleng-scfm /bin/bash -c 'bundle exec rake task:callouts:run && bundle exec rake task:callouts:statistics'
```

#### 11. Enqueue the calls on Somleng (or Twilio) and print the statistics (your phone should ring)

```
$ SOMLENG_CLIENT_REST_API_HOST="api.twilio.com" SOMLENG_CLIENT_REST_API_BASE_URL="https://api.twilio.com" SOMLENG_ACCOUNT_SID="replace-with-your-somleng-or-twilio-account-sid" SOMLENG_AUTH_TOKEN="replace-with-your-somleng-or-twilio-auth-token" ENQUEUE_CALLS_TASK_DEFAULT_SOMLENG_REQUEST_PARAMS="{\"from\":\"1234\",\"url\":\"http://demo.twilio.com/docs/voice.xml\",\"method\":\"GET\"}" bundle exec rake task:enqueue_calls:run && bundle exec rake task:callouts:statistics
```

or using Docker

```
$ sudo docker run --rm -t -v /tmp/somleng-scfm/db:/usr/src/app/db -e RAILS_ENV=production -e SOMLENG_CLIENT_REST_API_HOST="api.twilio.com" -e SOMLENG_CLIENT_REST_API_BASE_URL="https://api.twilio.com" -e SOMLENG_ACCOUNT_SID="replace-with-your-somleng-or-twilio-account-sid" -e SOMLENG_AUTH_TOKEN="replace-with-your-somleng-or-twilio-auth-token" -e ENQUEUE_CALLS_TASK_DEFAULT_SOMLENG_REQUEST_PARAMS="{\"from\":\"1234\",\"url\":\"http://demo.twilio.com/docs/voice.xml\",\"method\":\"GET\"}" dwilkie/somleng-scfm /bin/bash -c 'bundle exec rake task:enqueue_calls:run && bundle exec rake task:callouts:statistics'
```

#### 12. Update the call status and print the statistics (run multiple times to watch it change)

```
$ SOMLENG_CLIENT_REST_API_HOST="api.twilio.com" SOMLENG_CLIENT_REST_API_BASE_URL="https://api.twilio.com" SOMLENG_ACCOUNT_SID="replace-with-your-somleng-or-twilio-account-sid" SOMLENG_AUTH_TOKEN="replace-with-your-somleng-or-twilio-auth-token" bundle exec rake task:update_calls:run && bundle exec rake task:callouts:statistics
```

or using Docker

```
$ sudo docker run --rm -t -v /tmp/somleng-scfm/db:/usr/src/app/db -e RAILS_ENV=production -e SOMLENG_CLIENT_REST_API_HOST="api.twilio.com" -e SOMLENG_CLIENT_REST_API_BASE_URL="https://api.twilio.com" -e SOMLENG_ACCOUNT_SID="replace-with-your-somleng-or-twilio-account-sid" -e SOMLENG_AUTH_TOKEN="replace-with-your-somleng-or-twilio-auth-token" dwilkie/somleng-scfm /bin/bash -c 'bundle exec rake task:update_calls:run && bundle exec rake task:callouts:statistics'
```

Optionally repeat step 11, this time your phone should not ring

#### 13. Boot the Rails Console (optional)

```
$ bundle exec rails c
```

or using Docker

```
$ sudo docker run --rm -it -v /tmp/somleng-scfm/db:/usr/src/app/db -e RAILS_ENV=production dwilkie/somleng-scfm bundle exec rails c
```

#### 14. Boot the Database Console (optional)

```
$ bundle exec rails dbconsole
```

or using Docker

```
$ sudo docker run --rm -it -v /tmp/somleng-scfm/db:/usr/src/app/db -e RAILS_ENV=production dwilkie/somleng-scfm bundle exec rails dbconsole
```

### Global Task Configuration

Each task has it's own specific configuration which is documented below. Some tasks make use of global configuration which is described here.

#### Scopes

`PHONE_NUMBER_RETRY_STATUSES` configures the phone call statuses in which to retry (defaults to `failed`). Used in the [PhoneNumber.remaining scope](https://github.com/somleng/somleng-scfm/blob/master/app/models/phone_number.rb)

`PHONE_CALL_TIME_CONSIDERED_RECENTLY_CREATED_SECONDS` configures the age in seconds in which a phone call is considered recently created (defaults to `60`). Used in the [PhoneCall.not_recently_created scope](https://github.com/somleng/somleng-scfm/blob/master/app/models/phone_call.rb)

#### Somleng Configuration

`SOMLENG_CLIENT_REST_API_HOST` configures the REST API host to connect to Somleng (or Twilio) (defaults to `api.twilio.com`).

`SOMLENG_CLIENT_REST_API_BASE_URL` configures the REST API base url to connect to Somleng (or Twilio) (defaults to `https://api.twilio.com`).

`SOMLENG_ACCOUNT_SID` configures the Account SID for Somleng (or Twilio) (defaults to nil).

`SOMLENG_AUTH_TOKEN` configures the Auth Token for Somleng (or Twilio) (defaults to nil).

### Callouts

The [callouts task](https://github.com/somleng/somleng-scfm/blob/master/app/tasks/callouts_task.rb) performs various operations on callouts.

#### task:callouts:create

Creates a new callout and prints the callout id.

##### Task Configuration

`CALLOUTS_TASK_CREATE_METADATA` configures the default metadata to be set when creating a callout (defaults to nil). For example, setting `CALLOUTS_TASK_CREATE_METADATA="{'foo':'bar'}"` will create the callout with the specified metadata. The metadata is default metadata only and can be overriden in [the task](https://github.com/somleng/somleng-scfm/blob/master/app/tasks/callouts_task.rb).

##### Example

```
$ CALLOUTS_TASK_CREATE_METADATA='{}' bundle exec rake task:callouts:create
```

#### task:callouts:populate

Populates a callout with phone numbers to call.

##### Task Configuration

`CALLOUTS_TASK_POPULATE_METADATA` configures the default metadata to be set on the phone numbers when populating the callout (defaults to nil). For example, setting `CALLOUTS_TASK_POPULATE_METADATA="{'foo':'bar'}"` will populate the callout with phone numbers containg the specified metadata. The metadata is default metadata only and can be overriden in [the task](https://github.com/somleng/somleng-scfm/blob/master/app/tasks/callouts_task.rb).

`CALLOUTS_TASK_CALLOUT_ID` tells the task which callout to populate. If `CALLOUTS_TASK_CALLOUT_ID` is not specified it's assumed there is only one callout in the database. If there are multiple an exception is raised.

By default callouts are populated with all the contacts in the Contacts table. Override the `contacts_to_populate_with` in the [task](https://github.com/somleng/somleng-scfm/blob/master/app/tasks/callouts_task.rb) to modify this behavior.

##### Example

```
$ CALLOUTS_TASK_POPULATE_METADATA='{}' CALLOUTS_TASK_CALLOUT_ID= bundle exec rake task:callouts:populate
```

#### task:callouts:run

*start*, *stop*, *pause* or *resume* a callout

##### Task Configuration

`CALLOUTS_TASK_ACTION` tells the script which action to perform. `CALLOUTS_TASK_ACTION` can be one of either `start`, `stop`, `pause` or `resume`.

`CALLOUTS_TASK_CALLOUT_ID` tells the task which callout to perform the action on. If `CALLOUTS_TASK_CALLOUT_ID` is not specified then it's assumed there is only one callout in the database. If there are multiple an exception is raised.

##### Example

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

##### Task Configuration

`ENQUEUE_CALLS_TASK_MAX_CALLS_TO_ENQUEUE` configures the maximum number of calls to enqueue (defaults to nil). If `ENQUEUE_CALLS_TASK_MAX_CALLS_TO_ENQUEUE=30` the maximum number of calls that will be enqueued by running this task will be 30. If `ENQUEUE_CALLS_TASK_MAX_CALLS_TO_ENQUEUE` is not specified then there is no maximum (the task will try to enqueue as many as it can).

`ENQUEUE_CALLS_TASK_ENQUEUE_STRATEGY` configures the strategy for enqueuing calls. If `ENQUEUE_CALLS_TASK_ENQUEUE_STRATEGY=optimistic` (default). The maximum number of calls that will be enqueued by running this task will be equal to `ENQUEUE_CALLS_TASK_MAX_CALLS_TO_ENQUEUE`.

If `ENQUEUE_CALLS_TASK_ENQUEUE_STRATEGY=pessimistic` the maximum number of calls that will be enqueued by running this task will be the difference between `ENQUEUE_CALLS_TASK_MAX_CALLS_TO_ENQUEUE` and the amount of calls that are awaiting completion. For example, suppose `ENQUEUE_CALLS_TASK_MAX_CALLS_TO_ENQUEUE=30` and `ENQUEUE_CALLS_TASK_ENQUEUE_STRATEGY=pessimistic` and there are `10` phone calls awaiting completion. In this case the maximum number of phone calls that will be enqueued by running this task would be `30 - 10 = 20`.

`ENQUEUE_CALLS_TASK_PESSIMISTIC_MIN_CALLS_TO_ENQUEUE` configures the minimum number of calls to enqueue if `ENQUEUE_CALLS_TASK_ENQUEUE_STRATEGY=pessimistic` (defaults to 1). Using the example above let's say there are actually `30` phone calls awaiting completion. Using logic described above the maximum number of phone calls that will be enqueued by running this task would be `30 - 30 = 0`. Setting `ENQUEUE_CALLS_TASK_PESSIMISTIC_MIN_CALLS_TO_ENQUEUE` to `1` would ensure that even though all calls are awaiting completion, 1 call would still be enqueued by running this task.

`ENQUEUE_CALLS_TASK_MAX_CALLS_PER_PERIOD` configures the maximum number of calls to enqueue in a given period (defaults to nil). Where the period is configured by `ENQUEUE_CALLS_TASK_MAX_CALLS_PER_PERIOD_HOURS` (or is 24 hours by default). For example suppose you set `ENQUEUE_CALLS_TASK_MAX_CALLS_PER_PERIOD=1000`. This would set a maximum number of calls to be enqueued to 1000 per 24 hour period. Setting `ENQUEUE_CALLS_TASK_MAX_CALLS_PER_PERIOD_HOURS=36` would apply this maximum to a 3 day period instead.

`ENQUEUE_CALLS_TASK_DEFAULT_SOMLENG_REQUEST_PARAMS` configures the default request params that will be sent to Somleng (or Twilio) when enqueuing a call (defaults to nil). Setting `ENQUEUE_CALLS_TASK_DEFAULT_SOMLENG_REQUEST_PARAMS="{'from':'1234','url':'http://demo.twilio.com/docs/voice.xml','method':'GET'}"` would send these params to Somleng (or Twilio) when enqueuing a phone call. These params are default params only and can be overriden in [the task](https://github.com/somleng/somleng-scfm/blob/master/app/tasks/enqueue_calls_task.rb).

##### Somleng (Twilio) Configuration

See [Somleng Configuration](#somleng-configuration)

##### Example

```
$ ENQUEUE_CALLS_TASK_MAX_CALLS_TO_ENQUEUE=30 ENQUEUE_CALLS_TASK_ENQUEUE_STRATEGY=optimistic ENQUEUE_CALLS_TASK_PESSIMISTIC_MIN_CALLS_TO_ENQUEUE=1 ENQUEUE_CALLS_TASK_MAX_CALLS_PER_PERIOD= ENQUEUE_CALLS_TASK_MAX_CALLS_PER_PERIOD_HOURS=24 ENQUEUE_CALLS_TASK_DEFAULT_SOMLENG_REQUEST_PARAMS="{'from':'1234','url':'http://demo.twilio.com/docs/voice.xml','method':'GET'}" bundle exec rake task:enqueue_calls:run
```

### Update Calls

The [update calls task](https://github.com/somleng/somleng-scfm/blob/master/app/tasks/update_calls_task.rb) handles updating phone call statuses from Somleng or Twilio.

#### task:update_calls:run

##### Task Configuration

`UPDATE_CALLS_TASK_MAX_CALLS_TO_FETCH` configures the maximum number of calls to fetch when running this task (defaults to nil). Setting `UPDATE_CALLS_TASK_MAX_CALLS_TO_FETCH=1000` would limit the task to fetching at most 1000 call statuses.

##### Somleng (Twilio) Configuration

See [Somleng Configuration](#somleng-configuration)

##### Example

```
$ UPDATE_CALLS_TASK_MAX_CALLS_TO_FETCH=1000 bundle exec rake task:update_calls:run
```

#### rake task:start_flow_rapidpro:run

The [start flow rapidpro task](https://github.com/somleng/somleng-scfm/blob/master/app/tasks/start_flow_rapidpro_task.rb) triggers a remote flow on [RapidPro](https://community.rapidpro.io/).

##### Task Configuration

`START_FLOW_RAPIDPRO_TASK_MAX_FLOWS_TO_START` configures the maximum number of flows to trigger when running this task (defaults to nil).

`START_FLOW_RAPIDPRO_TASK_REMOTE_REQUEST_PARAMS` configures the default request parameters that will be sent to RapidPro for each remote request (defaults to nil). For example, setting `START_FLOW_RAPIDPRO_TASK_REMOTE_REQUEST_PARAMS="{\"flow\"=>\"flow-id\", \"groups\"=>[], \"contacts\"=>[], \"urns\"=>[\"telegram:telegram-id\"], \"extra\"=>{}}"` would send these parameters to the the start flow remote request on RapidPro. These params are default params only and can be overriden in [the task](https://github.com/somleng/somleng-scfm/blob/master/app/tasks/start_flow_rapidpro_task.rb).

`RAPIDPRO_BASE_URL` configures the base url to send RapidPro requests (defaults to `https://app.rapidpro.io/api`)

`RAPIDPRO_API_VERSION` configures the API version for RapidPro (defaults to `v2`)

`RAPIDPRO_API_TOKEN` configures the API token needed to authenticate with RapidPro (defaults to nil)

##### Example

```
$ RAPIDPRO_BASE_URL="https://app.rapidpro.io/api" RAPIDPRO_API_VERSION="v2" RAPIDPRO_API_TOKEN="rapidpro-api-token" START_FLOW_RAPIDPRO_TASK_MAX_FLOWS_TO_START=1000 START_FLOW_RAPIDPRO_TASK_REMOTE_REQUEST_PARAMS="{\"flow\"=>\"flow-id\", \"groups\"=>[], \"contacts\"=>[], \"urns\"=>[\"telegram:telegram-id\"], \"extra\"=>{}}" bundle exec rake task:start_flow_rapidpro:run
```
