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

Note that the response is `204 No Content`

```
$ docker run -t --rm --link somleng-scfm endeveit/docker-jq /bin/sh -c 'curl -v -XPATCH http://scfm:3000/api/contacts/1 --data-urlencode "msisdn=+252662345700" -d "metadata[name]=Alice" -d "metadata[gender]=f"'
```

```
< HTTP/1.1 204 No Content
```

### Fetch

```
$ docker run -t --rm --link somleng-scfm endeveit/docker-jq /bin/sh -c 'curl -s http://scfm:3000/api/contacts/1 | jq'
```

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

### Index

Note that the response is paginated.

```
$ docker run -t --rm --link somleng-scfm endeveit/docker-jq /bin/sh -c 'curl -v -s http://scfm:3000/api/contacts | jq'
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

Sample Response:

### Filter by metadata

Note that the response is paginated.

```
$ docker run -t --rm --link somleng-scfm endeveit/docker-jq /bin/sh -c 'curl -v -s -g http://scfm:3000/api/contacts?q[metadata][gender]=f | jq'
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

### Filter by msisdn

Note that the response is paginated.

```
$ docker run -t --rm --link somleng-scfm endeveit/docker-jq /bin/sh -c 'curl -v -s -g http://scfm:3000/api/contacts?q[msisdn]=252662345700 | jq'
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

```
< HTTP/1.1 204 No Content
```

## Callouts

### Create

```
$ docker run -t --rm --link somleng-scfm endeveit/docker-jq /bin/sh -c 'curl -s -XPOST http://scfm:3000/api/callouts | jq'
```

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

Note that the response is `204 No Content`

```
$ docker run -t --rm --link somleng-scfm endeveit/docker-jq /bin/sh -c 'curl -v -XPATCH http://scfm:3000/api/callouts/1 -d call_flow_logic=CallFlowLogic::Application -d "metadata[name]=my+callout"'
```

```
< HTTP/1.1 204 No Content
```

### Fetch

```
$ docker run -t --rm --link somleng-scfm endeveit/docker-jq /bin/sh -c 'curl -s http://scfm:3000/api/callouts/1 | jq'
```

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

### Index

Note that the response is paginated.

```
$ docker run -t --rm --link somleng-scfm endeveit/docker-jq /bin/sh -c 'curl -v -s http://scfm:3000/api/callouts | jq'
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

### Filter by metadata

Note that the response is paginated.

```
$ docker run -t --rm --link somleng-scfm endeveit/docker-jq /bin/sh -c 'curl -v -s -g http://scfm:3000/api/callouts?q[metadata][name]=my+callout | jq'
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

### Filter by status

Note that the response is paginated.

```
$ docker run -t --rm --link somleng-scfm endeveit/docker-jq /bin/sh -c 'curl -v -s -g http://scfm:3000/api/callouts?q[status]=initialized | jq'
```

```
< HTTP/1.1 200 OK
< Per-Page: 25
< Total: 1
```

Sample Response:

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

### Filter by call_flow_logic

Note that the response is paginated.

```
$ docker run -t --rm --link somleng-scfm endeveit/docker-jq /bin/sh -c 'curl -v -s -g http://scfm:3000/api/callouts?q[call_flow_logic]=CallFlowLogic::Application | jq'
```

```
< HTTP/1.1 200 OK
< Per-Page: 25
< Total: 1
```

Sample Response:

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

### Events (Start)

```
$ docker run -t --rm --link somleng-scfm endeveit/docker-jq /bin/sh -c 'curl -s -XPOST http://scfm:3000/api/callouts/1/callout_events -d "event=start" | jq'
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

### Events (Pause)

```
$ docker run -t --rm --link somleng-scfm endeveit/docker-jq /bin/sh -c 'curl -s -XPOST http://scfm:3000/api/callouts/1/callout_events -d "event=pause" | jq'
```

```json
{
  "id": 1,
  "status": "paused",
  "call_flow_logic": "CallFlowLogic::Application",
  "metadata": {
    "name": "my callout"
  },
  "created_at": "2017-11-23T05:32:25.773Z",
  "updated_at": "2017-11-23T05:41:11.264Z"
}
```

### Events (Resume)

