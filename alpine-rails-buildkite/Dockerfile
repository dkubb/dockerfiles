FROM dkubb/alpine-rails-nginx

# Improve root state, intend to be pushed there
WORKDIR /

COPY etc /etc

# Upgrade installed system dependencies
COPY apk-packages /tmp/
RUN echo '@testing https://s3.amazonaws.com/alpine-packages/testing' >> /etc/apk/repositories \
  && sed 's/#.*$//;/^$/d' /tmp/apk-packages \
  | tr -d ' ' \
  | xargs apk add --update-cache \
  && rm /tmp/apk-packages

RUN rm -r /etc/sv/nginx /etc/service/nginx /etc/sv/rails /etc/service/rails \
  && /root/setup-directories.sh root     r  /etc/service/postgres /etc/service/buildkite \
  && /root/setup-directories.sh postgres rw /var/db/postgresql \
  && ln -s -- /etc/sv/postgres /etc/service/postgres/run \
  && ln -s -- /etc/sv/buildkite /etc/service/buildkite/run

USER buildkite

# Setup bundler for buildkite user
RUN bundle config --global build.nokogiri '--use-system-libraries' \
  && bundle config --global jobs '8'

USER postgres

# Setup user and database
RUN export PGDATA=/var/db/postgresql/data \
  && pg_ctl initdb \
  && pg_ctl start \
  && until psql --command 'SELECT 1' 2>/dev/null >&2; do :; done \
  && createuser buildkite --superuser \
  && pg_ctl stop

USER root
