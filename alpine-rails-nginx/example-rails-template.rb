gem 'puma'
gem 'tzinfo-data'

file 'config/puma.rb', <<-'PUMA_CONFIG'
directory   '/opt/rails'
rackup      '/opt/rails/config.ru'
environment ENV.fetch('RAILS_ENV')

bind 'unix:///var/run/rails/server.sock'

workers 3
threads 0, 4

preload_app!

on_worker_boot do
  ActiveSupport.on_load(:active_record) do
    ActiveRecord::Base.establish_connection
  end

  Rails.cache.try(:reset)
end
PUMA_CONFIG

file 'Procfile', <<-'PROCFILE'
web: bundle exec puma --quiet --config config/puma.rb
PROCFILE

file 'config/postgres.sh', <<-'POSTGRES'
#!/usr/bin/env bash

source strict-mode.sh

export PGDATA=/var/db/postgresql/data

exec chpst -u postgres -- postgres
POSTGRES

file 'Dockerfile', <<-'DOCKERFILE'
FROM dkubb/alpine-rails-nginx
MAINTAINER Dan Kubb <dkubb@fastmail.com>

ENV RAILS_ENV development

RUN apk add postgresql-dev=9.4.5-r1

COPY config/postgres.sh /etc/sv/postgres
RUN export PGDATA=/var/db/postgresql/data \
  && setup-directories.sh root     r  /etc/service/postgres \
  && setup-directories.sh postgres rw "$(dirname "$PGDATA")" "$PGDATA" \
  && chmod u+x /etc/sv/postgres \
  && ln -s -- /etc/sv/postgres /etc/service/postgres/run

USER postgres
WORKDIR /var/lib/postgresql

# Setup default user and database
RUN export PGDATA=/var/db/postgresql/data \
  && pg_ctl initdb \
  && pg_ctl start \
  && until psql --command 'SELECT 1' 2>/dev/null >&2; do :; done \
  && createuser -- rails \
  && createdb --owner rails -- example_development \
  && pg_ctl stop

USER root
WORKDIR /opt/rails

# Install gem dependencies
COPY Gemfile* /opt/rails/
RUN until bundle; do :; done

COPY . /opt/rails
RUN mkdir /opt/nginx \
  && mv /opt/rails/public /opt/nginx/html \
  && setup-directories.sh nginx r  /opt/nginx \
  && setup-directories.sh rails r  /opt/rails \
  && setup-directories.sh rails rw /opt/rails/log /opt/rails/tmp
DOCKERFILE