```
$ docker run -t --rm --link somleng-scfm endeveit/docker-jq /bin/sh -c 'curl -s -XPOST http://scfm:3000/api/callouts/1/callout_events -d "event=resume" | jq'
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
  "updated_at": "2017-11-23T05:41:35.727Z"
}
```

### Events (Stop)

```
$ docker run -t --rm --link somleng-scfm endeveit/docker-jq /bin/sh -c 'curl -s -XPOST http://scfm:3000/api/callouts/1/callout_events -d "event=stop" | jq'
```

```json
{
  "id": 1,
  "status": "stopped",
  "call_flow_logic": "CallFlowLogic::Application",
  "metadata": {
    "name": "my callout"
  },
  "created_at": "2017-11-23T05:32:25.773Z",
  "updated_at": "2017-11-23T05:42:00.691Z"
}
```

### Delete

Note that the response is `204 No Content`

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
$ curl -XPOST http://localhost:3000/api/callouts/1/callout_participations \
  -d "contact_id=1"
```

```json
{
  "id": 3,
  "callout_id": 1,
  "contact_id": 1,
  "callout_population_id": 1,
  "msisdn": "+85510202101",
  "metadata": {},
  "created_at": "2017-11-10T10:40:29.083Z",
  "updated_at": "2017-11-10T10:40:29.083Z"
}
```

### Update

Note that the response is `204 No Content`

```
$ curl -v -XPATCH http://localhost:3000/api/callout_participations/2 \
  -d "metadata[foo]=baz" \
  -d "metadata[baz]=foo"
```

```
< HTTP/1.1 204 No Content
```

### Fetch

```
$ curl http://localhost:3000/api/callout_participations/2
```

Sample Response:

```
{
  "id": 2,
  "callout_id": 1,
  "contact_id": 2,
  "callout_population_id": null,
  "msisdn": "+85510202102",
  "metadata": {},
  "created_at": "2017-11-10T10:21:24.395Z",
  "updated_at": "2017-11-10T10:21:24.395Z"
}
```

### Index

Note that the response is paginated.

```
$ curl -v http://localhost:3000/api/callouts/1/callout_participations
```

```
< Per-Page: 25
< Total: 2
```

```
[
  {
    "id": 3,
    "callout_id": 1,
    "contact_id": 1,
    "callout_population_id": 1,
    "msisdn": "+85510202101",
    "metadata": {},
    "created_at": "2017-11-10T10:40:29.083Z",
    "updated_at": "2017-11-10T10:40:29.083Z"
  },
  {
    "id": 2,
    "callout_id": 1,
    "contact_id": 2,
    "callout_population_id": null,
    "msisdn": "+85510202102",
    "metadata": {},
    "created_at": "2017-11-10T10:21:24.395Z",
    "updated_at": "2017-11-10T10:21:24.395Z"
  }
]
```

### Filter by metadata

Note that the response is paginated.

```
$ curl -v -g "http://localhost:3000/api/callouts/1/callout_participations?q[metadata][foo]=baz"
```

Sample Response:

```
< Per-Page: 25
< Total: 1
```

```json
[
  {
    "id": 2,
    "callout_id": 1,
    "contact_id": 2,
    "callout_population_id": null,
    "msisdn": "+85510202102",
    "metadata": {
      "foo": "baz",
      "baz": "foo"
    },
    "created_at": "2017-11-10T10:21:24.395Z",
    "updated_at": "2017-11-10T11:24:47.143Z"
  }
]
```

### Filter by contact_id

Note that the response is paginated.

```
$ curl -v -g "http://localhost:3000/api/callouts/1/callout_participations?q[contact_id]=2"
```

Sample Response:

```
< Per-Page: 25
< Total: 1
```

```json
[
  {
    "id": 2,
    "callout_id": 1,
    "contact_id": 2,
    "callout_population_id": null,
    "msisdn": "+85510202102",
    "metadata": {},
    "created_at": "2017-11-10T10:21:24.395Z",
    "updated_at": "2017-11-10T10:21:24.395Z"
  }
]
```

### Delete

Note that the response is `204 No Content`

```
$ curl -v -XDELETE http://localhost:3000/api/callout_participations/2
```

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

Note that the response is `204 No Content`

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

Note that the response is paginated.

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

Note that the response is paginated.

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
