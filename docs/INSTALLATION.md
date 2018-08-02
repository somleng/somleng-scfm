# Setup

Follow this guide to get Somleng SCFM setup on your local machine using Docker.

## Prerequisites

### Docker

If you haven't already done so, go ahead and [install Docker](https://docs.docker.com/engine/installation/).

### Git

You'll also need Git installed. If you haven't already done so, go ahead and [install Git](https://git-scm.com/book/en/v1/Getting-Started-Installing-Git)

### Twilio Account

For the tutorial we're going to connect Somleng SCFM to Twilio. If you haven't already done so, go ahead and [create a Twilio Account](https://www.twilio.com/).

### Clone the Repository

    $ git clone https://github.com/somleng/somleng-scfm.git
    $ cd somleng-scfm

### Start the SCFM Server

From a new terminal, in the SCFM directory, run:

        docker-compose up --build

Note that this command exposes port 3000 to your host. You should now see SCFM booted at <http://localhost:3000>

### Setup the Database

The next need to do is create the database and setup a Super Admin account. Go ahead and run the following commands in the first terminal:

    docker-compose exec somleng-scfm /bin/bash -c './bin/rails db:setup'
    SUPER_ADMIN_ACCESS_TOKEN=$(docker-compose run --rm -e CREATE_SUPER_ADMIN_ACCOUNT=1 -e OUTPUT=super_admin -e FORMAT=http_basic somleng-scfm /bin/bash -c './bin/rails db:seed')
    echo $SUPER_ADMIN_ACCESS_TOKEN

You should see the output of your Super Admin access token.

### Create a user account

Using our Super Admin account we will now use the API to create a normal user account.

Run the following command:

    $ ACCOUNT_ID=$(docker-compose run --rm -e SUPER_ADMIN_ACCESS_TOKEN=$SUPER_ADMIN_ACCESS_TOKEN curl /bin/sh -c 'curl -s -XPOST http://somleng-scfm:3000/api/accounts -u $SUPER_ADMIN_ACCESS_TOKEN: | jq -r -M ".id"')
    $ echo $ACCOUNT_ID

If all goes well should see your user account id. E.g. `2`

### Create an access token for the acccount

Now that we have our user account we need to create an access token in order to access the API.

Run the following command:

    $ ACCESS_TOKEN=$(docker-compose run --rm -e SUPER_ADMIN_ACCESS_TOKEN=$SUPER_ADMIN_ACCESS_TOKEN -e ACCOUNT_ID=$ACCOUNT_ID curl /bin/sh -c 'curl -s -XPOST http://somleng-scfm:3000/api/access_tokens -d "account_id=$ACCOUNT_ID" -u $SUPER_ADMIN_ACCESS_TOKEN: | jq -r -M ".token"')
    $ echo $ACCESS_TOKEN

You should see your access token. E.g. `4705e06c2977e12bed7ff8f24296aeb804fc7037213c4e09ed21d770608e6a40`

We can now authenticate with the API by using `-u $ACCESS_TOKEN:` (note the trailing ':') in our requests.

### Create a User

Now that we our user account and access token, let's go ahead and create a user in order to sign in:

Run the following command:

    $ docker-compose run --rm -e ACCESS_TOKEN=$ACCESS_TOKEN curl /bin/sh -c 'curl -s -XPOST http://somleng-scfm:3000/api/users -d "email=tiadmin@peopleinneed.cz" -d "password=secret1234" -u $ACCESS_TOKEN: | jq'

You should be able to now sign in at <http://localhost:3000> with the email and password that you used in the request above.
