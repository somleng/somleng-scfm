# Usage

## Concepts and Terminology

Somleng SCFM is build around the following key concepts.

### Contacts

A [contact](https://github.com/somleng/somleng-scfm/blob/master/app/models/contact.rb) represents a person who has a [msisdn (aka: phone number)](https://en.wikipedia.org/wiki/MSISDN). Contacts are uniquely indexed by their msisdn. You cannot create two contacts with the same msisdn. Contacts can be created with custom metadata.

### Callouts

A [callout](https://github.com/somleng/somleng-scfm/blob/master/app/models/callout.rb) represents a collection of contacts that need to be called for a particular purpose. For example, you might create a callout to notify your customers of a new product. A callout has a status and can be *started*, *stopped*, *paused* or *resumed*.

### Callout Populations

A [callout population](https://github.com/somleng/somleng-scfm/blob/master/app/models/callout_population.rb) represents the population of a callout with participants. For example, you might create a callout population for only a subset of your customers that live in a certain area. You can inspect the callout population to see who will be called before populating it. A callout population has a status and can be *preview*, *populated*.

### Callout Participations

A [callout participation](https://github.com/somleng/somleng-scfm/blob/master/app/models/callout_participation.rb) represents a contact who needs to be called for a particular callout. One callout participation may have have multiple phone calls. Callout participations are uniquely indexed by the callout and contact. You cannot create two callout participations with the same callout and contact.

### Phone Calls

A [phone call](https://github.com/somleng/somleng-scfm/blob/master/app/models/phone_call.rb) represents a single attempt at a phone call. A phone call has a status which represents the outcome of the phone call. There may be muliple phone calls for single participation on a callout.

## Databases

Somleng SCFM currently supports [SQLite](https://www.sqlite.org/) and [PostgreSQL](https://www.postgresql.org/). If you want to test things out locally using Docker feel free to use the SQLite. For production we recommend using PostgreSQL.

## REST API

Somleng SCFM provides a REST API for managing the core resources listed above. Below is the documentation for the REST API.

### Authentication

HTTP Basic Authentication is supported out of the box. To enable HTTP Basic Authentication set the following environment variable:

```
HTTP_BASIC_AUTH_USER=api-user
```

Optionally you can set `HTTP_BASIC_AUTH_PASSWORD` to enable username and password authentication.

### Contacts

#### Create a Contact

```
$ curl -XPOST http://localhost:3000/api/contacts \
  --data-urlencode "msisdn=+85510202101" \
  -d "metadata[foo]=bar" \
  -d "metadata[bar]=baz"
```

Sample Response:

```json
{
  "id": 1,
  "msisdn": "+85510202101",
  "metadata": {
    "foo": "bar",
    "bar": "baz"
  },
  "created_at": "2017-11-07T08:34:25.880Z",
  "updated_at": "2017-11-07T08:34:25.880Z"
}
```

#### List all Contacts

Note that the response is paginated.

```
$ curl -v http://localhost:3000/api/contacts
```

Sample Response:

```
< HTTP/1.1 200 OK
< Per-Page: 25
< Total: 1
```

```json
[
  {
    "id": 1,
    "msisdn": "+85510202101",
    "metadata": {
      "foo": "bar",
      "bar": "baz"
    },
    "created_at": "2017-11-07T08:34:25.880Z",
    "updated_at": "2017-11-07T08:34:25.880Z"
  }
]
```

#### List all Contacts (fitering by metadata)

```
$ curl -g "http://localhost:3000/api/contacts?metadata[foo]=bar&metadata[bar]=baz"
```

Sample Response:

```json
[
  {
    "id": 1,
    "msisdn": "+85510202101",
    "metadata": {
      "foo": "bar",
      "bar": "baz"
    },
    "created_at": "2017-11-07T08:34:25.880Z",
    "updated_at": "2017-11-07T08:34:25.880Z"
  }
]
```

#### List all Contacts (fitering by msisdn)

```
$ curl -g "http://localhost:3000/api/contacts?msisdn=85510202101"
```

Sample Response:

```json
[
  {
    "id": 1,
    "msisdn": "+85510202101",
    "metadata": {
      "foo": "bar",
      "bar": "baz"
    },
    "created_at": "2017-11-07T08:34:25.880Z",
    "updated_at": "2017-11-07T08:34:25.880Z"
  }
]
```

#### Get a Contact

```
$ curl http://localhost:3000/api/contacts/1
```

Sample Response:

```json
{
  "id": 1,
  "msisdn": "+85510202101",
  "metadata": {
    "foo": "bar",
    "bar": "baz"
  },
  "created_at": "2017-11-07T08:34:25.880Z",
  "updated_at": "2017-11-07T08:34:25.880Z"
}
```

#### Update a Contact

Note the response is `204 No Content`

```
$ curl -v -XPUT http://localhost:3000/api/contacts/1 \
  --data-urlencode "msisdn=+85510202102" \
  -d "metadata[foo]=baz" \
  -d "metadata[baz]=foo"
```

Sample Response:

```
< HTTP/1.1 204 No Content
```

#### Delete a Contact

Note the response is `204 No Content`

```
$ curl -v -XDELETE http://localhost:3000/api/contacts/1
```

Sample Response:

```
< HTTP/1.1 204 No Content
```

### Callouts

#### Create a Callout

```
$ curl -XPOST http://localhost:3000/api/callouts \
  -d "metadata[foo]=bar" \
  -d "metadata[bar]=baz"
```

Sample Response:

```json
{
  "id": 1,
  "status": "initialized",
  "metadata": {
    "foo": "bar",
    "bar": "baz"
  },
  "created_at": "2017-11-07T05:11:24.772Z",
  "updated_at": "2017-11-07T05:11:24.772Z"
}
```

#### List all Callouts

Note that the response is paginated.

```
$ curl -v http://localhost:3000/api/callouts
```

Sample Response:

```
< HTTP/1.1 200 OK
< Per-Page: 25
< Total: 1
```

```json
[
  {
    "id": 1,
    "status": "initialized",
    "metadata": {
      "foo": "bar",
      "bar": "baz"
    },
    "created_at": "2017-11-07T05:29:13.935Z",
    "updated_at": "2017-11-07T05:29:13.935Z"
  }
]
```

#### List all Callouts (filtering by metadata)

```
$ curl -g "http://localhost:3000/api/callouts?metadata[foo]=bar&metadata[bar]=baz"
```

Sample Response:

```json
[
  {
    "id": 1,
    "status": "initialized",
    "metadata": {
      "foo": "bar",
      "bar": "baz"
    },
    "created_at": "2017-11-07T05:53:03.370Z",
    "updated_at": "2017-11-07T05:53:03.370Z"
  }
]
```

#### List all Callouts (filtering by status)

```
$ curl -g "http://localhost:3000/api/callouts?status=initialized"
```

Sample Response:

```json
[
  {
    "id": 1,
    "status": "initialized",
    "metadata": {
      "foo": "bar",
      "bar": "baz"
    },
    "created_at": "2017-11-07T05:53:03.370Z",
    "updated_at": "2017-11-07T05:53:03.370Z"
  }
]
```

#### Get a Callout

```
$ curl http://localhost:3000/api/callouts/1
```

Sample Response:

```json
{
  "id": 1,
  "status": "initialized",
  "metadata": {
    "foo": "bar",
    "bar": "baz"
  },
  "created_at": "2017-11-07T05:29:13.935Z",
  "updated_at": "2017-11-07T05:29:13.935Z"
}
```

#### Update a Callout

Note the response is `204 No Content`

```
$ curl -v -XPUT http://localhost:3000/api/callouts/1 \
  -d "metadata[foo]=baz" \
  -d "metadata[baz]=foo"
```

Sample Response:

```
< HTTP/1.1 204 No Content
```

#### Start a Callout

```
$ curl -XPOST http://localhost:3000/api/callouts/1/callout_events \
  -d "event=start"
```

Sample Response:

```json
{
  "id": 1,
  "status": "running",
  "metadata": {
    "foo": "baz",
    "baz": "foo"
  },
  "created_at": "2017-11-07T05:11:24.772Z",
  "updated_at": "2017-11-07T05:17:33.823Z"
}
```

#### Pause a Callout

```
$ curl -XPOST http://localhost:3000/api/callouts/1/callout_events \
  -d "event=pause"
```

Sample Response:

```json
{
  "id": 1,
  "status": "paused",
  "metadata": {
    "foo": "baz",
    "baz": "foo"
  },
  "created_at": "2017-11-07T05:29:13.935Z",
  "updated_at": "2017-11-07T05:31:31.297Z"
}
```

#### Resume a Callout

```
$ curl -XPOST http://localhost:3000/api/callouts/1/callout_events \
  -d "event=resume"
```

Sample Response:

```json
{
  "id": 1,
  "status": "running",
  "metadata": {
    "foo": "baz",
    "baz": "foo"
  },
  "created_at": "2017-11-07T05:29:13.935Z",
  "updated_at": "2017-11-07T05:31:49.596Z"
}
```

#### Stop a Callout

```
$ curl -XPOST http://localhost:3000/api/callouts/1/callout_events \
  -d "event=stop"
```

Sample Response:

```json
{
  "id": 1,
  "status": "stopped",
  "metadata": {
    "foo": "baz",
    "baz": "foo"
  },
  "created_at": "2017-11-07T05:29:13.935Z",
  "updated_at": "2017-11-07T05:32:02.503Z"
}
```

#### Get Callout Statistics

```
$ curl http://localhost:3000/api/callouts/1/callout_statistics
```

Sample Response:

```json
{
  "callout_status": "initialized",
  "callout_participations": 0,
  "callout_participations_remaining": 0,
  "callout_participations_completed": 0,
  "calls_completed": 0,
  "calls_initialized": 0,
  "calls_scheduling": 0,
  "calls_fetching_status": 0,
  "calls_waiting_for_completion": 0,
  "calls_queued": 0,
  "calls_in_progress": 0,
  "calls_errored": 0,
  "calls_failed": 0,
  "calls_busy": 0,
  "calls_not_answered": 0,
  "calls_canceled": 0
}
```

#### Delete a Callout

Note the response is `204 No Content`

```
$ curl -v -XDELETE http://localhost:3000/api/callouts/1
```

Sample Response:

```
< HTTP/1.1 204 No Content
```

### Callout Populations

#### Create a Callout Population

```
$ curl -XPOST http://localhost:3000/api/callouts/1/callout_populations \
  -d "metadata[foo]=bar" \
  -d "metadata[bar]=baz" \
  -d "contact_filter_params[location]=phnom+penh"
```

Sample Response:

```json
{
  "id": 1,
  "callout_id": 1,
  "contact_filter_params": {
    "location": "phnom penh"
  },
  "metadata": {
    "foo": "bar",
    "bar": "baz"
  },
  "created_at": "2017-11-07T12:05:24.240Z",
  "updated_at": "2017-11-07T12:05:24.240Z"
}
```

#### List all Callout Populations for a given callout

```
$ curl http://localhost:3000/api/callouts/1/callout_populations
```

Sample Response:

```json
[
  {
    "id": 1,
    "callout_id": 1,
    "contact_filter_params": {
      "location": "phnom penh"
    },
    "metadata": {
      "foo": "bar",
      "bar": "baz"
    },
    "created_at": "2017-11-07T12:04:59.470Z",
    "updated_at": "2017-11-07T12:04:59.470Z"
  }
]
```

#### List all Callout Populations

```
$ curl http://localhost:3000/api/callout_populations
```

Sample Response:

```json
[
  {
    "id": 1,
    "callout_id": 1,
    "contact_filter_params": {
      "location": "phnom penh"
    },
    "metadata": {
      "foo": "bar",
      "bar": "baz"
    },
    "created_at": "2017-11-07T12:04:59.470Z",
    "updated_at": "2017-11-07T12:04:59.470Z"
  }
]
```

#### List all Callout Populations (filtering by metadata)

```
$ curl -g "http://localhost:3000/api/callout_populations?metadata[foo]=bar"
```

Sample Response:

```json
[
  {
    "id": 1,
    "callout_id": 1,
    "contact_filter_params": {
      "location": "phnom penh"
    },
    "metadata": {
      "foo": "bar",
      "bar": "baz"
    },
    "created_at": "2017-11-07T12:04:59.470Z",
    "updated_at": "2017-11-07T12:04:59.470Z"
  }
]
```

#### List all Callout Populations (filtering by contact_filter_params)

```
$ curl -g "http://localhost:3000/api/callout_populations?contact_filter_params[location]=phnom+penh"
```

Sample Response:

```json
[
  {
    "id": 1,
    "callout_id": 1,
    "contact_filter_params": {
      "location": "phnom penh"
    },
    "metadata": {
      "foo": "bar",
      "bar": "baz"
    },
    "created_at": "2017-11-07T12:04:59.470Z",
    "updated_at": "2017-11-07T12:04:59.470Z"
  }
]
```

#### Get a Callout Population

```
$ curl http://localhost:3000/api/callout_populations/1
```

Sample Response:

```json
{
  "id": 1,
  "callout_id": 1,
  "contact_filter_params": {
    "location": "phnom penh"
  },
  "metadata": {
    "foo": "bar",
    "bar": "baz"
  },
  "created_at": "2017-11-07T12:04:59.470Z",
  "updated_at": "2017-11-07T12:04:59.470Z"
}
```

#### Update a Callout Population

Note the response is `204 No Content`

```
$ curl -v -XPUT http://localhost:3000/api/callout_populations/1 \
  -d "metadata[foo]=baz" \
  -d "metadata[baz]=foo" \
  -d "contact_filter_params[location]=battambang"
```

Sample Response:

```
< HTTP/1.1 204 No Content
```

#### Delete a Callout Population

Note the response is `204 No Content`

```
$ curl -v -XDELETE http://localhost:3000/api/callout_populations/1
```

Sample Response:

```
< HTTP/1.1 204 No Content
```

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

#### 15. List available rake tasks (optional)

```
$ bundle exec rake -T
```

or using Docker

```
$ sudo docker run --rm -t -e RAILS_ENV=production dwilkie/somleng-scfm bundle exec rake -T
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

#### task:callouts:create

Creates a new callout and prints the callout id.

##### Task Configuration

`CALLOUTS_TASK_CREATE_METADATA` configures the default metadata to be set when creating a callout (defaults to nil). For example, setting `CALLOUTS_TASK_CREATE_METADATA="{\"foo\":\"bar\"}"` will create the callout with the specified metadata. The metadata is default metadata only and can be overriden in [the task](https://github.com/somleng/somleng-scfm/blob/master/app/tasks/callouts_task.rb).

##### Example

```
$ CALLOUTS_TASK_CREATE_METADATA="{}" bundle exec rake task:callouts:create
```

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
