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

file 'Dockerfile', <<-'DOCKERFILE'
FROM dkubb/alpine-nix-rails-nginx:latest
MAINTAINER Dan Kubb <dkubb@fastmail.com>

ENV RAILS_ENV development

RUN nix-env --install sqlite-3.8.11.1

RUN source /etc/profile.d/nix.sh \
  && bundle config --local build.sqlite3 '--use-system-libraries --with-zlib-dir=/nix/var/nix/profiles/default --with-sqlite3-dir=/nix/var/nix/profiles/default'

# TODO: use the bundix tool to package up Gemfile deps, see:
# https://nixos.org/nixpkgs/manual/#sec-language-ruby

COPY Gemfile* /opt/rails/
RUN source /etc/profile.d/nix.sh \
  && until timeout -t 180 bundle --deployment --jobs 8 --without development test; do :; done
COPY . /opt/rails
RUN /root/setup-directories.sh rails /opt/rails
DOCKERFILE
