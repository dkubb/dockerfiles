# dkubb/alpine-ruby-buildkite

FROM dkubb/alpine-ruby
MAINTAINER Dan Kubb <dkubb@fastmail.com>

COPY etc /etc

# Upgrade installed system dependencies
COPY apk-packages /tmp/
RUN echo '@testing https://s3.amazonaws.com/alpine-packages/testing' >> /etc/apk/repositories \
  && sed 's/#.*$//;/^$/d' /tmp/apk-packages \
  | tr -d ' ' \
  | xargs apk add --update-cache \
  && rm -- /tmp/apk-packages

# Create system directories and service symlinks
RUN export PGDATA=/var/db/postgresql/data \
  && setup-directories.sh  root     r /etc/service/postgres /etc/service/buildkite \
  && setup-directories.sh postgres rw "$(dirname "$PGDATA")" "$PGDATA" \
  && ln -s -- /etc/sv/postgres /etc/service/postgres/run \
  && ln -s -- /etc/sv/buildkite /etc/service/buildkite/run

# Setup bundler for the buildkite user
RUN cp --recursive -- ~/.bundle ~buildkite \
  && setup-directories.sh buildkite rw ~buildkite/.bundle

# Setup database and user
USER postgres
RUN export PGDATA=/var/db/postgresql/data \
  && pg_ctl initdb \
  && pg_ctl start \
  && until psql --command 'SELECT 1' 2>/dev/null >&2; do :; done \
  && createuser --superuser -- buildkite \
  && pg_ctl stop

USER root
