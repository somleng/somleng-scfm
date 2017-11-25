# REST API Reference

Somleng SCFM provides a REST API for managing core resources. Below is the full documentation for the REST API. If you're new to Somleng SCFM we recommend that you read the [GETTING_STARTED](https://github.com/somleng/somleng-scfm/blob/master/docs/GETTING_STARTED.md) guide first.

## Prerequisites

Just like the [GETTING_STARTED](https://github.com/somleng/somleng-scfm/blob/master/docs/GETTING_STARTED.md) guide, the examples that follow assume that you are useing Somleng SCFM in SQLite mode with Docker. Please go ahead and [install Docker](https://docs.docker.com/engine/installation/) if you haven't already done so, then pull the latest image:

```
$ docker pull dwilkie/somleng-scfm
```

Setup a new database:

```
$ docker run --rm -v /tmp/somleng-scfm/db:/tmp/db -e RAILS_ENV=production -e RAILS_DB_ADAPTER=sqlite3 dwilkie/somleng-scfm /bin/bash -c 'bundle exec rake db:create && bundle exec rake db:migrate && if [ ! -f /tmp/db/somleng_scfm_production.sqlite3 ]; then cp /usr/src/app/db/somleng_scfm_production.sqlite3 /tmp/db; fi'
```

And boot the API Server:

```
$ docker run -it --rm -v /tmp/somleng-scfm/db:/usr/src/app/db -p 3000:3000 -h scfm --name somleng-scfm -e RAILS_ENV=production -e SECRET_KEY_BASE=secret -e RAILS_DB_ADAPTER=sqlite3 dwilkie/somleng-scfm /bin/bash -c 'bundle exec rails s'
```

## Contacts

### Create

```
$ docker run -t --rm --link somleng-scfm endeveit/docker-jq /bin/sh -c 'curl -s -XPOST http://scfm:3000/api/contacts --data-urlencode "msisdn=+252662345699" | jq'
```

Sample Response:

```json
{
  "id": 1,
  "msisdn": "+252662345699",
  "metadata": {},
  "created_at": "2017-11-23T05:22:07.519Z",
  "updated_at": "2017-11-23T05:22:07.519Z"
}
```

### Update

```
$ docker run -t --rm --link somleng-scfm endeveit/docker-jq /bin/sh -c 'curl -v -XPATCH http://scfm:3000/api/contacts/1 --data-urlencode "msisdn=+252662345700" -d "metadata[name]=Alice" -d "metadata[gender]=f"'
```

Sample Response:

```
< HTTP/1.1 204 No Content
```

### Fetch

```
$ docker run -t --rm --link somleng-scfm endeveit/docker-jq /bin/sh -c 'curl -s http://scfm:3000/api/contacts/1 | jq'
```

Sample Response:

```json
{
  "id": 1,
  "msisdn": "+252662345700",
  "metadata": {
    "name": "Alice",
    "gender": "f"
  },
  "created_at": "2017-11-23T05:22:07.519Z",
  "updated_at": "2017-11-23T05:26:14.983Z"
}
```

### Index and Filter

#### All Contacts

```
$ docker run -t --rm --link somleng-scfm endeveit/docker-jq /bin/sh -c 'curl -v -s http://scfm:3000/api/contacts | jq'
```

#### Filter by metadata

```
$ docker run -t --rm --link somleng-scfm endeveit/docker-jq /bin/sh -c 'curl -v -s -g http://scfm:3000/api/contacts?q[metadata][gender]=f | jq'
```

#### Filter by msisdn

```
$ docker run -t --rm --link somleng-scfm endeveit/docker-jq /bin/sh -c 'curl -v -s -g http://scfm:3000/api/contacts?q[msisdn]=252662345700 | jq'
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
    "msisdn": "+252662345700",
    "metadata": {
      "name": "Alice",
      "gender": "f"
    },
    "created_at": "2017-11-23T05:22:07.519Z",
    "updated_at": "2017-11-23T05:26:14.983Z"
  }
]
```

### Delete

Note that the the response is `204 No Content`

```
$ docker run -t --rm --link somleng-scfm endeveit/docker-jq /bin/sh -c 'curl -v -XDELETE http://scfm:3000/api/contacts/1'
```

Sample Response:

```
< HTTP/1.1 204 No Content
```

## Callouts

### Create

```
$ docker run -t --rm --link somleng-scfm endeveit/docker-jq /bin/sh -c 'curl -s -XPOST http://scfm:3000/api/callouts | jq'
```

Sample Response:

```json
{
  "id": 1,
  "status": "initialized",
  "call_flow_logic": null,
  "metadata": {},
  "created_at": "2017-11-23T05:32:25.773Z",
  "updated_at": "2017-11-23T05:32:25.773Z"
}
```

### Update

```
$ docker run -t --rm --link somleng-scfm endeveit/docker-jq /bin/sh -c 'curl -v -XPATCH http://scfm:3000/api/callouts/1 -d call_flow_logic=CallFlowLogic::Application -d "metadata[name]=my+callout"'
```

Sample Response:

```
< HTTP/1.1 204 No Content
```

### Fetch

```
$ docker run -t --rm --link somleng-scfm endeveit/docker-jq /bin/sh -c 'curl -s http://scfm:3000/api/callouts/1 | jq'
```

Sample Response:

```json
{
  "id": 1,
  "status": "initialized",
  "call_flow_logic": "CallFlowLogic::Application",
  "metadata": {
    "name": "my callout"
  },
  "created_at": "2017-11-23T05:32:25.773Z",
  "updated_at": "2017-11-23T05:34:33.218Z"
}
```

### Index and Filter

#### All Callouts

```
$ docker run -t --rm --link somleng-scfm endeveit/docker-jq /bin/sh -c 'curl -v -s http://scfm:3000/api/callouts | jq'
```

#### Filter by metadata

```
$ docker run -t --rm --link somleng-scfm endeveit/docker-jq /bin/sh -c 'curl -v -s -g http://scfm:3000/api/callouts?q[metadata][name]=my+callout | jq'
```

#### Filter by status

```
$ docker run -t --rm --link somleng-scfm endeveit/docker-jq /bin/sh -c 'curl -v -s -g http://scfm:3000/api/callouts?q[status]=initialized | jq'
```

#### Filter by call flow logic

```
$ docker run -t --rm --link somleng-scfm endeveit/docker-jq /bin/sh -c 'curl -v -s -g http://scfm:3000/api/callouts?q[call_flow_logic]=CallFlowLogic::Application | jq'
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
    "call_flow_logic": "CallFlowLogic::Application",
    "metadata": {
      "name": "my callout"
    },
    "created_at": "2017-11-23T05:32:25.773Z",
    "updated_at": "2017-11-23T05:34:33.218Z"
  }
]
```

### Events

#### Start

```
$ docker run -t --rm --link somleng-scfm endeveit/docker-jq /bin/sh -c 'curl -s -XPOST http://scfm:3000/api/callouts/1/callout_events -d "event=start" | jq'
```

#### Pause

```
$ docker run -t --rm --link somleng-scfm endeveit/docker-jq /bin/sh -c 'curl -s -XPOST http://scfm:3000/api/callouts/1/callout_events -d "event=pause" | jq'
```

#### Resume

```
$ docker run -t --rm --link somleng-scfm endeveit/docker-jq /bin/sh -c 'curl -s -XPOST http://scfm:3000/api/callouts/1/callout_events -d "event=resume" | jq'
```

#### Stop

```
$ docker run -t --rm --link somleng-scfm endeveit/docker-jq /bin/sh -c 'curl -s -XPOST http://scfm:3000/api/callouts/1/callout_events -d "event=stop" | jq'
```

Sample Response:

```json
{
  "id": 1,
  "status": "running",
  "call_flow_logic": "CallFlowLogic::Application",
  "metadata": {
    "name": "my callout"
  },
  "created_at": "2017-11-23T05:32:25.773Z",
  "updated_at": "2017-11-23T05:40:46.139Z"
}
```

### Delete

```
$ docker run -t --rm --link somleng-scfm endeveit/docker-jq /bin/sh -c 'curl -v -XDELETE http://scfm:3000/api/callouts/1
```

Sample Response:

```
< HTTP/1.1 204 No Content
```

## Callout Participations

### Create

```
$ docker run -t --rm --link somleng-scfm endeveit/docker-jq /bin/sh -c 'curl -s -XPOST http://scfm:3000/api/callouts/1/callout_participations -d "contact_id=1" | jq'
```

Sample Response:

```json
{
  "id": 1,
  "callout_id": 1,
  "contact_id": 1,
  "callout_population_id": null,
  "msisdn": "+252662345700",
  "call_flow_logic": null,
  "metadata": {},
  "created_at": "2017-11-25T03:28:16.151Z",
  "updated_at": "2017-11-25T03:28:16.151Z"
}
```

### Update

```
$ docker run -t --rm --link somleng-scfm endeveit/docker-jq /bin/sh -c 'curl -v -XPATCH http://scfm:3000/api/callout_participations/1 -d call_flow_logic=CallFlowLogic::Application -d "metadata[name]=my+callout+participation" -d "msisdn=252662345701"'
```

Sample Response:

```
< HTTP/1.1 204 No Content
```

### Fetch

```
$ docker run -t --rm --link somleng-scfm endeveit/docker-jq /bin/sh -c 'curl -s http://scfm:3000/api/callout_participations/1 | jq'
```

Sample Response:

```
{
  "id": 1,
  "callout_id": 1,
  "contact_id": 1,
  "callout_population_id": null,
  "msisdn": "+252662345701",
  "call_flow_logic": "CallFlowLogic::Application",
  "metadata": {
    "name": "my callout participation"
  },
  "created_at": "2017-11-25T03:28:16.151Z",
  "updated_at": "2017-11-25T03:55:01.439Z"
}
```

### Index and Filter

#### All Callout Participations

```
$ docker run -t --rm --link somleng-scfm endeveit/docker-jq /bin/sh -c 'curl -v -s http://scfm:3000/api/callout_participations | jq'
```

#### Filter by metadata

```
$ docker run -t --rm --link somleng-scfm endeveit/docker-jq /bin/sh -c 'curl -v -g -s http://scfm:3000/api/callout_participations?q[metadata][name]=my+callout+participation | jq'
```

#### Filter by callout

```
$ docker run -t --rm --link somleng-scfm endeveit/docker-jq /bin/sh -c 'curl -v -s http://scfm:3000/api/callouts/1/callout_participations | jq'
```

#### Filter by contact

```
$ docker run -t --rm --link somleng-scfm endeveit/docker-jq /bin/sh -c 'curl -v -g -s http://scfm:3000/api/contacts/1/callout_participations | jq'
```

#### Filter by msisdn

```
$ docker run -t --rm --link somleng-scfm endeveit/docker-jq /bin/sh -c 'curl -v -g -s http://scfm:3000/api/callout_participations?q[msisdn]=252662345700 | jq'
```

#### Filter by call flow logic

```
$ docker run -t --rm --link somleng-scfm endeveit/docker-jq /bin/sh -c 'curl -v -g -s http://scfm:3000/api/callout_participations?q[call_flow_logic]=CallFlowLogic::Application | jq'
```

#### Filter by callout participations which have phone calls

```
$ docker run -t --rm --link somleng-scfm endeveit/docker-jq /bin/sh -c 'curl -v -g -s http://scfm:3000/api/callout_participations?q[has_phone_calls]=true | jq'
```

#### Filter by callout participations which have no phone calls

```
$ docker run -t --rm --link somleng-scfm endeveit/docker-jq /bin/sh -c 'curl -v -g -s http://scfm:3000/api/callout_participations?q[has_phone_calls]=false | jq'
```

#### Filter by callout participations where the last phone call attempt was failed or errored

```
$ docker run -t --rm --link somleng-scfm endeveit/docker-jq /bin/sh -c 'curl -v -g -s http://scfm:3000/api/callout_participations?q[last_phone_call_attempt]=failed,errored | jq'
```

#### Filter by callout participations which have no phone calls OR the last phone call attempt was failed or errored

```
$ docker run -t --rm --link somleng-scfm endeveit/docker-jq /bin/sh -c 'curl -v -g -s http://scfm:3000/api/callout_participations?q[no_phone_calls_or_last_attempt]=failed,errored | jq'
```

Sample Response:

```
< Per-Page: 25
< Total: 1
```

```
[
  {
    "id": 1,
    "callout_id": 1,
    "contact_id": 1,
    "callout_population_id": null,
    "msisdn": "+252662345701",
    "call_flow_logic": "CallFlowLogic::Application",
    "metadata": {
      "name": "my callout participation"
    },
    "created_at": "2017-11-25T03:28:16.151Z",
    "updated_at": "2017-11-25T03:55:01.439Z"
  }
]
```

### Delete

```
$ docker run -t --rm --link somleng-scfm endeveit/docker-jq /bin/sh -c 'curl -v -XDELETE http://scfm:3000/api/callout_participations/1
```

Sample Response:

```
< HTTP/1.1 204 No Content
```

## Phone Calls

### Create

### Update

### Fetch

### Index

### Filter

### Delete

## Remote Phone Call Events

### Create

### Update

### Fetch

### Index

### Filter

### Delete

## Batch Operations

### Create (CalloutPopulation)

```
$ curl -XPOST http://localhost:3000/api/callouts/1/callout_populations \
  -d "metadata[foo]=bar" \
  -d "metadata[bar]=baz" \
  -d "contact_filter_params[metadata][location]=phnom+penh"
```

```json
{
  "id": 1,
  "callout_id": 1,
  "contact_filter_params": {
    "metadata": {
      "location": "phnom penh"
    }
  },
  "metadata": {
    "foo": "bar",
    "bar": "baz"
  },
  "status": "preview",
  "created_at": "2017-11-08T09:04:02.346Z",
  "updated_at": "2017-11-08T09:04:02.346Z"
}
```

### Create (PhoneCall::Create)

### Create (PhoneCall::Queue)

### Create (PhoneCall::QueueRemoteFetch)

### Update

```
$ curl -v -XPATCH http://localhost:3000/api/callout_populations/1 \
  -d "metadata[foo]=baz" \
  -d "metadata[baz]=foo" \
  -d "contact_filter_params[metadata][location]=battambang"
```

```
< HTTP/1.1 204 No Content
```
### Fetch

```
$ curl http://localhost:3000/api/batch_operations/1
```

```json
{
  "id": 1,
  "callout_id": 1,
  "contact_filter_params": {
    "metadata": {
      "gender": "f"
    }
  },
  "metadata": {},
  "status": "populated",
  "created_at": "2017-11-10T09:52:10.116Z",
  "updated_at": "2017-11-10T10:40:29.097Z"
}
```

### Index

```
$ curl http://localhost:3000/api/callout_populations
```

```
< HTTP/1.1 200 OK
< Per-Page: 25
< Total: 1
```

```json
[
  {
    "id": 1,
    "callout_id": 1,
    "contact_filter_params": {
      "metadata": {
        "location": "phnom penh"
      }
    },
    "metadata": {
      "foo": "bar",
      "bar": "baz"
    },
    "status": "preview",
    "created_at": "2017-11-08T09:04:02.346Z",
    "updated_at": "2017-11-08T09:04:02.346Z"
  }
]
```

### Index for a Callout

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
      "metadata": {
        "location": "phnom penh"
      }
    },
    "metadata": {
      "foo": "bar",
      "bar": "baz"
    },
    "status": "preview",
    "created_at": "2017-11-08T09:04:02.346Z",
    "updated_at": "2017-11-08T09:04:02.346Z"
  }
]
```

### Filter by parameters

```
$ curl -g "http://localhost:3000/api/callout_populations?q[contact_filter_params][metadata][location]=phnom+penh"
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

