# somleng-scfm

[![Build Status](https://travis-ci.org/somleng/somleng-scfm.svg?branch=master)](https://travis-ci.org/somleng/somleng-scfm)
[![Test Coverage](https://codeclimate.com/github/somleng/somleng-scfm/badges/coverage.svg)](https://codeclimate.com/github/somleng/somleng-scfm/coverage)
[![Code Climate](https://codeclimate.com/github/somleng/somleng-scfm/badges/gpa.svg)](https://codeclimate.com/github/somleng/somleng-scfm)

Somleng Simple Call Flow Manager (Somleng SCFM) can be used to enqueue, throttle, update, and process calls through [Somleng](https://github.com/somleng/twilreapi) (or [Twilio](twilio.com))

## Getting Started

### Pull the latest Docker image

```
$ sudo docker pull dwilkie/somleng-scfm
```

### Setup Database (SQLite)

#### Create Database

Creates a new database called `somleng_scfm_production` and copies it to the host directory `/etc/somleng-scfm/db`.

```
$ sudo docker run --rm -v /etc/somleng-scfm/db:/tmp/db -e RAILS_ENV=production -e RAILS_DB_ADAPTER=sqlite3 -e DATABASE_NAME=somleng_scfm_production dwilkie/somleng-scfm /bin/bash -c 'bundle exec rake db:create && bundle exec rake db:migrate && if [ ! -f /tmp/db/somleng_scfm_production.sqlite3 ]; then cp /usr/src/app/db/somleng_scfm_production.sqlite3 /tmp/db; fi'
```

#### Import Data

Imports data into the production database (using [the example import script](https://github.com/somleng/somleng-scfm/blob/master/examples/import_data.rb)). Assumes the import file is called `data.csv`, is located `/etc/somleng-scfm/data` and has a header row.

```
$ sudo docker run -t --rm -v /etc/somleng-scfm/data:/tmp/data:ro -v /etc/somleng-scfm/db:/usr/src/app/db -e RAILS_ENV=production -e RAILS_DB_ADAPTER=sqlite3 -e DATABASE_NAME=somleng_scfm_production -e HEADER_ROW=1 -e IMPORT_FILE=/tmp/data/data.csv dwilkie/somleng-scfm /bin/bash -c 'bundle exec rails runner /usr/src/app/examples/import_data.rb'
```

### Export Cron

```
$ sudo docker run --rm -v /etc/somleng-scfm/cron:/usr/src/app/install/cron -e RAILS_ENV=production -e HOST_INSTALL_DIR=/etc/somleng-scfm dwilkie/somleng-scfm /bin/bash -c 'bundle exec rake task:install:cron'
```

### Run the Rails Console

```
$ sudo docker run --rm -it -v /etc/somleng-scfm/db:/usr/src/app/db -e RAILS_ENV=production dwilkie/somleng-scfm bundle exec rails c
```

### Run the Database Console

```
$ sudo docker run --rm -it -v /etc/somleng-scfm/db:/usr/src/app/db -e RAILS_ENV=production dwilkie/somleng-scfm bundle exec rails dbconsole
```

## License

The software is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
