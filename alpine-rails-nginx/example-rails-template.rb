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

export PGDATA=/var/db/postgresql/data

cd $PGDATA
exec chpst -u postgres postgres
POSTGRES

file 'Dockerfile', <<-'DOCKERFILE'
FROM dkubb/alpine-rails-nginx
MAINTAINER Dan Kubb <dkubb@fastmail.com>

ENV RAILS_ENV=development \
  PGDATA=/var/db/postgresql/data

RUN apk add postgresql-dev=9.5.2-r1 \
  && chown postgres: /usr/bin/postgres \
  && chmod 0700 /usr/bin/postgres

COPY config/postgres.sh /etc/sv/postgres
RUN setup-directories.sh root      r  /etc/service/postgres \
  && setup-directories.sh postgres rw "$(dirname "$PGDATA")" "$PGDATA" \
  && chmod u+x /etc/sv/postgres \
  && ln -s /etc/sv/postgres /etc/service/postgres/run

# Setup database and user
USER postgres
RUN pg_ctl initdb \
  && pg_ctl start -w \
  && createuser rails \
  && createdb --owner rails example_development \
  && pg_ctl stop

USER root

# Install gem dependencies
COPY Gemfile* /opt/rails/
RUN until timeout -t 180 bundle; do :; done \
  && setup-directories.sh rails r /opt/rails

COPY . /opt/rails
RUN setup-directories.sh  rails r  /opt/rails \
  && setup-directories.sh rails rw /opt/rails/log /opt/rails/tmp
DOCKERFILE
