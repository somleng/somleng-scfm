# REST API Reference

Somleng SCFM provides a REST API for managing core resources. Below is the full documentation for the REST API.

## Authentication

HTTP Basic Authentication is supported out of the box. To enable HTTP Basic Authentication set the following environment variable:

```
HTTP_BASIC_AUTH_USER=api-user
```

Optionally you can set `HTTP_BASIC_AUTH_PASSWORD` to enable username and password authentication.

## Contacts

### Create

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

### List

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

### Filter by metadata

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

### Filter by msisdn

```
$ curl -g "http://localhost:3000/api/contacts?q[msisdn]=85510202101"
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

### Fetch

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

### Update

Note that the response is `204 No Content`

```
$ curl -v -XPATCH http://localhost:3000/api/contacts/1 \
  --data-urlencode "msisdn=+85510202102" \
  -d "metadata[foo]=baz" \
  -d "metadata[baz]=foo"
```

Sample Response:

```
< HTTP/1.1 204 No Content
```

### Delete

Note that the the response is `204 No Content`

```
$ curl -v -XDELETE http://localhost:3000/api/contacts/1
```

Sample Response:

```
< HTTP/1.1 204 No Content
```

## Callouts

### Create

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

### List

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

### Filter by metadata

```
$ curl -g "http://localhost:3000/api/callouts?q[metadata][foo]=bar&q[metadata][bar]=baz"
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

### Filter by status

```
$ curl -g "http://localhost:3000/api/callouts?q[status]=initialized"
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

### Fetch

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

### Update

Note that the response is `204 No Content`

```
$ curl -v -XPATCH http://localhost:3000/api/callouts/1 \
  -d "metadata[foo]=baz" \
  -d "metadata[baz]=foo"
```

Sample Response:

```
< HTTP/1.1 204 No Content
```

### Start

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

### Pause

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

### Resume

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

### Stop

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

### List Participants

Note that the response is paginated.

```
$ curl -v /http://localhost:3000/api/callouts/1/contacts
```

Sample Response:

```
< Per-Page: 25
< Total: 2
```

```json
[
  {
    "id": 1,
    "msisdn": "+85510202101",
    "metadata": {
      "name": "Alice",
      "gender": "f"
    },
    "created_at": "2017-11-10T09:50:15.301Z",
    "updated_at": "2017-11-10T09:50:27.928Z"
  },
  {
    "id": 2,
    "msisdn": "+85510202102",
    "metadata": {
      "name": "Bob",
      "gender": "m"
    },
    "created_at": "2017-11-10T09:50:46.118Z",
    "updated_at": "2017-11-10T09:50:46.118Z"
  }
]
```

### Get Statistics (Deprecated)

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

### Delete

Note that the response is `204 No Content`

```
$ curl -v -XDELETE http://localhost:3000/api/callouts/1
```

Sample Response:

```
< HTTP/1.1 204 No Content
```

## Callout Populations

### Create

```
$ curl -XPOST http://localhost:3000/api/callouts/1/callout_populations \
  -d "metadata[foo]=bar" \
  -d "metadata[bar]=baz" \
  -d "contact_filter_params[metadata][location]=phnom+penh"
```

Sample Response:

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

### List

Note that the response is paginated.

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

### List for a Callout

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

### Filter by contact_filter_params

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

### Fetch

```
$ curl http://localhost:3000/api/callout_populations/1
```

Sample Response:

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

### Preview Population

Note that the response is paginated.

```
$ curl -v  http://localhost:3000/api/callout_populations/1/preview/contacts
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
      "location": "phnom penh"
    },
    "created_at": "2017-11-08T08:55:51.477Z",
    "updated_at": "2017-11-08T08:56:23.752Z"
  }
]
```

### Update

Note that the response is `204 No Content`

```
$ curl -v -XPATCH http://localhost:3000/api/callout_populations/1 \
  -d "metadata[foo]=baz" \
  -d "metadata[baz]=foo" \
  -d "contact_filter_params[metadata][location]=battambang"
```

Sample Response:

```
< HTTP/1.1 204 No Content
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

### Populate

This enqueues a callout population to be populated with callout participations

```
$ curl -XPOST http://localhost:3000/api/callout_populations/1/callout_population_events \
  -d "event=queue"
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
  "status": "queued",
  "created_at": "2017-11-08T02:59:10.898Z",
  "updated_at": "2017-11-08T02:59:27.053Z"
}
```

### Repopulate

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

### List the contacts populated

Note that the response is paginated.

```
$ curl http://localhost:3000/api/callout_populations/1/contacts
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

## Callout Participations

### Create

```
$ curl -XPOST http://localhost:3000/api/callouts/1/callout_participations \
  -d "contact_id=1"
```

Sample Response:

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

### List

Note that the response is paginated.

```
$ curl -v http://localhost:3000/api/callouts/1/callout_participations
```

Sample Response:

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

### Delete

Note that the response is `204 No Content`

```
$ curl -v -XDELETE http://localhost:3000/api/callout_participations/2
```

```
< HTTP/1.1 204 No Content
```