### Filter by metadata

```
$ curl -g "http://localhost:3000/api/callout_populations?q[metadata][foo]=bar"
```

Sample Response:

```json
[
  {
    "id": 1,
    "callout_id": 1,
    "contact_filter_params": {
      "metadata": {
        "location": "phnom penh"
      }
    },
    "metadata": {
      "foo": "bar",
      "bar": "baz"
    },
    "status": "preview",
    "created_at": "2017-11-08T09:04:02.346Z",
    "updated_at": "2017-11-08T09:04:02.346Z"
  }
]
```

### Events (Queue)

This enqueues a callout population to be populated with callout participations

```
$ curl -XPOST http://localhost:3000/api/callout_populations/1/callout_population_events \
  -d "event=queue"
```

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
  "status": "queued",
  "created_at": "2017-11-08T02:59:10.898Z",
  "updated_at": "2017-11-08T02:59:27.053Z"
}
```

### Events (Requeue)

This requeues a callout population to be populated with callout participations

```
$ curl -XPOST http://localhost:3000/api/callout_populations/1/callout_population_events \
  -d "event=requeue"
```

```json
{
  "id": 1,
  "callout_id": 1,
  "contact_filter_params": {
    "metadata": {
      "gender": "f"
    }
  },
  "metadata": {},
  "status": "queued",
  "created_at": "2017-11-10T09:52:10.116Z",
  "updated_at": "2017-11-10T11:06:10.964Z"
}
```

### Delete

Note the response is `204 No Content`

```
$ curl -v -XDELETE http://localhost:3000/api/callout_populations/1
```

Sample Response:

```
< HTTP/1.1 204 No Content
```
