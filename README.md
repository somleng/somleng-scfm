# somleng-scfm

[![Build Status](https://travis-ci.org/somleng/somleng-scfm.svg?branch=master)](https://travis-ci.org/somleng/somleng-scfm)
[![Test Coverage](https://codeclimate.com/github/somleng/somleng-scfm/badges/coverage.svg)](https://codeclimate.com/github/somleng/somleng-scfm/coverage)
[![Code Climate](https://codeclimate.com/github/somleng/somleng-scfm/badges/gpa.svg)](https://codeclimate.com/github/somleng/somleng-scfm)

Somleng Simple Call Flow Manager (Somleng SCFM) can be used to enqueue, throttle, update, and process calls through [Somleng](https://github.com/somleng/twilreapi) (or [Twilio](twilio.com))

## Getting Started

## Pull the latest Docker image

```
$ sudo docker pull dwilkie/somleng-scfm
```

## Setup Production Database (SQLite)

```
$ sudo docker run --rm -v $(pwd)/db:/usr/src/app/db -e RAILS_ENV=production -e RAILS_DB_ADAPTER=sqlite3 -e DATABASE_NAME=somleng_scfm_production dwilkie/somleng-scfm /bin/bash -c 'bundle exec rake db:create && bundle exec rake db:migrate'
```

### Run the Rails Console

```
$ sudo docker run --rm -it -v $(pwd)/db:/usr/src/app/db -e RAILS_ENV=production dwilkie/somleng-scfm bundle exec rails c
```

### Run the Database Console

```
$ sudo docker run --rm -it -v $(pwd)/db:/usr/src/app/db -e RAILS_ENV=production dwilkie/somleng-scfm bundle exec rails dbconsole
```

## License

The software is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
