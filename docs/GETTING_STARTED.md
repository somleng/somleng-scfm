# Getting Started

## Introduction

Let's start with an example. Suppose you are building a Disaster Alert System. When there's a flood in particular area and you want to call out to those who are affected and warn them of the impending danger. You also want to allow people to register with the system by calling into your service.

Somleng Simple Call Flow Manager (Somleng SCFM) provides a fully featured [REST API](https://github.com/somleng/somleng-scfm/blob/master/docs/REST_API_REFERENCE.md) to manage both your inbound and outbound call flows. In this guide we'll get you up and running using the REST API.

## Getting set up

For this tutorial we're going to use Somleng SCFM in SQLite mode with Docker. Note that this is not recommended for a production environment, but it's the easiest way to try things out.

### Prerequisites

#### Docker

If you haven't already done so, go ahead and [install Docker](https://docs.docker.com/engine/installation/). Then download the lastest image of Somleng SCFM.

```
$ docker pull dwilkie/somleng-scfm
```

#### Twilio Account

For the tutorial we're going to connect Somleng SCFM to Twilio. If you haven't already done so, go ahead and [create a Twilio Account](https://www.twilio.com/).

### Create a new SQLite Database

The first thing to do is create the database which will be used for keeping track of things. Go ahead and run the following command to get your database set up.

Note that this will create a new SQLite database called `somleng_scfm_production.sqlite3` on host machine in the directory `/tmp/somleng-scfm/db`. The docker examples in this tutorial mount the database directory at `/tmp/somleng-scfm/db`. Feel free to change it to whatever you want.

Run the following command:

```
$ docker run --rm -v /tmp/somleng-scfm/db:/tmp/db -e RAILS_ENV=production dwilkie/somleng-scfm /bin/bash -c 'bundle exec rake db:create && bundle exec rake db:migrate && if [ ! -f /tmp/db/somleng_scfm_production.sqlite3 ]; then cp /usr/src/app/db/somleng_scfm_production.sqlite3 /tmp/db; fi'
```

### Start the REST API Server

Now that the database has been created we can start the REST API Server.

Run the following command:

```
$ docker run -it --rm -v /tmp/somleng-scfm/db:/usr/src/app/db -p 3000:3000 -h scfm --name somleng-scfm -e RAILS_ENV=production -e SECRET_KEY_BASE=secret dwilkie/somleng-scfm /bin/bash -c 'bundle exec rails s'
```

Note that this command exposes port 3000 to your host. This will allow you to access the API at `http://localhost:3000/api`. Feel free to remove the `-p 3000:3000` option if you don't want to access the REST API from your host.

To test things out run the following command from another terminal:

```
$ docker run -t --rm --link somleng-scfm endeveit/docker-jq /bin/sh -c 'curl -s -v  http://scfm:3000/api/contacts | jq'
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

Note we used the `curl` and `jq` commands to execute the request, which are available in the `endeveit/docker-jq` container. Inside the container the REST API is available at `http://scfm:3000/api`. If you have `curl` and `jq` installed locally you could also run the above command like so:

```
$ curl -s -v http://localhost:3000/api/contacts | jq
```

The rest of the examples in this tutorial access the REST API from within a docker container. Feel free to access the API from your host if you like.

## Managing Contacts

Now that we're all set up, let's create some contacts in our database using the REST API. This will give us some people to call and also introduce the contacts API.

### Creating

The following command creates a new contact with the phone number (msisdn) `+85510202101`. Feel free to update the phone number to your number.

```
$ docker run -t --rm --link somleng-scfm endeveit/docker-jq /bin/sh -c 'curl -s -XPOST http://scfm:3000/api/contacts --data-urlencode "msisdn=+85510202101" | jq'
```

You should see something like:

```json
{
  "id": 1,
  "msisdn": "+85510202101",
  "metadata": {},
  "created_at": "2017-11-09T04:58:03.684Z",
  "updated_at": "2017-11-09T04:58:03.684Z"
}
```

Note that the only required field for a contact is a msisdn (aka phone number) which must be valid and must be unique.

### Updating

Our contact is a bit hard to identify, so let's give her a name and a gender.

```
$ docker run -t --rm --link somleng-scfm endeveit/docker-jq /bin/sh -c 'curl -XPATCH -v http://scfm:3000/api/contacts/1 -d "[metadata][name]=Alice" -d "[metadata][gender]=f"'
```

You should see something like:

```
...
> PATCH /api/contacts/1 HTTP/1.1
> Host: scfm:3000
> User-Agent: curl/7.51.0
> Accept: */*
> Content-Length: 22
> Content-Type: application/x-www-form-urlencoded
>
* upload completely sent off: 22 out of 22 bytes
< HTTP/1.1 204 No Content
< X-Frame-Options: SAMEORIGIN
< X-XSS-Protection: 1; mode=block
< X-Content-Type-Options: nosniff
< Cache-Control: no-cache
< X-Request-Id: d7a4ea73-9bc5-4b17-8d15-fefc6593f4ed
< X-Runtime: 0.007223
<
...
```

Notice that we ran this curl command with the `-v` flag. By default updating a resource successfully returns no content. The `-v` option on curl allows us to see the headers. In this case the response is `HTTP/1.1 204 No Content` which means that the contact was updated successfully.

### Fetching

If we want proof that our contact was really is the case we can fetch the contact:

```
$ docker run -t --rm --link somleng-scfm endeveit/docker-jq /bin/sh -c 'curl -s http://scfm:3000/api/contacts/1 | jq'
```

You should see something like:

```json
{
  "id": 1,
  "msisdn": "+85510202101",
  "metadata": {
    "name": "Alice",
    "gender": "f"
  },
  "created_at": "2017-11-09T04:58:03.684Z",
  "updated_at": "2017-11-09T05:13:49.414Z"
}
```

### Creating more contacts

Now that we have Alice in our contacts, let's add another one for Bob:

```
$ docker run -t --rm --link somleng-scfm endeveit/docker-jq /bin/sh -c 'curl -s -XPOST http://scfm:3000/api/contacts --data-urlencode "msisdn=+85510202102" -d "[metadata][name]=Bob" -d "[metadata][gender]=m" | jq'
```

Now you should see Bob:

```json
{
  "id": 2,
  "msisdn": "+85510202102",
  "metadata": {
    "name": "Bob",
    "gender": "m"
  },
  "created_at": "2017-11-09T05:18:59.858Z",
  "updated_at": "2017-11-09T05:18:59.858Z"
}
```

Now just for fun, let's add a third contact for the Ghostbusters.

```
$ docker run -t --rm --link somleng-scfm endeveit/docker-jq /bin/sh -c 'curl -s -XPOST http://scfm:3000/api/contacts --data-urlencode "msisdn=+85510202103" -d "metadata[name]=Ghostbusters" | jq'
```

Now you should see the Ghostbusters:

```json
{
  "id": 3,
  "msisdn": "+85510202103",
  "metadata": {
    "name": "Ghostbusters"
  },
  "created_at": "2017-11-09T05:24:07.618Z",
  "updated_at": "2017-11-09T05:24:07.618Z"
}
```

### Indexing

Let's see see who we have in our contacts table

```
$ docker run -t --rm --link somleng-scfm endeveit/docker-jq /bin/sh -c 'curl -v -s http://scfm:3000/api/contacts | jq'
```

```
...
> GET /api/contacts HTTP/1.1
> Host: scfm:3000
> User-Agent: curl/7.51.0
> Accept: */*
>
< HTTP/1.1 200 OK
< X-Frame-Options: SAMEORIGIN
< X-XSS-Protection: 1; mode=block
< X-Content-Type-Options: nosniff
< Per-Page: 25
< Total: 3
< Content-Type: application/json; charset=utf-8
< ETag: W/"f46af555c8c8195492f4e4e2b2bc8d6f"
< Cache-Control: max-age=0, private, must-revalidate
< X-Request-Id: 82e09347-a79a-4e38-b1ad-ac56212a7b33
< X-Runtime: 0.007498
< Transfer-Encoding: chunked
<
...
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
    "created_at": "2017-11-09T04:58:03.684Z",
    "updated_at": "2017-11-09T05:13:49.414Z"
  },
  {
    "id": 2,
    "msisdn": "+85510202102",
    "metadata": {
      "name": "Bob",
      "gender": "m"
    },
    "created_at": "2017-11-09T05:18:59.858Z",
    "updated_at": "2017-11-09T05:27:17.381Z"
  },
  {
    "id": 3,
    "msisdn": "+85510202103",
    "metadata": {
      "name": "Ghostbusters"
    },
    "created_at": "2017-11-09T05:24:07.618Z",
    "updated_at": "2017-11-09T05:24:07.618Z"
  }
]
```

Note that again we specified the `-v` flag to curl in order to get the headers. If you take a closer look at the headers you'll see `Per-Page: 25`and `Total: 3`. All index requests to the REST API are paginated. This means that the maxiumum number of contacts displayed for a single request is 25. The actual number will appear in the `Total` header (in this case 3). If there are more than 25 contacts then you'll see a `Link` header with links to the first, last, next and previous pages.

### Filtering

What if we only wanted to only return the contacts who are female?

```
$ docker run -t --rm --link somleng-scfm endeveit/docker-jq /bin/sh -c 'curl -v -s -g "http://scfm:3000/api/contacts?q[metadata][gender]=f" | jq'
```

```
< Per-Page: 25
< Total: 1
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
    "created_at": "2017-11-09T04:58:03.684Z",
    "updated_at": "2017-11-09T05:13:49.414Z"
  }
]
```

You can filter contacts by their metadata or by their msisdn (phone number).

### Deleting

Looking at our contact index, adding the Ghostbusters was just a joke so let's delete them.

```
$ docker run -t --rm --link somleng-scfm endeveit/docker-jq /bin/sh -c 'curl -XDELETE -v "http://scfm:3000/api/contacts/3"'
```

You should see something like:

```
...
> DELETE /api/contacts/3 HTTP/1.1
> Host: scfm:3000
> User-Agent: curl/7.51.0
> Accept: */*
>
< HTTP/1.1 204 No Content
< X-Frame-Options: SAMEORIGIN
< X-XSS-Protection: 1; mode=block
< X-Content-Type-Options: nosniff
< Cache-Control: no-cache
< X-Request-Id: b0ebec64-5c78-4cfd-b3f7-563c8d85388c
< X-Runtime: 0.022870
<
...
```

Similar to when updating resources, a successful delete returns `No Content` which can be seen in the headers above.

To double check that the Ghostbusters have been deleted you can try to fetch them:

```
$ docker run -t --rm --link somleng-scfm endeveit/docker-jq /bin/sh -c 'curl -v -s http://scfm:3000/api/contacts/3 | jq'
```

```
...
> GET /api/contacts/3 HTTP/1.1
> Host: scfm:3000
> User-Agent: curl/7.51.0
> Accept: */*
>
< HTTP/1.1 404 Not Found
< Content-Type: application/json; charset=UTF-8
< X-Request-Id: 3842fd04-011d-4b5c-aed0-0d9d4df7f7c1
< X-Runtime: 0.004426
< Content-Length: 34
<
...
```

```json
{
  "status": 404,
  "error": "Not Found"
}
```

Note that the response header is `404 Not Found`

## Managing Callouts

Now that we have some contacts in our database let's create a callout. A callout represents a collection of contacts to be called for a specific purpose.

### Creating

Let's go ahead and create a callout:

```
$ docker run -t --rm --link somleng-scfm endeveit/docker-jq /bin/sh -c 'curl -s -XPOST http://scfm:3000/api/callouts | jq'
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

Note that the callout's status is initialized. This is the initial state for a callout. Callouts can be either initialized, running, paused or stopped. More on this later.

## Populating a Callout

Right now our callout isn't very interesting. Let's change that by populating our callout with contacts.

### Create a Callout Population

In order to populate a callout we create what's called callout population. This will allow us to preview the contacts that will be called before actually queuing the population process. A callout population is a type of batch operation. A batch operation can be one of a few different types and can be previewed queued, and requeued for processing (more on this later).

Let's go ahead and create a batch operation for populating the callout. Take notice of the url in the command below `/api/callouts/1/batch_operations`. Here `1` is the id of the callout created in the previous step. We are creating a batch operation of type `BatchOperation::CalloutPopulation` on the the callout with the id `1`.

```
$ docker run -t --rm --link somleng-scfm endeveit/docker-jq /bin/sh -c 'curl -s -XPOST http://scfm:3000/api/callouts/1/batch_operations -d type=BatchOperation::CalloutPopulation | jq'
```

You should see something like:

```json
{
  "id": 1,
  "callout_id": 1,
  "parameters": {},
  "metadata": {},
  "status": "preview",
  "created_at": "2017-11-17T10:24:20.458Z",
  "updated_at": "2017-11-17T10:24:20.458Z"
}
```

Now that we have our callout population we can preview which contacts will participate in our callout.

Again, take notice of the url in the command below `/api/batch_operations/1/preview/contacts`. Here `1` is the id of the callout population created in the previous step. We are previewing the contacts in the callout population.

```
$ docker run -t --rm --link somleng-scfm endeveit/docker-jq /bin/sh -c 'curl -s -v http://scfm:3000/api/batch_operations/1/preview/contacts | jq'
```

You should see something like:

```
...
< Per-Page: 25
< Total: 2
...
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
    "created_at": "2017-11-09T04:58:03.684Z",
    "updated_at": "2017-11-09T05:13:49.414Z"
  },
  {
    "id": 2,
    "msisdn": "+85510202102",
    "metadata": {
      "name": "Bob",
      "gender": "m"
    },
    "created_at": "2017-11-09T05:18:59.858Z",
    "updated_at": "2017-11-09T05:27:17.381Z"
  }
]
```

We can see from the response that there's `Total` of `2` contacts in the preview. This means that if we were to populate this callout now, these two contacts would be participants in the callout. Incidentally these two contacts are all of our contacts in our contacts table. This is because by default, populating a callout without a contact filter will add all contacts to the callout.

### Limiting the contacts who will participate in the callout

Typically you don't want to call everyone in your contacts table. Let's say for this example that we only want to call females.

To do this let's update the callout population specifying the `contact_filter_params` which will limit our population of the callout. Note that the `contacts_filter_params` are nested under `parameters` attribute. A batch operation will have different configurable parameters depending on the type.

```
$ docker run -t --rm --link somleng-scfm endeveit/docker-jq /bin/sh -c 'curl -v -XPATCH http://scfm:3000/api/batch_operations/1 -d parameters[contact_filter_params][metadata][gender]=f'
```

Again since we're updating a record, a successful response will return `No Content`.

```
< HTTP/1.1 204 No Content
```

### Inspecting a callout population

Let's double check that our callout population was updated.

```
$ docker run -t --rm --link somleng-scfm endeveit/docker-jq /bin/sh -c 'curl -s http://scfm:3000/api/batch_operations/1 | jq'
```

You should see something like;

```json
{
  "id": 1,
  "callout_id": 1,
  "parameters": {
    "contact_filter_params": {
      "metadata": {
        "gender": "f"
      }
    }
  },
  "metadata": {},
  "status": "preview",
  "created_at": "2017-11-17T10:24:20.458Z",
  "updated_at": "2017-11-17T10:35:15.500Z"
}
```

We can see now that the `contact_filter_params` are populated with the paramters required to restrict the contacts to females only

Let's try the preview again.

```
$ docker run -t --rm --link somleng-scfm endeveit/docker-jq /bin/sh -c 'curl -s -v http://scfm:3000/api/batch_operations/1/preview/contacts | jq'
```

```
< Per-Page: 25
< Total: 1
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
    "created_at": "2017-11-09T04:58:03.684Z",
    "updated_at": "2017-11-09T05:13:49.414Z"
  }
]
```

Now we can see from the response that there's `Total` of `1` contacts in the preview, and that that contact is in-fact female.

### Queuing the callout for population

Once we're happy with our batch operation for populating the callout we can queue it for processing. This will take some time depending on how many participations need to be created.

```
$ docker run -t --rm --link somleng-scfm endeveit/docker-jq /bin/sh -c 'curl -s -XPOST http://scfm:3000/api/batch_operations/1/batch_operation_events -d "event=queue" | jq'
```

You should see something like:

```json
{
  "id": 1,
  "callout_id": 1,
  "parameters": {
    "contact_filter_params": {
      "metadata": {
        "gender": "f"
      }
    }
  },
  "metadata": {},
  "status": "queued",
  "created_at": "2017-11-17T10:24:20.458Z",
  "updated_at": "2017-11-17T10:39:24.759Z"
}
```

Notice that the status is now `queued`. In the background, Somleng SCFM is now busy populating your callout with callout participations. You can check the status of the population by fetching it again.

```
$ docker run -t --rm --link somleng-scfm endeveit/docker-jq /bin/sh -c 'curl -s http://scfm:3000/api/batch_operations/1 | jq'
```

You should see something like this:

```json
{
  "id": 1,
  "callout_id": 1,
  "parameters": {
    "contact_filter_params": {
      "metadata": {
        "gender": "f"
      }
    }
  },
  "metadata": {},
  "status": "finished",
  "created_at": "2017-11-17T10:24:20.458Z",
  "updated_at": "2017-11-17T10:39:25.073Z"
}
```

Notice that the status is now `finished`. This means that the batch operation has finished and you should now have participations in your callout.

Let's check the contacts that the batch operation added to our callout.

```
< Per-Page: 25
< Total: 1
```

```
$ docker run -t --rm --link somleng-scfm endeveit/docker-jq /bin/sh -c 'curl -v -s http://scfm:3000/api/batch_operations/1/contacts | jq'
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
  }
]
```

## Managing Callout Participations

Now that we have populated our callout we should have a bunch of callout participations. A callout participation represents one contact that will participate in the callout.

Let's see what callout participations we have in our callout.

Take notice of the url in the command below `/api/callouts/1/callout_participations`. Here `1` is the id of the callout, *not* the batch operation (although in this case the batch operation id may also have an id of `1`). Here we are fetching the participations in the callout.

```
$ docker run -t --rm --link somleng-scfm endeveit/docker-jq /bin/sh -c 'curl -v -s http://scfm:3000/api/callouts/1/callout_participations | jq'
```

You should see something like:

```
< Per-Page: 25
< Total: 1
```

```json
[
  {
    "id": 1,
    "callout_id": 1,
    "contact_id": 1,
    "callout_population_id": 2,
    "msisdn": "+85510202101",
    "metadata": {},
    "created_at": "2017-11-10T07:36:56.560Z",
    "updated_at": "2017-11-10T07:36:56.560Z"
  }
]
```

As you can see we have just the one participation in the callout, which has the `contact_id: 1` (Alice).

### Listing Contacts

If we want to see exactly who will be participating in our callout we can check that too:

```
$ docker run -t --rm --link somleng-scfm endeveit/docker-jq /bin/sh -c 'curl -v -s http://scfm:3000/api/callouts/1/contacts | jq'
```

```
< Per-Page: 25
< Total: 1
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
    "created_at": "2017-11-09T04:58:03.684Z",
    "updated_at": "2017-11-09T05:13:49.414Z"
  }
]
```

### Creating

Let's say that we changed our mind from before and we now want to include Bob into our callout. We can add Bob, by creating a callout participation directly.

In the command below we specify `contact_id=2` which is Bob's contact_id

```
$ docker run -t --rm --link somleng-scfm endeveit/docker-jq /bin/sh -c 'curl -XPOST -s http://scfm:3000/api/callouts/1/callout_participations -d contact_id=2 | jq'
```

You should see something like:

```json
{
  "id": 2,
  "callout_id": 1,
  "contact_id": 2,
  "callout_population_id": null,
  "msisdn": "+85510202102",
  "metadata": {},
  "created_at": "2017-11-10T08:01:41.430Z",
  "updated_at": "2017-11-10T08:01:41.430Z"
}
```

Bob is now the second participant in the callout. Once again we can check all the participants with:

```
$ docker run -t --rm --link somleng-scfm endeveit/docker-jq /bin/sh -c 'curl -v -s http://scfm:3000/api/callouts/1/contacts | jq'
```

```json
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
    "created_at": "2017-11-09T04:58:03.684Z",
    "updated_at": "2017-11-09T05:13:49.414Z"
  },
  {
    "id": 2,
    "msisdn": "+85510202102",
    "metadata": {
      "name": "Bob",
      "gender": "m"
    },
    "created_at": "2017-11-09T05:18:59.858Z",
    "updated_at": "2017-11-09T05:27:17.381Z"
  }
]
```

### Filtering

Let's say we no longer want to call Alice. We can remove Alice by deleting her participation from the callout. In order to do this we need Alice's callout participation id. We can filter the callout participations by her contact id to find her.

Notice in the command below we specify Alice's `contact_id` as a query parameter.

```
$ docker run -t --rm --link somleng-scfm endeveit/docker-jq /bin/sh -c 'curl -v -s -g "http://scfm:3000/api/callouts/1/callout_participations?q[contact_id]=1" | jq'
```

```
< Per-Page: 25
< Total: 1
```

```json
[
  {
    "id": 1,
    "callout_id": 1,
    "contact_id": 1,
    "callout_population_id": 1,
    "msisdn": "+85510202101",
    "metadata": {},
    "created_at": "2017-11-10T09:53:08.427Z",
    "updated_at": "2017-11-10T09:53:08.427Z"
  }
]
```

The `id` field in the response above is Alice's callout participation id

### Deleting

Once we have Alice's callout participation id we can delete her from the callout. Note that this doesn't delete her from the contacts table. It simply removes her from the callout.

```
$ docker run -t --rm --link somleng-scfm endeveit/docker-jq /bin/sh -c 'curl -v -XDELETE http://scfm:3000/api/callout_participations/1'
```

As before, when deleting a resource successfully we should get a `No Content` reponse.

```
< HTTP/1.1 204 No Content
```

For our own piece of mind let's make sure she's actually been removed from the callout.

```
$ docker run -t --rm --link somleng-scfm endeveit/docker-jq /bin/sh -c 'curl -v -s http://scfm:3000/api/callouts/1/contacts | jq'
```

```
< Per-Page: 25
< Total: 1
```

```json
[
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

### Repopulating

Let's say that we really do want Alice in the callout after all. We could just re-add her to the callout as we did for Bob, but let's add her back by requeuing or batch operation for populating the callout.

First let's check our batch operation again:

```
$ docker run -t --rm --link somleng-scfm endeveit/docker-jq /bin/sh -c 'curl -s http://scfm:3000/api/batch_operations/1 | jq'
```

```json
{
  "id": 1,
  "callout_id": 1,
  "parameters": {
    "contact_filter_params": {
      "metadata": {
        "gender": "f"
      }
    }
  },
  "metadata": {},
  "status": "finished",
  "created_at": "2017-11-17T10:24:20.458Z",
  "updated_at": "2017-11-17T10:39:25.073Z"
}
```

As you can see from the response above the status of the batch operation is already `finished`. But we can requeue it again.

First let's make sure that Alice will be added again if we repopulate by previewing the contacts.

```
$ docker run -t --rm --link somleng-scfm endeveit/docker-jq /bin/sh -c 'curl -s -v http://scfm:3000/api/batch_operations/1/preview/contacts | jq'
```

```
< Per-Page: 25
< Total: 1
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
  }
]
```

Ok so we can see from the preview that Alice will added as a participant to the callout.

Finally let's go ahead and queue the batch operation. Notice that the `event` in the command below is `requeue`. We're requeuing the batch operation to populate the callout.

```
$ docker run -t --rm --link somleng-scfm endeveit/docker-jq /bin/sh -c 'curl -s -XPOST http://scfm:3000/api/batch_operations/1/batch_operation_events -d "event=requeue" | jq'
```

```json
{
  "id": 1,
  "callout_id": 1,
  "parameters": {
    "contact_filter_params": {
      "metadata": {
        "gender": "f"
      }
    }
  },
  "metadata": {},
  "status": "queued",
  "created_at": "2017-11-17T10:24:20.458Z",
  "updated_at": "2017-11-17T10:39:25.073Z"
}
```

Now we see that the callout population has been queued again.

Let's check again to see if it's done.

```
$ docker run -t --rm --link somleng-scfm endeveit/docker-jq /bin/sh -c 'curl -s http://scfm:3000/api/batch_operations/1 | jq'
```

```json
{
  "id": 1,
  "callout_id": 1,
  "parameters": {
    "contact_filter_params": {
      "metadata": {
        "gender": "f"
      }
    }
  },
  "metadata": {},
  "status": "finished",
  "created_at": "2017-11-17T10:24:20.458Z",
  "updated_at": "2017-11-17T10:39:25.073Z"
}
```

Looks good. Now let's check to see if Alice is was populated in our callout.

```
$ docker run -t --rm --link somleng-scfm endeveit/docker-jq /bin/sh -c 'curl -v -s http://scfm:3000/api/batch_operations/1/contacts | jq'
```

```
< Per-Page: 25
< Total: 1
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
  }
]
```

Ok, we see that Alice is has been populated but what happened to Bob? If we take a closer look at the previous command notice that the URL is `api/batch_operations/1/contacts`. This command lists all the contacts which have been populated by the batch operation.

What we really want to see is who is now in our callout.

```
$ docker run -t --rm --link somleng-scfm endeveit/docker-jq /bin/sh -c 'curl -v -s http://scfm:3000/api/callouts/1/contacts | jq'
```

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
