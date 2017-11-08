# Deployment

## Databases

Somleng SCFM currently supports [SQLite](https://www.sqlite.org/) and [PostgreSQL](https://www.postgresql.org/). If you want to test things out locally using Docker feel free to use the SQLite. For production we recommend using PostgreSQL.

## Docker

The following section decribes how to deploy Somleng Simple Call Flow Manager with Docker using and SQLite database.

### Pull the latest Docker image

```
$ sudo docker pull dwilkie/somleng-scfm
```

### Setup Database

#### Create Database (SQLite)

Creates a new database called `somleng_scfm_production` and copies it to the host directory `/etc/somleng-scfm/db`. Modify the command below to change these defaults.

```
$ sudo docker run --rm -v /etc/somleng-scfm/db:/tmp/db -e RAILS_ENV=production -e RAILS_DB_ADAPTER=sqlite3 -e DATABASE_NAME=somleng_scfm_production dwilkie/somleng-scfm /bin/bash -c 'bundle exec rake db:create && bundle exec rake db:migrate && if [ ! -f /tmp/db/somleng_scfm_production.sqlite3 ]; then cp /usr/src/app/db/somleng_scfm_production.sqlite3 /tmp/db; fi'
```

### Export Cron

Exports cron scripts with sensible defaults to `/etc/somleng-scfm/cron`. Modify the command below to change these defaults or edit them in the exported cron scripts. For additional configuration options see [the install task](https://github.com/somleng/somleng-scfm/blob/master/app/tasks/install_task.rb) and the [.env](https://github.com/somleng/somleng-scfm/blob/master/.env) file.

```
$ sudo docker run --rm -v /etc/somleng-scfm/cron:/usr/src/app/install/cron -e RAILS_ENV=production -e HOST_INSTALL_DIR=/etc/somleng-scfm dwilkie/somleng-scfm /bin/bash -c 'bundle exec rake task:install:cron'
```
