# Setup

Follow this guide to get Somleng SCFM setup on your local machine. This guide installs Somleng SCFM in SQLite mode with Docker. Note that this is not recommended for a production environment, but it's the easiest way to try things out.

## Prerequisites

### Docker

If you haven't already done so, go ahead and [install Docker](https://docs.docker.com/engine/installation/).

Then download the lastest image of Somleng SCFM.

```
$ docker pull dwilkie/somleng-scfm
```

### Twilio Account

For the tutorial we're going to connect Somleng SCFM to Twilio. If you haven't already done so, go ahead and [create a Twilio Account](https://www.twilio.com/).

### Create a new SQLite Database

The first thing to do is create the database with a super admin account. Go ahead and run the following command to get your database set up.

Note that this will create a new SQLite database located at `/tmp/somleng-scfm/db/somleng_scfm_production.sqlite3` on your host machine. It will also create a file located at `/tmp/somleng-scfm/super_admin_access_token.txt` which contains the Access Token of your Super Admin account.

Run the following command:

```
$ docker run --rm -v /tmp/somleng-scfm:/tmp -e RAILS_ENV=production -e RAILS_DB_ADAPTER=sqlite3 -e SECRET_KEY_BASE=secret -e CREATE_SUPER_ADMIN_ACCOUNT=1 -e OUTPUT=super_admin -e FORMAT=http_basic dwilkie/somleng-scfm /bin/bash -c 'if [ -f /tmp/db/somleng_scfm_production.sqlite3 ]; then cp /tmp/db/somleng_scfm_production.sqlite3 ./db/; fi && bundle exec rake db:create && bundle exec rake db:migrate && SUPER_ADMIN_ACCESS_TOKEN=$(bundle exec rake db:seed) && mkdir -p /tmp/db/ && cp ./db/somleng_scfm_production.sqlite3 /tmp/db && echo $SUPER_ADMIN_ACCESS_TOKEN > /tmp/super_admin_access_token.txt' && SUPER_ADMIN_ACCESS_TOKEN=$(</tmp/somleng-scfm/super_admin_access_token.txt) && echo "Super Admin Account Access Token: $SUPER_ADMIN_ACCESS_TOKEN"
```

You should see your Super Admin's access token in the `$SUPER_ADMIN_ACCESS_TOKEN` environment variable as shown below:

```
$ Super Admin Account Access Token: 49c6f7961eae951e1d8ecb28093c4d59fcf3fd5fb31f120fcdef45f18c930a06
```

### Start the REST API Server

Now that the database has been created we can start the REST API Server.

In *another* terminal, run the following command:

```
$ docker run -it --rm -v /tmp/somleng-scfm/db:/usr/src/app/db -p 3000:3000 -h scfm --name somleng-scfm -e RAILS_ENV=production -e SECRET_KEY_BASE=secret -e RAILS_DB_ADAPTER=sqlite3 dwilkie/somleng-scfm /bin/bash -c 'bundle exec rails s'
```

Note that this command exposes port 3000 to your host. This will allow you to access the API at `http://localhost:3000/api`. Feel free to remove the `-p 3000:3000` option if you don't want to access the REST API from your host.

### Testing the API

To test things out run the following command from another terminal:

```
$ docker run -t --rm --link somleng-scfm endeveit/docker-jq /bin/sh -c 'curl -s -v  http://scfm:3000/api/contacts'
```

You should see something like:

```
< HTTP/1.1 401 Unauthorized
< X-Frame-Options: SAMEORIGIN
< X-XSS-Protection: 1; mode=block
< X-Content-Type-Options: nosniff
< Cache-Control: no-store
< Pragma: no-cache
< WWW-Authenticate: Bearer realm="Doorkeeper", error="invalid_token", error_description="The access token is invalid"
< Content-Type: text/html
< X-Request-Id: ba91231c-7d9e-447b-b247-b04a42db9588
< X-Runtime: 0.002254
< Transfer-Encoding: chunked
<
```

Note we used the `curl` and `jq` commands to execute the request, which are available in the `endeveit/docker-jq` container. Inside the container the REST API is available at `http://scfm:3000/api`. If you have `curl` and `jq` installed locally you could also run the above command like so:

```
$ curl -s -v http://localhost:3000/api/contacts
```

The rest of the examples access the REST API from within a docker container. Feel free to access the API from your host if you like.

### Create a user account

Run the following command:

```
$ ACCOUNT_ID=$(docker run -t --rm --link somleng-scfm -e SUPER_ADMIN_ACCESS_TOKEN=$SUPER_ADMIN_ACCESS_TOKEN endeveit/docker-jq /bin/sh -c 'curl -s -XPOST http://scfm:3000/api/accounts -u $SUPER_ADMIN_ACCESS_TOKEN: | jq -j ".id"') && echo "Account ID: $ACCOUNT_ID"
```

If all goes well should see something like:

```
Account ID: 2
```

### Create a user access token

Now that we have our user account we need to create an access token in order to access the API.

Run the following command:

```
$ ACCESS_TOKEN=$(docker run -t --rm --link somleng-scfm -e SUPER_ADMIN_ACCESS_TOKEN=$SUPER_ADMIN_ACCESS_TOKEN -e ACCOUNT_ID=$ACCOUNT_ID endeveit/docker-jq /bin/sh -c 'curl -s -XPOST http://scfm:3000/api/access_tokens -d "account_id=2" -u $SUPER_ADMIN_ACCESS_TOKEN: | jq -j ".token"') && echo "Access Token: $ACCESS_TOKEN"
```

You should see something like:

```
Access Token: 4705e06c2977e12bed7ff8f24296aeb804fc7037213c4e09ed21d770608e6a40
```

We can now authenticate with the API by using `-u $ACCESS_TOKEN:` (note the trailing ':') in our requests.
