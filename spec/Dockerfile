FROM ruby:latest

RUN add-apt-repository ppa:jonathonf/backports -y && apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs sqlite3 libsqlite3-dev libpq-dev

RUN mkdir /usr/src/app
WORKDIR /usr/src/app

ADD Gemfile /usr/src/app/Gemfile
ADD Gemfile.lock /usr/src/app/Gemfile.lock
RUN bundle install --deployment
ADD . /usr/src/app
