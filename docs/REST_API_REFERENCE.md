# REST API Reference

Somleng SCFM provides a REST API for managing core resources. Below is the full documentation for the REST API.

## Authentication

HTTP Basic Authentication is supported out of the box. To enable HTTP Basic Authentication set the following environment variable:

```
HTTP_BASIC_AUTH_USER=api-user
```

Optionally you can set `HTTP_BASIC_AUTH_PASSWORD` to enable username and password authentication.

## Contacts

### Create a Contact

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

### List all Contacts

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

### List all Contacts (fitering by metadata)

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

### List all Contacts (fitering by msisdn)

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

### Get a Contact

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

### Update a Contact

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

### Delete a Contact

Note the response is `204 No Content`

```
$ curl -v -XDELETE http://localhost:3000/api/contacts/1
```

Sample Response:

```
< HTTP/1.1 204 No Content
```

## Callouts

### Create a Callout

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

### List all Callouts

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

### List all Callouts (filtering by metadata)

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

### List all Callouts (filtering by status)

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

### Get a Callout

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

### Update a Callout

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

### Start a Callout

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

### Pause a Callout

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

### Resume a Callout

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

### Stop a Callout

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

### Get Callout Statistics

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

### Delete a Callout

Note the response is `204 No Content`

```
$ curl -v -XDELETE http://localhost:3000/api/callouts/1
```

Sample Response:

```
< HTTP/1.1 204 No Content
```

## Callout Populations

### Create a Callout Population

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

### List all Callout Populations for a given callout

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

### List all Callout Populations (across all callouts)

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

### List all Callout Populations (filtering by metadata)

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

### List all Callout Populations (filtering by contact_filter_params)

```
$ curl -g "http://localhost:3000/api/callout_populations?contact_filter_params[metadata][location]=phnom+penh"
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

### Get a Callout Population

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

### Preview the contacts that will be participating in the callout if populated now

Note that the response is paginated.

```
$ curl -v  http://localhost:3000/api/callout_populations/1/preview/contacts
```

Sample Response:

```
< HTTP/1.1 200 OK
< Per-Page: 25
< Total: 1

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

### Update a Callout Population

Note the response is `204 No Content`

```
$ curl -v -XPUT http://localhost:3000/api/callout_populations/1 \
  -d "metadata[foo]=baz" \
  -d "metadata[baz]=foo" \
  -d "contact_filter_params[metadata][location]=battambang"
```

Sample Response:

```
< HTTP/1.1 204 No Content
```

### Delete a Callout Population

Note the response is `204 No Content`

```
$ curl -v -XDELETE http://localhost:3000/api/callout_populations/1
```

Sample Response:

```
< HTTP/1.1 204 No Content
```

### Enqueue a Callout Population for populating with callout participants

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

### List the contacts in the callout population

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
