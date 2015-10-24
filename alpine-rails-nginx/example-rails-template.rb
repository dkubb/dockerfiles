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

set -o errexit -o pipefail -o noglob -o noclobber -o nounset
IFS=$'\n\t'

exec chpst -u postgres -- postgres -D $PGDATA
POSTGRES

file 'Dockerfile', <<-'DOCKERFILE'
FROM dkubb/alpine-rails-nginx:latest
MAINTAINER Dan Kubb <dkubb@fastmail.com>

ENV RAILS_ENV development
ENV PGDATA    /var/lib/postgresql/data

RUN apk add postgresql=9.4.4-r0

COPY config/postgres.sh /etc/sv/postgres
RUN /root/setup-directories.sh root /etc/sv /etc/service/postgres \
  && /root/setup-directories.sh postgres "$(dirname "$PGDATA")" "$PGDATA" \
  && chmod u+x /etc/sv/postgres \
  && ln -s -- /etc/sv/postgres /etc/service/postgres/run

USER postgres
WORKDIR /var/lib/postgresql

# Setup default user and database
RUN pg_ctl initdb --pgdata $PGDATA \
  && pg_ctl start --pgdata $PGDATA \
  && until psql --command 'SELECT 1' 2>/dev/null >&2; do :; done \
  && createuser rails \
  && createdb --owner rails example_development \
  && pg_ctl stop --pgdata $PGDATA

USER root
WORKDIR /opt/rails

# Install gem dependencies
COPY Gemfile* /opt/rails/
RUN until timeout -t 180 bundle; do :; done

COPY . /opt/rails
RUN mkdir /opt/nginx \
  && mv /opt/rails/public /opt/nginx/html \
  && /root/setup-directories.sh nginx /opt/nginx \
  && /root/setup-directories.sh rails /opt/rails
DOCKERFILE
