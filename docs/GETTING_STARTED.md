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
$ docker run -t --rm --link somleng-scfm endeveit/docker-jq /bin/sh -c 'curl -XPUT -v http://scfm:3000/api/contacts/1 -d "[metadata][name]=Alice" -d "[metadata][gender]=f"'
```

You should see something like:

```
...
> PUT /api/contacts/1 HTTP/1.1
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
$ docker run -t --rm --link somleng-scfm endeveit/docker-jq /bin/sh -c 'curl -v -s -g "http://scfm:3000/api/contacts?metadata[gender]=f" | jq'
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

## Create a Callout

Now that we have some contacts in our database let's create a callout. In Somleng SCFM a callout represents a collection of contacts that need to be called for a particular purpose. In this example the callout represents the disaster alert. A callout can be *started*, *stopped*, *paused* or *resumed* using the REST API.

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

Note that the callout has been initialized, but not yet started. We could start the callout now, but it has not yet been populated so it wouldn't initiate any calls. So before we do that let's go and populate the callout first.

Note you can also list, show, update, filter and delete callouts similar to contacts. See the [REST API Reference](https://github.com/somleng/somleng-scfm/blob/master/docs/REST_API_REFERENCE.md) for more details

## Populating a Callout

In order to populate a callout we create a callout population. This will allow us to preview the contacts that will be called before actually queuing the population process. Let's go ahead and do that using the [REST API](https://github.com/somleng/somleng-scfm/blob/master/docs/REST_API_REFERENCE.md)

Note the url in the command below `/api/callouts/1/callout_populations`. Here `1` is the id of the callout created in the previous step.

```
$ docker run -t --rm --link somleng-scfm endeveit/docker-jq /bin/sh -c 'curl -s -XPOST http://scfm:3000/api/callouts/1/callout_populations | jq'
```

Sample Response:

```json
{
  "id": 1,
  "callout_id": 1,
  "contact_filter_params": {},
  "metadata": {},
  "status": "preview",
  "created_at": "2017-11-08T11:12:20.820Z",
  "updated_at": "2017-11-08T11:12:20.820Z"
}
```

Ok, now that we have our callout population let's preview what contacts will be called.

Again, note the url in the following command. `/api/callout_populations/1/preview/contacts`, where `1` is the id of the callout population created in the previous step.

```
$ docker run -t --rm --link somleng-scfm endeveit/docker-jq /bin/sh -c 'curl -s -v http://scfm:3000/api/callout_populations/1/preview/contacts | jq'
```

Sample Response:

```
< Per-Page: 25
< Total: 2
```

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
  },
  {
    "id": 3,
    "msisdn": "+85510202101",
    "metadata": {
      "zip_code": "90210",
      "city": "Beverly Hills"
    },
    "created_at": "2017-11-08T11:24:28.574Z",
    "updated_at": "2017-11-08T11:24:28.574Z"
  }
]
```

We can see from the response headers that there's `Total` of `2` contacts in the preview. This means that if we were to populate this now, these two contacts would participate in the callout.

Folowing our example, suppose that we wanted to restict the callout to contacts that live in the Zip Code 90210.

To do this let's update the callout population specifying some `contact_filter_params` which will limit our population of the callout.

```
$ docker run -t --rm --link somleng-scfm endeveit/docker-jq /bin/sh -c 'curl -v -s -XPUT http://scfm:3000/api/callout_populations/1 -d contact_filter_params[metadata][zip_code]=90210'
```

Sample Reponse:

```
< HTTP/1.1 204 No Content
```

When updating or deleting a resource successfully we should get a response of `204 No Content`. We can check that callout population was updated successfully by fetching it.

```
docker run -t --rm --link somleng-scfm endeveit/docker-jq /bin/sh -c 'curl -s http://scfm:3000/api/callout_populations/1 | jq'
```

Sample Response:

```json
{
  "id": 1,
  "callout_id": 1,
  "contact_filter_params": {
    "metadata": {
      "zip_code": "90210"
    }
  },
  "metadata": {},
  "status": "preview",
  "created_at": "2017-11-08T11:12:20.820Z",
  "updated_at": "2017-11-08T11:35:08.116Z"
}
```

We can see that the `contact_filter_params` are now set.

Let's try the preview again.

```
$ docker run -t --rm --link somleng-scfm endeveit/docker-jq /bin/sh -c 'curl -s -v http://scfm:3000/api/callout_populations/1/preview/contacts | jq'
```

```
< Per-Page: 25
< Total: 1
```

```json
[
  {
    "id": 3,
    "msisdn": "+85510202101",
    "metadata": {
      "zip_code": "90210",
      "city": "Beverly Hills"
    },
    "created_at": "2017-11-08T11:24:28.574Z",
    "updated_at": "2017-11-08T11:24:28.574Z"
  }
]
```

Now we can see from the response headers that there's `Total` of `1` contacts in the preview.

Once we're happy with our callout population we can queue it for population. This will take some time depending on how many participations need to be created.

```
$ docker run -t --rm --link somleng-scfm endeveit/docker-jq /bin/sh -c 'curl -s -XPOST http://scfm:3000/api/callout_populations/1/calout_population_events -d "event=queue" | jq'
```

Sample Response:

```json
```

## Tasks

Somleng SCFM Tasks are stand alone rake tasks that can be run manually, from cron or from another application.

## Quickstart

This section explains how to get up and running quickly using tasks. Please continue reading the sections below for detailed information on tasks.

If you want to follow this guide without installing anything locally, run the docker examples instead (assumes you have Docker installed).

