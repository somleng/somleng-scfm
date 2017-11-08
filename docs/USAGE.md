# Usage

## Quickstart

### Introduction

Let's start with an example. Suppose there's a flood warning for a particular area and you want to call out to those who are affected and warn them of the impending danger.

In order to do that we're going to make use of the [REST API](https://github.com/somleng/somleng-scfm/blob/master/docs/REST_API_REFERENCE.md).

### Getting set up

For the Quickstart we're going to use Somleng SCFM in SQLite mode with Docker. Note that this is not recommended for a production environment, but it's the easiest way to get started on your local machine.

#### Install Docker

If you haven't already done so, go ahead and [install Docker](https://docs.docker.com/engine/installation/) before continuing.

#### Have your Twilio API Keys ready

For the quickstart guide we're going to connect Somleng SCFM to Twilio. Have your Twilio API Keys (Account SID and Auth Token) ready.

#### Create a new SQLite Database

The first thing to do is create the database which will be used for keeping track of things. Go ahead and run the following command to get your database set up.

Note: This will create a new SQLite database in `/tmp/somleng-scfm/db` called `somleng_scfm_production.sqlite3` your host machine. Feel free to change the `-v` flag in the command below create it somewhere else. The examples in this quickstart assume that your database is in `/tmp/somleng-scfm/db` so be sure to update them if needed.

```
$ docker run --rm -v /tmp/somleng-scfm/db:/tmp/db -e RAILS_ENV=production dwilkie/somleng-scfm /bin/bash -c 'bundle exec rake db:create && bundle exec rake db:migrate && if [ ! -f /tmp/db/somleng_scfm_production.sqlite3 ]; then cp /usr/src/app/db/somleng_scfm_production.sqlite3 /tmp/db; fi'
```

#### Start the REST API Server

Run the following command to boot the REST API Server.

```
$ docker run -it --rm -v /tmp/somleng-scfm/db:/usr/src/app/db -p 3000:3000 -h scfm --name somleng-scfm -e RAILS_ENV=production -e SECRET_KEY_BASE=secret dwilkie/somleng-scfm /bin/bash -c 'bundle exec rails s'
```

To test things out run the following command from another terminal:

```
$ docker run -t --rm --link somleng-scfm endeveit/docker-jq /bin/sh -c 'curl -s -v  http://scfm:3000/api/contacts | jq .'
```

You should see something like:

```
< HTTP/1.1 200 OK
< X-Frame-Options: SAMEORIGIN
< X-XSS-Protection: 1; mode=block
< X-Content-Type-Options: nosniff
< Per-Page: 25
< Total: 0
< Content-Type: application/json; charset=utf-8
< ETag: W/"4f53cda18c2baa0c0354bb5f9a3ecbe5"
< Cache-Control: max-age=0, private, must-revalidate
< X-Request-Id: 85efd4b1-028a-44a8-8a6f-81f523d41a9d
< X-Runtime: 0.004101
< Transfer-Encoding: chunked
<
{ [12 bytes data]
* Curl_http_done: called premature == 0
* Connection #0 to host scfm left intact
[]
```

### Creating Contacts

Now that we're all set up, let's create some contacts in our database. In Somleng SCFM, a contact represents a single person with a phone number.

