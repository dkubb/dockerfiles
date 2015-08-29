# dkubb Dockerfiles

A collection of Dockerfile configurations.

## Requirements

* [Ruby 2.2.3+](https://www.ruby-lang.org/en/downloads/)
* [Rails 4.2.4+](https://rubygems.org/gems/rails)

## Quickstart

```bash
# Build and run an example rails application
./build.sh && docker run --interactive --tty --rm --publish 3000:80 dkubb/alpine-nix-rails-nginx/example
```
