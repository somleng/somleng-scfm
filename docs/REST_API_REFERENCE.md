# REST API Reference

Somleng SCFM provides a REST API for managing core resources. Below is the full documentation for the REST API. If you're new to Somleng SCFM we recommend that you read the [GETTING_STARTED](https://github.com/somleng/somleng-scfm/blob/master/docs/GETTING_STARTED.md) guide first.

Before we get started, follow the [Installation Guide](https://github.com/somleng/somleng-scfm/blob/master/docs/INSTALLATION.md) to install Somleng SCFM on your local machine.

## Accounts

### Create

Only Super Admins can create an account. In this example we use the account credentials of the super admin account we created in the [Installation Guide](https://github.com/somleng/somleng-scfm/blob/master/docs/INSTALLATION.md) to create a user account.

```
$ docker run -t --rm -e SUPER_ADMIN_ACCESS_TOKEN=$SUPER_ADMIN_ACCESS_TOKEN --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -s -XPOST http://scfm:3000/api/accounts -u $SUPER_ADMIN_ACCESS_TOKEN: | jq'
```

Sample Response:

```json
{
  "id": 2,
  "metadata": {},
  "settings": {},
  "twilio_account_sid": null,
  "somleng_account_sid": null,
  "permissions": [],
  "created_at": "2018-02-18T12:52:49.993Z",
  "updated_at": "2018-02-18T12:52:49.993Z"
}
```

### Update

```
$ docker run -t --rm -e SUPER_ADMIN_ACCESS_TOKEN=$SUPER_ADMIN_ACCESS_TOKEN --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -v -XPATCH http://scfm:3000/api/accounts/2 -d "somleng_account_sid=abcdefg" -d "metadata[name]=Basic+Account" -u $SUPER_ADMIN_ACCESS_TOKEN:'
```

Sample Response:

```
< HTTP/1.1 204 No Content
```

### Fetch

```
$ docker run -t --rm -e SUPER_ADMIN_ACCESS_TOKEN=$SUPER_ADMIN_ACCESS_TOKEN --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -s http://scfm:3000/api/accounts/2 -u $SUPER_ADMIN_ACCESS_TOKEN: | jq'
```

Sample Response:

```json
{
  "id": 2,
  "metadata": {
    "name": "Basic Account"
  },
  "settings": {},
  "twilio_account_sid": null,
  "somleng_account_sid": "abcdefg",
  "permissions": [],
  "created_at": "2018-02-18T12:52:49.993Z",
  "updated_at": "2018-02-18T13:06:36.101Z"
}
```

### Index and Filter

#### All Accounts

```
$ docker run -t --rm -e SUPER_ADMIN_ACCESS_TOKEN=$SUPER_ADMIN_ACCESS_TOKEN --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -v -s http://scfm:3000/api/accounts -u $SUPER_ADMIN_ACCESS_TOKEN: | jq'
```

Sample Response:

```
< HTTP/1.1 200 OK
< Per-Page: 25
< Total: 2
```

```json
[
  {
    "id": 1,
    "metadata": {},
    "settings": {},
    "twilio_account_sid": null,
    "somleng_account_sid": null,
    "permissions": [
      "super_admin"
    ],
    "created_at": "2018-02-18T12:50:30.276Z",
    "updated_at": "2018-02-18T12:50:30.276Z"
  },
  {
    "id": 2,
    "metadata": {
      "name": "Basic Account"
    },
    "settings": {},
    "twilio_account_sid": null,
    "somleng_account_sid": "abcdefg",
    "permissions": [],
    "created_at": "2018-02-18T12:52:49.993Z",
    "updated_at": "2018-02-18T13:06:36.101Z"
  }
]
```

### Delete

```
$ docker run -t --rm -e SUPER_ADMIN_ACCESS_TOKEN=$SUPER_ADMIN_ACCESS_TOKEN --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -v -XDELETE http://scfm:3000/api/accounts/2 -u $SUPER_ADMIN_ACCESS_TOKEN:'
```

Sample Response:

```
< HTTP/1.1 204 No Content
```

## Access Tokens

### Create

```
$ docker run -t --rm -e SUPER_ADMIN_ACCESS_TOKEN=$SUPER_ADMIN_ACCESS_TOKEN --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -s -XPOST http://scfm:3000/api/access_tokens -d "account_sid=2" -u $SUPER_ADMIN_ACCESS_TOKEN: | jq'
```

Sample Response:

```json
{
  "id": 2,
  "token": "98860748b16c56acdf0c719e0d39f3bf9524c9119e8023b1b5ade32a964a6c5b",
  "created_at": "2018-02-18T13:19:40.834Z",
  "updated_at": "2018-02-18T13:19:40.838Z",
  "metadata": {}
}
```

## Contacts

### Create

```
$ docker run -t --rm --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -s -XPOST http://scfm:3000/api/contacts --data-urlencode "msisdn=+252662345699" -u $ACCESS_TOKEN: | jq'
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
$ docker run -t --rm --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -v -XPATCH http://scfm:3000/api/contacts/1 --data-urlencode "msisdn=+252662345700" -d "metadata[name]=Alice" -d "metadata[gender]=f" -u $ACCESS_TOKEN:'
```

#### metadata_merge_mode=merge (default)

Merges new metadata with existing metadata

```
$ docker run -t --rm --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -v -XPATCH http://scfm:3000/api/contacts/1 -d metadata_merge_mode=merge -d "metadata[province]=Kampong+Thom" -u $ACCESS_TOKEN:'
```

#### metadata_merge_mode=replace

Replaces existing metadata with new metadata

```
$ docker run -t --rm --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -v -XPATCH http://scfm:3000/api/contacts/1 -d metadata_merge_mode=replace -d "metadata[gender]=f" -u $ACCESS_TOKEN:'
```

#### metadata_merge_mode=deep_merge

Deep merges existing metadata with new metadata

```
$ docker run -t --rm --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -v -XPATCH http://scfm:3000/api/contacts/1 -d metadata_merge_mode=deep_merge -d "metadata[gender]=f" -u $ACCESS_TOKEN:'
```

Sample Response:

```
< HTTP/1.1 204 No Content
```

### Fetch

```
$ docker run -t --rm --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -s http://scfm:3000/api/contacts/1 -u $ACCESS_TOKEN: | jq'
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
$ docker run -t --rm --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -v -s http://scfm:3000/api/contacts -u $ACCESS_TOKEN: | jq'
```

#### Filter by metadata

```
$ docker run -t --rm --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -v -s -g http://scfm:3000/api/contacts?q[metadata][gender]=f -u $ACCESS_TOKEN: | jq'
```

#### Filter by msisdn

```
$ docker run -t --rm --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -v -s -g http://scfm:3000/api/contacts?q[msisdn]=252662345700 -u $ACCESS_TOKEN: | jq'
```

#### Filter by created_at

##### created_at_before

```
$ docker run -t --rm --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -v -s -g "http://scfm:3000/api/contacts?q[created_at_before]=2017-11-29+01:36:02" -u $ACCESS_TOKEN: | jq'
```

##### created_at_after

```
$ docker run -t --rm --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -v -s -g "http://scfm:3000/api/contacts?q[created_at_after]=2017-11-29+01:36:02" -u $ACCESS_TOKEN: | jq'
```

##### created_at_or_before

```
$ docker run -t --rm --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -v -s -g "http://scfm:3000/api/contacts?q[created_at_or_before]=2017-11-29+01:36:02" -u $ACCESS_TOKEN: | jq'
```

##### created_at_or_after

```
$ docker run -t --rm --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -v -s -g "http://scfm:3000/api/contacts?q[created_at_or_after]=2017-11-29+01:36:02" -u $ACCESS_TOKEN: | jq'
```

#### Filter by updated_at

##### updated_at_before

```
$ docker run -t --rm --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -v -s -g "http://scfm:3000/api/contacts?q[updated_at_before]=2017-11-29+01:36:02" -u $ACCESS_TOKEN: | jq'
```

##### updated_at_after

```
$ docker run -t --rm --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -v -s -g "http://scfm:3000/api/contacts?q[updated_at_after]=2017-11-29+01:36:02" -u $ACCESS_TOKEN: | jq'
```

##### updated_at_or_before

```
$ docker run -t --rm --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -v -s -g "http://scfm:3000/api/contacts?q[updated_at_or_before]=2017-11-29+01:36:02" -u $ACCESS_TOKEN: | jq'
```

##### updated_at_or_after

```
$ docker run -t --rm --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -v -s -g "http://scfm:3000/api/contacts?q[updated_at_or_after]=2017-11-29+01:36:02" -u $ACCESS_TOKEN: | jq'
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

```
$ docker run -t --rm --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -v -XDELETE http://scfm:3000/api/contacts/1 -u $ACCESS_TOKEN:'
```

Sample Response:

```
< HTTP/1.1 204 No Content
```

## Callouts

### Create

```
$ docker run -t --rm --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -s -XPOST http://scfm:3000/api/callouts -u $ACCESS_TOKEN: | jq'
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
$ docker run -t --rm --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -v -XPATCH http://scfm:3000/api/callouts/1 -d call_flow_logic=CallFlowLogic::Application -d "metadata[name]=my+callout" -u $ACCESS_TOKEN:'
```

#### metadata_merge_mode=merge (default)

Merges new metadata with existing metadata

```
$ docker run -t --rm --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -v -XPATCH http://scfm:3000/api/callouts/1 -d metadata_merge_mode=merge -d "metadata[province]=Kampong+Thom" -u $ACCESS_TOKEN:'
```

#### metadata_merge_mode=replace

Replaces existing metadata with new metadata

```
$ docker run -t --rm --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -v -XPATCH http://scfm:3000/api/callouts/1 -d metadata_merge_mode=replace -d "metadata[gender]=f" -u $ACCESS_TOKEN:'
```

#### metadata_merge_mode=deep_merge

Deep merges existing metadata with new metadata

```
$ docker run -t --rm --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -v -XPATCH http://scfm:3000/api/callouts/1 -d metadata_merge_mode=deep_merge -d "metadata[gender]=f" -u $ACCESS_TOKEN:'
```

Sample Response:

```
< HTTP/1.1 204 No Content
```

### Fetch

```
$ docker run -t --rm --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -s http://scfm:3000/api/callouts/1 -u $ACCESS_TOKEN: | jq'
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
$ docker run -t --rm --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -v -s http://scfm:3000/api/callouts -u $ACCESS_TOKEN: | jq'
```

#### Filter by metadata

```
$ docker run -t --rm --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -v -s -g http://scfm:3000/api/callouts?q[metadata][name]=my+callout -u $ACCESS_TOKEN: | jq'
```

#### Filter by status

```
$ docker run -t --rm --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -v -s -g http://scfm:3000/api/callouts?q[status]=initialized -u $ACCESS_TOKEN: | jq'
```

#### Filter by call flow logic

```
$ docker run -t --rm --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -v -s -g http://scfm:3000/api/callouts?q[call_flow_logic]=CallFlowLogic::Application -u $ACCESS_TOKEN: | jq'
```

#### Filter by created_at

##### created_at_before

```
$ docker run -t --rm --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -v -s -g "http://scfm:3000/api/callouts?q[created_at_before]=2017-11-29+01:36:02" -u $ACCESS_TOKEN: | jq'
```

##### created_at_after

```
$ docker run -t --rm --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -v -s -g "http://scfm:3000/api/callouts?q[created_at_after]=2017-11-29+01:36:02" -u $ACCESS_TOKEN: | jq'
```

##### created_at_or_before

```
$ docker run -t --rm --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -v -s -g "http://scfm:3000/api/callouts?q[created_at_or_before]=2017-11-29+01:36:02" -u $ACCESS_TOKEN: | jq'
```

##### created_at_or_after

```
$ docker run -t --rm --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -v -s -g "http://scfm:3000/api/callouts?q[created_at_or_after]=2017-11-29+01:36:02" -u $ACCESS_TOKEN: | jq'
```

#### Filter by updated_at

##### updated_at_before

```
$ docker run -t --rm --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -v -s -g "http://scfm:3000/api/callouts?q[updated_at_before]=2017-11-29+01:36:02" -u $ACCESS_TOKEN: | jq'
```

##### updated_at_after

```
$ docker run -t --rm --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -v -s -g "http://scfm:3000/api/callouts?q[updated_at_after]=2017-11-29+01:36:02" -u $ACCESS_TOKEN: | jq'
```

##### updated_at_or_before

```
$ docker run -t --rm --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -v -s -g "http://scfm:3000/api/callouts?q[updated_at_or_before]=2017-11-29+01:36:02" -u $ACCESS_TOKEN: | jq'
```

##### updated_at_or_after

```
$ docker run -t --rm --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -v -s -g "http://scfm:3000/api/callouts?q[updated_at_or_after]=2017-11-29+01:36:02" -u $ACCESS_TOKEN: | jq'
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
$ docker run -t --rm --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -s -XPOST http://scfm:3000/api/callouts/1/callout_events -d "event=start" -u $ACCESS_TOKEN: | jq'
```

#### Pause

```
$ docker run -t --rm --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -s -XPOST http://scfm:3000/api/callouts/1/callout_events -d "event=pause" -u $ACCESS_TOKEN: | jq'
```

#### Resume

```
$ docker run -t --rm --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -s -XPOST http://scfm:3000/api/callouts/1/callout_events -d "event=resume" -u $ACCESS_TOKEN: | jq'
```

#### Stop

```
$ docker run -t --rm --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -s -XPOST http://scfm:3000/api/callouts/1/callout_events -d "event=stop" -u $ACCESS_TOKEN: | jq'
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
$ docker run -t --rm --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -v -XDELETE http://scfm:3000/api/callouts/1
```

Sample Response:

```
< HTTP/1.1 204 No Content
```

## Callout Participations

### Create

```
$ docker run -t --rm --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -s -XPOST http://scfm:3000/api/callouts/1/callout_participations -d "contact_id=1" -u $ACCESS_TOKEN: | jq'
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
$ docker run -t --rm --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -v -XPATCH http://scfm:3000/api/callout_participations/1 -d call_flow_logic=CallFlowLogic::Application -d "metadata[name]=my+callout+participation" -d "msisdn=252662345701" -u $ACCESS_TOKEN:'
```

#### metadata_merge_mode=merge (default)

Merges new metadata with existing metadata

```
$ docker run -t --rm --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -v -XPATCH http://scfm:3000/api/callout_participations/1 -d metadata_merge_mode=merge -d "metadata[province]=Kampong+Thom" -u $ACCESS_TOKEN:'
```

#### metadata_merge_mode=replace

Replaces existing metadata with new metadata

```
$ docker run -t --rm --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -v -XPATCH http://scfm:3000/api/callout_participations/1 -d metadata_merge_mode=replace -d "metadata[gender]=f" -u $ACCESS_TOKEN:'
```

#### metadata_merge_mode=deep_merge

Deep merges existing metadata with new metadata

```
$ docker run -t --rm --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -v -XPATCH http://scfm:3000/api/callout_participations/1 -d metadata_merge_mode=deep_merge -d "metadata[gender]=f" -u $ACCESS_TOKEN:'
```

Sample Response:

```
< HTTP/1.1 204 No Content
```

### Fetch

```
$ docker run -t --rm --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -s http://scfm:3000/api/callout_participations/1 -u $ACCESS_TOKEN: | jq'
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
$ docker run -t --rm --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -v -s http://scfm:3000/api/callout_participations -u $ACCESS_TOKEN: | jq'
```

#### Filter by metadata

```
$ docker run -t --rm --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -v -g -s http://scfm:3000/api/callout_participations?q[metadata][name]=my+callout+participation -u $ACCESS_TOKEN: | jq'
```

#### Filter by callout

```
$ docker run -t --rm --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -v -s http://scfm:3000/api/callouts/1/callout_participations -u $ACCESS_TOKEN: | jq'
```

#### Filter by contact

```
$ docker run -t --rm --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -v -g -s http://scfm:3000/api/contacts/1/callout_participations -u $ACCESS_TOKEN: | jq'
```

#### Filter by msisdn

```
$ docker run -t --rm --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -v -g -s http://scfm:3000/api/callout_participations?q[msisdn]=252662345700 -u $ACCESS_TOKEN: | jq'
```

#### Filter by call flow logic

```
$ docker run -t --rm --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -v -g -s http://scfm:3000/api/callout_participations?q[call_flow_logic]=CallFlowLogic::Application -u $ACCESS_TOKEN: | jq'
```

#### Filter by callout participations which have phone calls

```
$ docker run -t --rm --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -v -g -s http://scfm:3000/api/callout_participations?q[has_phone_calls]=true -u $ACCESS_TOKEN: | jq'
```

#### Filter by callout participations which have no phone calls

```
$ docker run -t --rm --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -v -g -s http://scfm:3000/api/callout_participations?q[has_phone_calls]=false -u $ACCESS_TOKEN: | jq'
```

#### Filter by callout participations where the last phone call attempt was failed or errored

```
$ docker run -t --rm --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -v -g -s http://scfm:3000/api/callout_participations?q[last_phone_call_attempt]=failed,errored -u $ACCESS_TOKEN: | jq'
```

#### Filter by callout participations which have no phone calls OR the last phone call attempt was failed or errored

```
$ docker run -t --rm --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -v -g -s http://scfm:3000/api/callout_participations?q[no_phone_calls_or_last_attempt]=failed,errored -u $ACCESS_TOKEN: | jq'
```

#### Filter by created_at

##### created_at_before

```
$ docker run -t --rm --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -v -s -g "http://scfm:3000/api/callout_participations?q[created_at_before]=2017-11-29+01:36:02" -u $ACCESS_TOKEN: | jq'
```

##### created_at_after

```
$ docker run -t --rm --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -v -s -g "http://scfm:3000/api/callout_participations?q[created_at_after]=2017-11-29+01:36:02" -u $ACCESS_TOKEN: | jq'
```

##### created_at_or_before

```
$ docker run -t --rm --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -v -s -g "http://scfm:3000/api/callout_participations?q[created_at_or_before]=2017-11-29+01:36:02" -u $ACCESS_TOKEN: | jq'
```

##### created_at_or_after

```
$ docker run -t --rm --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -v -s -g "http://scfm:3000/api/callout_participations?q[created_at_or_after]=2017-11-29+01:36:02" -u $ACCESS_TOKEN: | jq'
```

#### Filter by updated_at

##### updated_at_before

```
$ docker run -t --rm --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -v -s -g "http://scfm:3000/api/callout_participations?q[updated_at_before]=2017-11-29+01:36:02" -u $ACCESS_TOKEN: | jq'
```

##### updated_at_after

```
$ docker run -t --rm --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -v -s -g "http://scfm:3000/api/callout_participations?q[updated_at_after]=2017-11-29+01:36:02" -u $ACCESS_TOKEN: | jq'
```

##### updated_at_or_before

```
$ docker run -t --rm --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -v -s -g "http://scfm:3000/api/callout_participations?q[updated_at_or_before]=2017-11-29+01:36:02" -u $ACCESS_TOKEN: | jq'
```

##### updated_at_or_after

```
$ docker run -t --rm --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -v -s -g "http://scfm:3000/api/callout_participations?q[updated_at_or_after]=2017-11-29+01:36:02" -u $ACCESS_TOKEN: | jq'
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
$ docker run -t --rm --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -v -XDELETE http://scfm:3000/api/callout_participations/1
```

Sample Response:

```
< HTTP/1.1 204 No Content
```

## Phone Calls

### Create

```
$ docker run -t --rm --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -s -XPOST http://scfm:3000/api/callout_participations/1/phone_calls --data-urlencode "remote_request_params[from]=1234" --data-urlencode "remote_request_params[url]=https://demo.twilio.com/docs/voice.xml" -d "remote_request_params[method]=GET" -u $ACCESS_TOKEN: | jq'
```

Sample Response:

```json
{
  "id": 1,
  "callout_participation_id": 1,
  "contact_id": 1,
  "create_batch_operation_id": null,
  "queue_batch_operation_id": null,
  "queue_remote_fetch_batch_operation_id": null,
  "status": "created",
  "msisdn": "+252662345699",
  "remote_call_id": null,
  "remote_status": null,
  "remote_direction": null,
  "remote_error_message": null,
  "metadata": {},
  "remote_response": {},
  "remote_request_params": {
    "from": "1234",
    "url": "https://demo.twilio.com/docs/voice.xml",
    "method": "GET"
  },
  "remote_queue_response": {},
  "call_flow_logic": null,
  "remotely_queued_at": null,
  "created_at": "2017-11-28T08:23:24.458Z",
  "updated_at": "2017-11-28T08:23:24.458Z"
}
```

### Update

```
$ docker run -t --rm --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -v -XPATCH http://scfm:3000/api/phone_calls/1 --data-urlencode "remote_request_params[from]=345" --data-urlencode "remote_request_params[url]=https://demo.twilio.com/docs/voice.xml" -d "remote_request_params[method]=GET" -u $ACCESS_TOKEN:'
```

#### metadata_merge_mode=merge (default)

Merges new metadata with existing metadata

```
$ docker run -t --rm --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -v -XPATCH http://scfm:3000/api/phone_calls/1 -d metadata_merge_mode=merge -d "metadata[province]=Kampong+Thom" -u $ACCESS_TOKEN:'
```

#### metadata_merge_mode=replace

Replaces existing metadata with new metadata

```
$ docker run -t --rm --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -v -XPATCH http://scfm:3000/api/phone_calls/1 -d metadata_merge_mode=replace -d "metadata[gender]=f" -u $ACCESS_TOKEN:'
```

#### metadata_merge_mode=deep_merge

Deep merges existing metadata with new metadata

```
$ docker run -t --rm --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -v -XPATCH http://scfm:3000/api/phone_calls/1 -d metadata_merge_mode=deep_merge -d "metadata[gender]=f" -u $ACCESS_TOKEN:'
```

Sample Response:

```
< HTTP/1.1 204 No Content
```

### Fetch

```
$ docker run -t --rm --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -s http://scfm:3000/api/phone_calls/1 -u $ACCESS_TOKEN: | jq'
```

```json
{
  "id": 1,
  "callout_participation_id": 1,
  "contact_id": 1,
  "create_batch_operation_id": null,
  "queue_batch_operation_id": null,
  "queue_remote_fetch_batch_operation_id": null,
  "status": "created",
  "msisdn": "+252662345699",
  "remote_call_id": null,
  "remote_status": null,
  "remote_direction": null,
  "remote_error_message": null,
  "metadata": {},
  "remote_response": {},
  "remote_request_params": {
    "from": "345",
    "url": "https://demo.twilio.com/docs/voice.xml",
    "method": "GET"
  },
  "remote_queue_response": {},
  "call_flow_logic": null,
  "remotely_queued_at": null,
  "created_at": "2017-11-28T08:23:24.458Z",
  "updated_at": "2017-11-28T08:24:52.634Z"
}
```

### Index and Filter

#### All Phone Calls

```
$ docker run -t --rm --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -v -s http://scfm:3000/api/phone_calls -u $ACCESS_TOKEN: | jq'
```

#### Filter by Callout Participation

```
$ docker run -t --rm --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -v -s http://scfm:3000/api/callout_participations/1/phone_calls -u $ACCESS_TOKEN: | jq'
```

#### Filter by Contact

```
$ docker run -t --rm --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -v -s http://scfm:3000/api/contacts/1/phone_calls -u $ACCESS_TOKEN: | jq'
```

#### Filter by Callout

```
$ docker run -t --rm --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -v -s http://scfm:3000/api/callouts/1/phone_calls -u $ACCESS_TOKEN: | jq'
```

#### Filter by metadata

```
$ docker run -t --rm --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -v -s -g http://scfm:3000/api/phone_calls?q[metadata][foo]=bar -u $ACCESS_TOKEN: | jq'
```

#### Filter by msisdn

```
$ docker run -t --rm --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -v -s -g http://scfm:3000/api/phone_calls?q[msisdn]=252662345700 -u $ACCESS_TOKEN: | jq'
```

#### Filter by status

```
$ docker run -t --rm --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -v -s -g http://scfm:3000/api/phone_calls?q[status]=created -u $ACCESS_TOKEN: | jq'
```

#### Filter by call flow logic

```
$ docker run -t --rm --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -v -s -g http://scfm:3000/api/phone_calls?q[call_flow_logic]=CallFlowLogic::Application -u $ACCESS_TOKEN: | jq'
```

#### Filter by remote_call_id

```
$ docker run -t --rm --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -v -s -g http://scfm:3000/api/phone_calls?q[remote_call_id]=082305b2-a0e4-4921-89bf-7bb544fd6910 -u $ACCESS_TOKEN: | jq'
```

#### Filter by remote_status

```
$ docker run -t --rm --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -v -s -g http://scfm:3000/api/phone_calls?q[remote_status]=in-progress -u $ACCESS_TOKEN: | jq'
```

#### Filter by remote_direction

```
$ docker run -t --rm --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -v -s -g http://scfm:3000/api/phone_calls?q[remote_direction]=inbound -u $ACCESS_TOKEN: | jq'
```

#### Filter by remote_error_message

```
$ docker run -t --rm --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -v -s -g http://scfm:3000/api/phone_calls?q[remote_error_message]=Unable+to+create+record -u $ACCESS_TOKEN: | jq'
```

#### Filter by remote_queue_response

```
$ docker run -t --rm --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -v -s -g http://scfm:3000/api/phone_calls?q[remote_queue_response][from]=345 -u $ACCESS_TOKEN: | jq'
```

#### Filter by remote_response

```
$ docker run -t --rm --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -v -s -g http://scfm:3000/api/phone_calls?q[remote_response][status]=canceled -u $ACCESS_TOKEN: | jq'
```

#### Filter by remote_request_params

```
$ docker run -t --rm --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -v -s -g "http://scfm:3000/api/phone_calls?q[remote_request_params][url]=https://demo.twilio.com/docs/voice.xml" -u $ACCESS_TOKEN: | jq'
```

#### Filter by remotely_queued_at

##### remotely_queued_at_before

```
$ docker run -t --rm --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -v -s -g "http://scfm:3000/api/phone_calls?q[remotely_queued_at_before]=2017-11-29+01:36:02" -u $ACCESS_TOKEN: | jq'
```

##### remotely_queued_at_after

```
$ docker run -t --rm --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -v -s -g "http://scfm:3000/api/phone_calls?q[remotely_queued_at_after]=2017-11-29+01:36:02" -u $ACCESS_TOKEN: | jq'
```

##### remotely_queued_at_or_before

```
$ docker run -t --rm --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -v -s -g "http://scfm:3000/api/phone_calls?q[remotely_queued_at_or_before]=2017-11-29+01:36:02" -u $ACCESS_TOKEN: | jq'
```

##### remotely_queued_at_or_after

```
$ docker run -t --rm --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -v -s -g "http://scfm:3000/api/phone_calls?q[remotely_queued_at_or_after]=2017-11-29+01:36:02" -u $ACCESS_TOKEN: | jq'
```

#### Filter by created_at

##### created_at_before

```
$ docker run -t --rm --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -v -s -g "http://scfm:3000/api/phone_calls?q[created_at_before]=2017-11-29+01:36:02" -u $ACCESS_TOKEN: | jq'
```

##### created_at_after

```
$ docker run -t --rm --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -v -s -g "http://scfm:3000/api/phone_calls?q[created_at_after]=2017-11-29+01:36:02" -u $ACCESS_TOKEN: | jq'
```

##### created_at_or_before

```
$ docker run -t --rm --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -v -s -g "http://scfm:3000/api/phone_calls?q[created_at_or_before]=2017-11-29+01:36:02" -u $ACCESS_TOKEN: | jq'
```

##### created_at_or_after

```
$ docker run -t --rm --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -v -s -g "http://scfm:3000/api/phone_calls?q[created_at_or_after]=2017-11-29+01:36:02" -u $ACCESS_TOKEN: | jq'
```

#### Filter by updated_at

##### updated_at_before

```
$ docker run -t --rm --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -v -s -g "http://scfm:3000/api/phone_calls?q[updated_at_before]=2017-11-29+01:36:02" -u $ACCESS_TOKEN: | jq'
```

##### updated_at_after

```
$ docker run -t --rm --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -v -s -g "http://scfm:3000/api/phone_calls?q[updated_at_after]=2017-11-29+01:36:02" -u $ACCESS_TOKEN: | jq'
```

##### updated_at_or_before

```
$ docker run -t --rm --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -v -s -g "http://scfm:3000/api/phone_calls?q[updated_at_or_before]=2017-11-29+01:36:02" -u $ACCESS_TOKEN: | jq'
```

##### updated_at_or_after

```
$ docker run -t --rm --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -v -s -g "http://scfm:3000/api/phone_calls?q[updated_at_or_after]=2017-11-29+01:36:02" -u $ACCESS_TOKEN: | jq'
```

Sample Response:

```
< Per-Page: 25
< Total: 1
```

```json
[
  {
    "id": 1,
    "callout_participation_id": 1,
    "contact_id": 1,
    "create_batch_operation_id": null,
    "queue_batch_operation_id": null,
    "queue_remote_fetch_batch_operation_id": null,
    "status": "created",
    "msisdn": "+252662345699",
    "remote_call_id": null,
    "remote_status": null,
    "remote_direction": null,
    "remote_error_message": null,
    "metadata": {},
    "remote_response": {},
    "remote_request_params": {
      "from": "345",
      "url": "https://demo.twilio.com/docs/voice.xml",
      "method": "GET"
    },
    "remote_queue_response": {},
    "call_flow_logic": null,
    "remotely_queued_at": null,
    "created_at": "2017-11-28T08:23:24.458Z",
    "updated_at": "2017-11-28T08:24:52.634Z"
  }
]
```

### Events

#### Queue

```
$ docker run -t --rm --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -s -XPOST http://scfm:3000/api/phone_calls/1/phone_call_events -d event=queue -u $ACCESS_TOKEN: | jq'
```

#### Queue Remote Fetch

```
$ docker run -t --rm --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -s -XPOST http://scfm:3000/api/phone_calls/1/phone_call_events -d event=queue_remote_fetch -u $ACCESS_TOKEN: | jq'
```

Sample Response:

```json
{
  "id": 1,
  "callout_participation_id": 1,
  "contact_id": 1,
  "create_batch_operation_id": null,
  "queue_batch_operation_id": null,
  "queue_remote_fetch_batch_operation_id": null,
  "status": "queued",
  "msisdn": "+252662345699",
  "remote_call_id": null,
  "remote_status": null,
  "remote_direction": null,
  "remote_error_message": null,
  "metadata": {},
  "remote_response": {},
  "remote_request_params": {
    "from": "345",
    "url": "https://demo.twilio.com/docs/voice.xml",
    "method": "GET"
  },
  "remote_queue_response": {},
  "call_flow_logic": "CallFlowLogic::AvfCapom::CapomShort",
  "remotely_queued_at": null,
  "created_at": "2017-11-29T03:54:35.502Z",
  "updated_at": "2017-11-29T03:58:07.144Z"
}
```

### Delete

```
$ docker run -t --rm --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -v -XDELETE http://scfm:3000/api/phone_calls/1 -u $ACCESS_TOKEN:'
```

Sample Response:

```
< HTTP/1.1 204 No Content
```

## Remote Phone Call Events

Remote Phone Call Events are created by Twilio or Somleng.

### Update

```
$ docker run -t --rm --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -v -XPATCH http://scfm:3000/api/remote_phone_call_events/1 -d "metadata[foo]=bar" -u $ACCESS_TOKEN:'
```

#### metadata_merge_mode=merge (default)

Merges new metadata with existing metadata

```
$ docker run -t --rm --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -v -XPATCH http://scfm:3000/api/remote_phone_call_events/1 -d metadata_merge_mode=merge -d "metadata[province]=Kampong+Thom" -u $ACCESS_TOKEN:'
```

#### metadata_merge_mode=replace

Replaces existing metadata with new metadata

```
$ docker run -t --rm --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -v -XPATCH http://scfm:3000/api/remote_phone_call_events/1 -d metadata_merge_mode=replace -d "metadata[gender]=f" -u $ACCESS_TOKEN:'
```

#### metadata_merge_mode=deep_merge

Deep merges existing metadata with new metadata

```
$ docker run -t --rm --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -v -XPATCH http://scfm:3000/api/remote_phone_call_events/1 -d metadata_merge_mode=deep_merge -d "metadata[gender]=f" -u $ACCESS_TOKEN:'
```

Sample Response:

```
< HTTP/1.1 204 No Content
```

### Fetch

```
$ docker run -t --rm --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -s http://scfm:3000/api/remote_phone_call_events/1 -u $ACCESS_TOKEN: | jq'
```

Sample Response:

```json
{
  "id": 1,
  "phone_call_id": 1,
  "details": {
    "From": "+1234",
    "To": "+252662345699",
    "CallSid": "06d9ebf7-4d71-4470-8b57-09235979781e",
    "CallStatus": "ringing",
    "Direction": "outbound-api",
    "AccountSid": "ddda6f6c-f698-40f7-be5b-53056ec1c52c",
    "ApiVersion": "2010-04-01"
  },
  "metadata": {},
  "remote_call_id": "06d9ebf7-4d71-4470-8b57-09235979781e",
  "remote_direction": "outbound-api",
  "call_flow_logic": "CallFlowLogic::AvfCapom::CapomShort",
  "created_at": "2017-11-29T03:58:16.135Z",
  "updated_at": "2017-11-29T03:58:16.135Z"
}
```

### Index and Filter

#### All Remote Phone Call Events

```
$ docker run -t --rm --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -v -s http://scfm:3000/api/remote_phone_call_events -u $ACCESS_TOKEN: | jq'
```

#### Filter by Phone Call

```
$ docker run -t --rm --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -v -s http://scfm:3000/api/phone_calls/1/remote_phone_call_events -u $ACCESS_TOKEN: | jq'
```

#### Filter by Contact

```
$ docker run -t --rm --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -v -s http://scfm:3000/api/contacts/1/remote_phone_call_events -u $ACCESS_TOKEN: | jq'
```

#### Filter by Callout

```
$ docker run -t --rm --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -v -s http://scfm:3000/api/callouts/1/remote_phone_call_events -u $ACCESS_TOKEN: | jq'
```

#### Filter by Callout Participation

```
$ docker run -t --rm --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -v -s http://scfm:3000/api/callout_participations/1/remote_phone_call_events -u $ACCESS_TOKEN: | jq'
```

#### Filter by details

```
$ docker run -t --rm --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -v -s -g http://scfm:3000/api/remote_phone_call_events?q[details][CallStatus]=ringing -u $ACCESS_TOKEN: | jq'
```

#### Filter by call_flow_logic

```
$ docker run -t --rm --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -v -s -g "http://scfm:3000/api/remote_phone_call_events?q[call_flow_logic]=CallFlowLogic::AvfCapom::CapomShort" -u $ACCESS_TOKEN: | jq'
```

#### Filter by remote_call_id

```
$ docker run -t --rm --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -v -s -g "http://scfm:3000/api/remote_phone_call_events?q[remote_call_id]=06d9ebf7-4d71-4470-8b57-09235979781e" -u $ACCESS_TOKEN: | jq'
```

#### Filter by remote_direction

```
$ docker run -t --rm --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -v -s -g "http://scfm:3000/api/remote_phone_call_events?q[remote_call_id]=06d9ebf7-4d71-4470-8b57-09235979781e" -u $ACCESS_TOKEN: | jq'
```

#### Filter by created_at

##### created_at_before

```
$ docker run -t --rm --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -v -s -g "http://scfm:3000/api/remote_phone_call_events?q[created_at_before]=2017-11-29+01:36:02" -u $ACCESS_TOKEN: | jq'
```

##### created_at_after

```
$ docker run -t --rm --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -v -s -g "http://scfm:3000/api/remote_phone_call_events?q[created_at_after]=2017-11-29+01:36:02" -u $ACCESS_TOKEN: | jq'
```

##### created_at_or_before

```
$ docker run -t --rm --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -v -s -g "http://scfm:3000/api/remote_phone_call_events?q[created_at_or_before]=2017-11-29+01:36:02" -u $ACCESS_TOKEN: | jq'
```

##### created_at_or_after

```
$ docker run -t --rm --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -v -s -g "http://scfm:3000/api/remote_phone_call_events?q[created_at_or_after]=2017-11-29+01:36:02" -u $ACCESS_TOKEN: | jq'
```

#### Filter by updated_at

##### updated_at_before

```
$ docker run -t --rm --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -v -s -g "http://scfm:3000/api/remote_phone_call_events?q[updated_at_before]=2017-11-29+01:36:02" -u $ACCESS_TOKEN: | jq'
```

##### updated_at_after

```
$ docker run -t --rm --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -v -s -g "http://scfm:3000/api/remote_phone_call_events?q[updated_at_after]=2017-11-29+01:36:02" -u $ACCESS_TOKEN: | jq'
```

##### updated_at_or_before

```
$ docker run -t --rm --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -v -s -g "http://scfm:3000/api/remote_phone_call_events?q[updated_at_or_before]=2017-11-29+01:36:02" -u $ACCESS_TOKEN: | jq'
```

##### updated_at_or_after

```
$ docker run -t --rm --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -v -s -g "http://scfm:3000/api/remote_phone_call_events?q[updated_at_or_after]=2017-11-29+01:36:02" -u $ACCESS_TOKEN: | jq'
```

Sample Response:

```
< Per-Page: 25
< Total: 1
```

```json
[
  {
    "id": 1,
    "phone_call_id": 1,
    "details": {
      "From": "+1234",
      "To": "+252662345699",
      "CallSid": "06d9ebf7-4d71-4470-8b57-09235979781e",
      "CallStatus": "ringing",
      "Direction": "outbound-api",
      "AccountSid": "ddda6f6c-f698-40f7-be5b-53056ec1c52c",
      "ApiVersion": "2010-04-01"
    },
    "metadata": {},
    "remote_call_id": "06d9ebf7-4d71-4470-8b57-09235979781e",
    "remote_direction": "outbound-api",
    "call_flow_logic": "CallFlowLogic::AvfCapom::CapomShort",
    "created_at": "2017-11-29T03:58:16.135Z",
    "updated_at": "2017-11-29T03:58:16.135Z"
  }
]
```

## Batch Operations

### Create

#### CalloutPopulation

Example: Create a batch operation for populating a callout, specifying `contact_filter_params` to stipulate the contacts who will participate in the callout.

```
$ docker run -t --rm --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -s -XPOST http://scfm:3000/api/callouts/1/batch_operations -d type=BatchOperation::CalloutPopulation -d parameters[contact_filter_params][metadata][gender]=f -u $ACCESS_TOKEN: | jq'
```

#### PhoneCallCreate

Example: Create a batch operation for creating phone calls, specifying `callout_filter_params` and `callout_participation_filter_params` to stipulate that phone calls should only be created for callouts which are `running` and for callout participations which have no phone calls or where the last attempt failed or was errored. Specify `remote_request_params` which will be set on each created phone call. Limit the number of phone calls which will be created to `30`. Allow creating the batch operation even if no actual phone calls will be created.

```
$ docker run -t --rm --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -s -XPOST http://scfm:3000/api/batch_operations -d type=BatchOperation::PhoneCallCreate -d parameters[callout_filter_params][status]=running -d parameters[callout_participation_filter_params][no_phone_calls_or_last_attempt]=failed,errored --data-urlencode "parameters[remote_request_params][from]=1234" --data-urlencode "parameters[remote_request_params][url]=https://demo.twilio.com/docs/voice.xml" -d "parameters[remote_request_params][method]=GET" -d parameters[limit]=30 -d parameters[skip_validate_preview_presence]=true -u $ACCESS_TOKEN: | jq'
```

#### PhoneCallQueue

Example: Create a batch operation for queuing phone calls on Twilio or Somleng specifying `phone_call_filter_params` and `callout_filter_params` to stipulate that only phone calls which have the status `created` and that are from a `running` callout should be queued. Limit the number of phone calls which will be queued to `30`. Allow creating the batch operation even if no actual phone calls will be queued.

```
$ docker run -t --rm --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -s -XPOST http://scfm:3000/api/batch_operations -d type=BatchOperation::PhoneCallQueue -d parameters[callout_filter_params][status]=running -d parameters[phone_call_filter_params][status]=created -d parameters[limit]=30 -d parameters[skip_validate_preview_presence]=true -u $ACCESS_TOKEN: | jq'
```

#### PhoneCallQueueRemoteFetch

Example: Create a batch operation for remotely fetching the phone calls status on Twilio or Somleng specifying `phone_call_filter_params` to stipulate that only phone calls which have the status `remotely_queued` or `in_progress` should be fetched. Limit the number of phone calls which will be fetched to `30`. Allow creating the batch operation even if no actual phone calls will be fetched.

```
$ docker run -t --rm --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -s -XPOST http://scfm:3000/api/batch_operations -d type=BatchOperation::PhoneCallQueueRemoteFetch -d "parameters[phone_call_filter_params][status]=remotely_queued,in_progress" -d parameters[limit]=30 -d parameters[skip_validate_preview_presence]=true -u $ACCESS_TOKEN: | jq'
```

Sample Response:

```json
{
  "id": 1,
  "callout_id": 1,
  "parameters": {},
  "metadata": {},
  "status": "preview",
  "created_at": "2017-11-30T03:59:39.425Z",
  "updated_at": "2017-11-30T03:59:39.425Z"
}
```

### Update

```
$ docker run -t --rm --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -v -XPATCH http://scfm:3000/api/batch_operations/1 -d "metadata[foo]=bar" -d "metadata[bar]=baz" -u $ACCESS_TOKEN:'
```

#### metadata_merge_mode=merge (default)

Merges new metadata with existing metadata

```
$ docker run -t --rm --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -v -XPATCH http://scfm:3000/api/batch_operations/1 -d metadata_merge_mode=merge -d "metadata[province]=Kampong+Thom" -u $ACCESS_TOKEN:'
```

#### metadata_merge_mode=replace

Replaces existing metadata with new metadata

```
$ docker run -t --rm --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -v -XPATCH http://scfm:3000/api/batch_operations/1 -d metadata_merge_mode=replace -d "metadata[gender]=f" -u $ACCESS_TOKEN:'
```

#### metadata_merge_mode=deep_merge

Deep merges existing metadata with new metadata

```
$ docker run -t --rm --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -v -XPATCH http://scfm:3000/api/batch_operations/1 -d metadata_merge_mode=deep_merge -d "metadata[gender]=f" -u $ACCESS_TOKEN:'
```

Sample Response:

```
< HTTP/1.1 204 No Content
```

### Fetch

```
$ docker run -t --rm --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -s http://scfm:3000/api/batch_operations/1 -u $ACCESS_TOKEN: | jq'
```

Sample Response:

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
  "created_at": "2017-12-01T05:28:01.904Z",
  "updated_at": "2017-12-01T05:28:01.904Z",
  "type": "BatchOperation::CalloutPopulation"
}
```

### Index and Filter

#### All Batch Operations

```
$ docker run -t --rm --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -v -s http://scfm:3000/api/batch_operations -u $ACCESS_TOKEN: | jq'
```

#### Filter by callout

```
$ docker run -t --rm --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -v -s http://scfm:3000/api/callouts/1/batch_operations -u $ACCESS_TOKEN: | jq'
```

#### Filter by parameters

```
$ docker run -t --rm --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -v -s -g "http://scfm:3000/api/batch_operations?q[parameters][contact_filter_params][metadata][gender]=f" -u $ACCESS_TOKEN: | jq'
```

#### Filter by metadata

```
$ docker run -t --rm --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -v -s -g "http://scfm:3000/api/batch_operations?q[metadata][foo]=bar" -u $ACCESS_TOKEN: | jq'
```

#### Filter by status

```
$ docker run -t --rm --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -v -s -g http://scfm:3000/api/batch_operations?q[status]=preview -u $ACCESS_TOKEN: | jq'
```

#### Filter by created_at

##### created_at_before

```
$ docker run -t --rm --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -v -s -g "http://scfm:3000/api/batch_operations?q[created_at_before]=2017-11-29+01:36:02" -u $ACCESS_TOKEN: | jq'
```

##### created_at_after

```
$ docker run -t --rm --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -v -s -g "http://scfm:3000/api/batch_operations?q[created_at_after]=2017-11-29+01:36:02" -u $ACCESS_TOKEN: | jq'
```

##### created_at_or_before

```
$ docker run -t --rm --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -v -s -g "http://scfm:3000/api/batch_operations?q[created_at_or_before]=2017-11-29+01:36:02" -u $ACCESS_TOKEN: | jq'
```

##### created_at_or_after

```
$ docker run -t --rm --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -v -s -g "http://scfm:3000/api/batch_operations?q[created_at_or_after]=2017-11-29+01:36:02" -u $ACCESS_TOKEN: | jq'
```

#### Filter by updated_at

##### updated_at_before

```
$ docker run -t --rm --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -v -s -g "http://scfm:3000/api/batch_operations?q[updated_at_before]=2017-11-29+01:36:02" -u $ACCESS_TOKEN: | jq'
```

##### updated_at_after

```
$ docker run -t --rm --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -v -s -g "http://scfm:3000/api/batch_operations?q[updated_at_after]=2017-11-29+01:36:02" -u $ACCESS_TOKEN: | jq'
```

##### updated_at_or_before

```
$ docker run -t --rm --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -v -s -g "http://scfm:3000/api/batch_operations?q[updated_at_or_before]=2017-11-29+01:36:02" -u $ACCESS_TOKEN: | jq'
```

##### updated_at_or_after

```
$ docker run -t --rm --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -v -s -g "http://scfm:3000/api/batch_operations?q[updated_at_or_after]=2017-11-29+01:36:02" -u $ACCESS_TOKEN: | jq'
```

Sample Response:

```
< Per-Page: 25
< Total: 1
```

```json
[
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
    "created_at": "2017-12-01T05:28:01.904Z",
    "updated_at": "2017-12-01T05:28:01.904Z",
    "type": "BatchOperation::CalloutPopulation"
  }
]
```

### Preview

Previewing batch operations allows you to preview what will happen, before queuing a batch operation for processing.

#### Preview Contacts (who will participate in a callout)

This preview can be run on a `BatchOperation::CalloutPopulation` to preview which contacts will be participants in the callout.

```
$ docker run -t --rm --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -s -v http://scfm:3000/api/batch_operations/1/preview/contacts -u $ACCESS_TOKEN: | jq'
```

Sample Response:

```
< Per-Page: 25
< Total: 1
```

```json
[
  {
    "id": 1,
    "msisdn": "+252662345699",
    "metadata": {
      "gender": "f"
    },
    "created_at": "2017-12-01T05:26:59.654Z",
    "updated_at": "2017-12-01T05:28:57.367Z"
  }
]
```

#### Preview Callout Participations (which will have phone calls created)

This preview can be run on a `BatchOperation::PhoneCallCreate` to preview which callout participations will have phone calls created.

```
$ docker run -t --rm --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -s -v http://scfm:3000/api/batch_operations/1/preview/callout_participations -u $ACCESS_TOKEN: | jq'
```

Sample Response:

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
    "callout_population_id": null,
    "msisdn": "+252662345699",
    "call_flow_logic": null,
    "metadata": {},
    "created_at": "2017-12-01T05:32:39.145Z",
    "updated_at": "2017-12-01T05:32:39.145Z"
  }
]
```

#### Preview Contacts (which will have phone calls created)

This preview can be run on a `BatchOperation::PhoneCallCreate` to preview which contacts will have phone calls created.

```
$ docker run -t --rm --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -s -v http://scfm:3000/api/batch_operations/1/preview/contacts -u $ACCESS_TOKEN: | jq'
```

Sample Response:

```
< Per-Page: 25
< Total: 1
```

```json
[
  {
    "id": 1,
    "msisdn": "+252662345699",
    "metadata": {
      "gender": "f"
    },
    "created_at": "2017-12-01T05:26:59.654Z",
    "updated_at": "2017-12-01T05:28:57.367Z"
  }
]
```

#### Preview Phone Calls (which will be queued or remotely fetched)

This preview can be run on a `BatchOperation::PhoneCallQueue` or `BatchOperation::PhoneCallQueueRemoteFetch` to preview which phone calls will be queued or remotely fetched.

```
$ docker run -t --rm --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -s -v http://scfm:3000/api/batch_operations/1/preview/phone_calls -u $ACCESS_TOKEN: | jq'
```

Sample Response:

```
< Per-Page: 25
< Total: 1
```

```json
[
  {
    "id": 1,
    "callout_participation_id": 1,
    "contact_id": 1,
    "create_batch_operation_id": 2,
    "queue_batch_operation_id": null,
    "queue_remote_fetch_batch_operation_id": null,
    "status": "created",
    "msisdn": "+252662345699",
    "remote_call_id": null,
    "remote_status": null,
    "remote_direction": null,
    "remote_error_message": null,
    "metadata": {},
    "remote_response": {},
    "remote_request_params": {
      "from": "1234",
      "url": "https://demo.twilio.com/docs/voice.xml",
      "method": "GET"
    },
    "remote_queue_response": {},
    "call_flow_logic": null,
    "remotely_queued_at": null,
    "created_at": "2017-12-01T05:36:47.963Z",
    "updated_at": "2017-12-01T05:36:47.963Z"
  }
]
```

### Events

#### Queue

Enqueues a batch operation to be run.

```
$ docker run -t --rm --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -s -XPOST http://scfm:3000/api/batch_operations/1/batch_operation_events -d "event=queue" -u $ACCESS_TOKEN: | jq'
```

#### Requeue

Requeues a batch operation that has already finished

```
$ docker run -t --rm --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -s -XPOST http://scfm:3000/api/batch_operations/1/batch_operation_events -d "event=requeue" -u $ACCESS_TOKEN: | jq'
```

Sample Response:

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
  "created_at": "2017-12-01T05:28:01.904Z",
  "updated_at": "2017-12-01T05:28:01.904Z",
  "type": "BatchOperation::CalloutPopulation"
}
```

