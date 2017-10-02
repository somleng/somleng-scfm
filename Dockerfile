FROM ruby:latest

RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs && echo "deb http://ftp.debian.org/debian jessie-backports main" >> /etc/apt/sources.list.d/jessie.list && apt-get update -qq && apt-get -t jessie-backports install -y sqlite3 libsqlite3-dev && rm /etc/apt/sources.list.d/jessie.list

RUN mkdir /usr/src/app
WORKDIR /usr/src/app

ADD Gemfile /usr/src/app/Gemfile
ADD Gemfile.lock /usr/src/app/Gemfile.lock
RUN bundle install --deployment --without development test
ADD . /usr/src/app