Following the [REST API Reference](https://github.com/somleng/somleng-scfm/blob/master/docs/REST_API_REFERENCE.md) create let's create a few contacts.

The following command creates a new contact with the phone number (msisdn) `+85510202101` with metadata specifying the `zip_code` and `city`. Note that you can add whatever metadata you like. Feel free the parameters below.

```
$ docker run -t --rm --link somleng-scfm endeveit/docker-jq /bin/sh -c 'curl -s -XPOST http://scfm:3000/api/contacts --data-urlencode "msisdn=+85510202101" -d "metadata[zip_code]=90210" -d "metadata[city]=Beverly+Hills" | jq .'
```

You should see something like:

```json
{
  "id": 1,
  "msisdn": "+85510202101",
  "metadata": {
    "zip_code": "90210",
    "city": "Beverly Hills"
  },
  "created_at": "2017-11-08T05:09:12.920Z",
  "updated_at": "2017-11-08T05:09:12.920Z"
}
```

Now, let's create another contact from a different zip code

```
$ docker run -t --rm --link somleng-scfm endeveit/docker-jq /bin/sh -c 'curl -s -XPOST http://scfm:3000/api/contacts --data-urlencode "msisdn=+85510202102" -d "metadata[zip_code]=90049" -d "metadata[city]=Los+Angeles" | jq .'
```

You should see something like:

```json
{
  "id": 2,
  "msisdn": "+85510202102",
  "metadata": {
    "zip_code": "90049",
    "city": "Los Angeles"
  },
  "created_at": "2017-11-08T05:14:21.833Z",
  "updated_at": "2017-11-08T05:14:21.833Z"
}
```

*Optionally* you can:

#### Update a Contact:

```
$ docker run -t --rm --link somleng-scfm endeveit/docker-jq /bin/sh -c 'curl -XPUT http://scfm:3000/api/contacts/1 --data-urlencode "msisdn=+14151009333"'
```

And get the contact to check they were updated successfully:

```
$ docker run -t --rm --link somleng-scfm endeveit/docker-jq /bin/sh -c 'curl -s http://scfm:3000/api/contacts/1 | jq .'
```

Sample Response:

```json
{
  "id": 1,
  "msisdn": "+14151009333",
  "metadata": {
    "zip_code": "90210",
    "city": "Beverly Hills"
  },
  "created_at": "2017-11-08T05:09:12.920Z",
  "updated_at": "2017-11-08T05:17:24.803Z"
}
```

#### Delete a contact

```
$ docker run -t --rm --link somleng-scfm endeveit/docker-jq /bin/sh -c 'curl -XDELETE http://scfm:3000/api/contacts/1'
```

#### List all contacts

```
$ docker run -t --rm --link somleng-scfm endeveit/docker-jq /bin/sh -c 'curl -s http://scfm:3000/api/contacts | jq .'
```

Sample Response:

```json
[
  {
    "id": 2,
    "msisdn": "+85510202102",
    "metadata": {
      "zip_code": "90049",
      "city": "Los Angeles"
    },
    "created_at": "2017-11-08T05:14:21.833Z",
    "updated_at": "2017-11-08T05:14:21.833Z"
  }
]
```

### Create a Callout

Now that we have some contacts in our database let's create a callout. In Somleng SCFM a callout represents a collection of contacts that need to be called for a particular purpose. In this example the callout represents the disaster alert. A callout can be *started*, *stopped*, *paused* or *resumed* using the REST API.

Let's go ahead and create a callout:

```
$ docker run -t --rm --link somleng-scfm endeveit/docker-jq /bin/sh -c 'curl -s -XPOST http://scfm:3000/api/callouts | jq .'
```

Sample Response:

```json
{
  "id": 1,
  "status": "initialized",
  "metadata": {},
  "created_at": "2017-11-08T05:30:38.291Z",
  "updated_at": "2017-11-08T05:30:38.291Z"
}
```

Note that the callout has been initialized, but not yet started. We could start the callout now, but it has not yet been populated so it wouldn't initiate any calls. So before we do that let's go and populate the callout first.

Note you can also list, show, update, filter and delete callouts similar to contacts. See the [REST API Reference](https://github.com/somleng/somleng-scfm/blob/master/docs/REST_API_REFERENCE.md) for more details

## Tasks

Somleng SCFM Tasks are stand alone rake tasks that can be run manually, from cron or from another application.

### Quickstart

This section explains how to get up and running quickly using tasks. Please continue reading the sections below for detailed information on tasks.

If you want to follow this guide without installing anything locally, run the docker examples instead (assumes you have Docker installed).

DEPRECATED:

#### 4. Populate the callout

```
$ bundle exec rake task:callouts:populate
```

or using Docker

```
$ docker run --rm -t -v /tmp/somleng-scfm/db:/usr/src/app/db -e RAILS_ENV=production dwilkie/somleng-scfm /bin/bash -c 'bundle exec rake task:callouts:populate'
```

#### 5. Print callout statistics

```
$ bundle exec rake task:callouts:statistics
```

or using Docker

```
$ docker run --rm -t -v /tmp/somleng-scfm/db:/usr/src/app/db -e RAILS_ENV=production dwilkie/somleng-scfm /bin/bash -c 'bundle exec rake task:callouts:statistics'
```

#### 6. Start the callout and print the statistics to see that it's running

```
$ CALLOUTS_TASK_ACTION=start bundle exec rake task:callouts:run && bundle exec rake task:callouts:statistics
```

or using Docker

```
$ docker run --rm -t -v /tmp/somleng-scfm/db:/usr/src/app/db -e RAILS_ENV=production -e CALLOUTS_TASK_ACTION=start dwilkie/somleng-scfm /bin/bash -c 'bundle exec rake task:callouts:run && bundle exec rake task:callouts:statistics'
```

#### 7. Pause the callout and print the statistics to see that it's paused (optional)

```
$ CALLOUTS_TASK_ACTION=pause bundle exec rake task:callouts:run && bundle exec rake task:callouts:statistics
```

or using Docker

```
$ docker run --rm -t -v /tmp/somleng-scfm/db:/usr/src/app/db -e RAILS_ENV=production -e CALLOUTS_TASK_ACTION=pause dwilkie/somleng-scfm /bin/bash -c 'bundle exec rake task:callouts:run && bundle exec rake task:callouts:statistics'
```

#### 8. Resume the callout and print the statistics to see that it's running (optional)

```
$ CALLOUTS_TASK_ACTION=resume bundle exec rake task:callouts:run && bundle exec rake task:callouts:statistics
```

or using Docker

```
$ docker run --rm -t -v /tmp/somleng-scfm/db:/usr/src/app/db -e RAILS_ENV=production -e CALLOUTS_TASK_ACTION=resume dwilkie/somleng-scfm /bin/bash -c 'bundle exec rake task:callouts:run && bundle exec rake task:callouts:statistics'
```

#### 9. Stop the callout and print the statistics to see that it's stopped (optional)

```
$ CALLOUTS_TASK_ACTION=stop bundle exec rake task:callouts:run && bundle exec rake task:callouts:statistics
```

or using Docker

```
$ docker run --rm -t -v /tmp/somleng-scfm/db:/usr/src/app/db -e RAILS_ENV=production -e CALLOUTS_TASK_ACTION=stop dwilkie/somleng-scfm /bin/bash -c 'bundle exec rake task:callouts:run && bundle exec rake task:callouts:statistics'
```

#### 10. Resume the callout again and print the statistics to see that it's running (optional)

```
$ CALLOUTS_TASK_ACTION=resume bundle exec rake task:callouts:run && bundle exec rake task:callouts:statistics
```

or using Docker

```
$ docker run --rm -t -v /tmp/somleng-scfm/db:/usr/src/app/db -e RAILS_ENV=production -e CALLOUTS_TASK_ACTION=resume dwilkie/somleng-scfm /bin/bash -c 'bundle exec rake task:callouts:run && bundle exec rake task:callouts:statistics'
```

#### 11. Enqueue the calls on Somleng (or Twilio) and print the statistics (your phone should ring)

```
$ SOMLENG_CLIENT_REST_API_HOST="api.twilio.com" SOMLENG_CLIENT_REST_API_BASE_URL="https://api.twilio.com" SOMLENG_ACCOUNT_SID="replace-with-your-somleng-or-twilio-account-sid" SOMLENG_AUTH_TOKEN="replace-with-your-somleng-or-twilio-auth-token" ENQUEUE_CALLS_TASK_DEFAULT_SOMLENG_REQUEST_PARAMS="{\"from\":\"1234\",\"url\":\"http://demo.twilio.com/docs/voice.xml\",\"method\":\"GET\"}" bundle exec rake task:enqueue_calls:run && bundle exec rake task:callouts:statistics
```

or using Docker

```
$ docker run --rm -t -v /tmp/somleng-scfm/db:/usr/src/app/db -e RAILS_ENV=production -e SOMLENG_CLIENT_REST_API_HOST="api.twilio.com" -e SOMLENG_CLIENT_REST_API_BASE_URL="https://api.twilio.com" -e SOMLENG_ACCOUNT_SID="replace-with-your-somleng-or-twilio-account-sid" -e SOMLENG_AUTH_TOKEN="replace-with-your-somleng-or-twilio-auth-token" -e ENQUEUE_CALLS_TASK_DEFAULT_SOMLENG_REQUEST_PARAMS="{\"from\":\"1234\",\"url\":\"http://demo.twilio.com/docs/voice.xml\",\"method\":\"GET\"}" dwilkie/somleng-scfm /bin/bash -c 'bundle exec rake task:enqueue_calls:run && bundle exec rake task:callouts:statistics'
```

#### 12. Update the call status and print the statistics (run multiple times to watch it change)

```
$ SOMLENG_CLIENT_REST_API_HOST="api.twilio.com" SOMLENG_CLIENT_REST_API_BASE_URL="https://api.twilio.com" SOMLENG_ACCOUNT_SID="replace-with-your-somleng-or-twilio-account-sid" SOMLENG_AUTH_TOKEN="replace-with-your-somleng-or-twilio-auth-token" bundle exec rake task:update_calls:run && bundle exec rake task:callouts:statistics
```

or using Docker

```
$ docker run --rm -t -v /tmp/somleng-scfm/db:/usr/src/app/db -e RAILS_ENV=production -e SOMLENG_CLIENT_REST_API_HOST="api.twilio.com" -e SOMLENG_CLIENT_REST_API_BASE_URL="https://api.twilio.com" -e SOMLENG_ACCOUNT_SID="replace-with-your-somleng-or-twilio-account-sid" -e SOMLENG_AUTH_TOKEN="replace-with-your-somleng-or-twilio-auth-token" dwilkie/somleng-scfm /bin/bash -c 'bundle exec rake task:update_calls:run && bundle exec rake task:callouts:statistics'
```

Optionally repeat step 11, this time your phone should not ring

#### 13. Boot the Rails Console (optional)

```
$ bundle exec rails c
```

or using Docker

```
$ docker run --rm -it -v /tmp/somleng-scfm/db:/usr/src/app/db -e RAILS_ENV=production dwilkie/somleng-scfm bundle exec rails c
```

#### 14. Boot the Database Console (optional)

```
$ bundle exec rails dbconsole
```

or using Docker

```
$ docker run --rm -it -v /tmp/somleng-scfm/db:/usr/src/app/db -e RAILS_ENV=production dwilkie/somleng-scfm bundle exec rails dbconsole
```

#### 15. List available rake tasks (optional)

```
$ bundle exec rake -T
```

or using Docker

```
$ docker run --rm -t -e RAILS_ENV=production dwilkie/somleng-scfm bundle exec rake -T
```

### Global Task Configuration

Each task has it's own specific configuration which is documented below. Some tasks make use of global configuration which is described here.

#### Scopes

`CALLOUT_PARTICIPATION_RETRY_STATUSES` configures the phone call statuses in which to retry (defaults to `failed`). Used in the [CalloutParticipation.remaining scope](https://github.com/somleng/somleng-scfm/blob/master/app/models/callout_participation.rb), possible values are statuses defined in [PhoneCall](https://github.com/somleng/somleng-scfm/blob/master/app/models/phone_call.rb).

`PHONE_CALL_TIME_CONSIDERED_RECENTLY_CREATED_SECONDS` configures the age in seconds in which a phone call is considered recently created (defaults to `60`). Used in the [PhoneCall.not_recently_created scope](https://github.com/somleng/somleng-scfm/blob/master/app/models/phone_call.rb)

#### Somleng Configuration

`SOMLENG_CLIENT_REST_API_HOST` configures the REST API host to connect to Somleng (or Twilio) (defaults to `api.twilio.com`).

`SOMLENG_CLIENT_REST_API_BASE_URL` configures the REST API base url to connect to Somleng (or Twilio) (defaults to `https://api.twilio.com`).

`SOMLENG_ACCOUNT_SID` configures the Account SID for Somleng (or Twilio) (defaults to nil).

`SOMLENG_AUTH_TOKEN` configures the Auth Token for Somleng (or Twilio) (defaults to nil).

### Callouts

The [callouts task](https://github.com/somleng/somleng-scfm/blob/master/app/tasks/callouts_task.rb) performs various operations on callouts.

#### task:callouts:populate

Populates a callout with participations to call.

##### Task Configuration

`CALLOUTS_TASK_POPULATE_METADATA` configures the default metadata to be set on the callout participation when populating the callout (defaults to nil). For example, setting `CALLOUTS_TASK_POPULATE_METADATA="{\"foo\":\"bar\"}"` will populate the callout with participations containing the specified metadata. The metadata is default metadata only and can be overriden in [the task](https://github.com/somleng/somleng-scfm/blob/master/app/tasks/callouts_task.rb).

`CALLOUTS_TASK_CALLOUT_ID` tells the task which callout to populate. If `CALLOUTS_TASK_CALLOUT_ID` is not specified it's assumed there is only one callout in the database. If there are multiple an exception is raised.

By default callouts are populated with all the contacts in the Contacts table. Override the `contacts_to_populate_with` in the [task](https://github.com/somleng/somleng-scfm/blob/master/app/tasks/callouts_task.rb) to modify this behavior.

##### Example

```
$ CALLOUTS_TASK_POPULATE_METADATA="{}" CALLOUTS_TASK_CALLOUT_ID= bundle exec rake task:callouts:populate
```

#### task:callouts:run

*start*, *stop*, *pause* or *resume* a callout

##### Task Configuration

`CALLOUTS_TASK_ACTION` tells the script which action to perform. `CALLOUTS_TASK_ACTION` can be one of either `start`, `stop`, `pause` or `resume`.

`CALLOUTS_TASK_CALLOUT_ID` tells the task which callout to perform the action on. If `CALLOUTS_TASK_CALLOUT_ID` is not specified then it's assumed there is only one callout in the database. If there are multiple an exception is raised.

##### Example

```
$ CALLOUTS_TASK_ACTION="start|stop|pause|resume" CALLOUTS_TASK_CALLOUT_ID= bundle exec rake task:callouts:run
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

`ENQUEUE_CALLS_TASK_DEFAULT_SOMLENG_REQUEST_PARAMS` configures the default request params that will be sent to Somleng (or Twilio) when enqueuing a call (defaults to nil). Setting `ENQUEUE_CALLS_TASK_DEFAULT_SOMLENG_REQUEST_PARAMS="{\"from\":\"1234\",\"url\":\"http://demo.twilio.com/docs/voice.xml\",\"method\":\"GET\"}"` would send these params to Somleng (or Twilio) when enqueuing a phone call. These params are default params only and can be overriden in [the task](https://github.com/somleng/somleng-scfm/blob/master/app/tasks/enqueue_calls_task.rb).

##### Somleng (Twilio) Configuration

See [Somleng Configuration](#somleng-configuration)

##### Example

```
$ ENQUEUE_CALLS_TASK_MAX_CALLS_TO_ENQUEUE=30 ENQUEUE_CALLS_TASK_ENQUEUE_STRATEGY=optimistic ENQUEUE_CALLS_TASK_PESSIMISTIC_MIN_CALLS_TO_ENQUEUE=1 ENQUEUE_CALLS_TASK_MAX_CALLS_PER_PERIOD= ENQUEUE_CALLS_TASK_MAX_CALLS_PER_PERIOD_HOURS=24 ENQUEUE_CALLS_TASK_DEFAULT_SOMLENG_REQUEST_PARAMS="{\"from\":\"1234\",\"url\":\"http://demo.twilio.com/docs/voice.xml\",\"method\":\"GET\"}" bundle exec rake task:enqueue_calls:run
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