### Results

Get the result of a batch operation

#### Callout Participations (which were created by the batch operation)

This can be run on a `BatchOperation::CalloutPopulation` do see which callout participations were created by the batch operation.

```
$ docker run -t --rm --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -s -v http://scfm:3000/api/batch_operations/1/callout_participations -u $ACCESS_TOKEN: | jq'
```

Sample Response:

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
    "msisdn": "+252662345699",
    "call_flow_logic": null,
    "metadata": {},
    "created_at": "2017-12-01T06:36:30.581Z",
    "updated_at": "2017-12-01T06:36:30.581Z"
  }
]
```

#### Contacts (who will participate in the callout)

This can be run on a `BatchOperation::CalloutPopulation` do see which contacts this batch operation created callout participations for.

```
$ docker run -t --rm --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -s -v http://scfm:3000/api/batch_operations/1/contacts -u $ACCESS_TOKEN: | jq'
```

Sample Response:

```
< Per-Page: 25
< Total: 1
```

```json
[
  {
    "id": 1,
    "msisdn": "+252662345699",
    "metadata": {
      "gender": "f"
    },
    "created_at": "2017-12-01T05:26:59.654Z",
    "updated_at": "2017-12-01T05:28:57.367Z"
  }
]
```

#### Phone Calls (which were created, queued or remotely fetched)

This can be run on a `BatchOperation::PhoneCallCreate`, `BatchOperation::PhoneCallQueue` or `BatchOperation::PhoneCallQueueRemoteFetch` do see which phone calls were created, queued or remotely fetched by the batch operation.

```
$ docker run -t --rm --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -s -v http://scfm:3000/api/batch_operations/1/phone_calls -u $ACCESS_TOKEN: | jq'
```

```
< Per-Page: 25
< Total: 1
```

```json
[
  {
    "id": 2,
    "callout_participation_id": 2,
    "contact_id": 1,
    "create_batch_operation_id": 2,
    "queue_batch_operation_id": null,
    "queue_remote_fetch_batch_operation_id": null,
    "status": "created",
    "msisdn": "+252662345699",
    "remote_call_id": null,
    "remote_status": null,
    "remote_direction": null,
    "remote_error_message": null,
    "metadata": {},
    "remote_response": {},
    "remote_request_params": {
      "from": "1234",
      "url": "https://demo.twilio.com/docs/voice.xml",
      "method": "GET"
    },
    "remote_queue_response": {},
    "call_flow_logic": null,
    "remotely_queued_at": null,
    "created_at": "2017-12-01T06:43:09.703Z",
    "updated_at": "2017-12-01T06:43:09.703Z"
  }
]
```

### Delete

```
$ docker run -t --rm --link somleng-scfm -e ACCESS_TOKEN=$ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -v -XDELETE http://scfm:3000/api/batch_operations/1 -u $ACCESS_TOKEN:'
```

Sample Response:

```
< HTTP/1.1 204 No Content
```
