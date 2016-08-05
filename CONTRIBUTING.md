# Contributing

## Running tests

### Install prerequisites

Install the latest version of [Bundler](http://gembundler.com)

```sh
$ gem install bundler
```

Clone the project

```sh
$ git clone git://github.com/berkshelf/buff-config.git
```

and run:

```sh
$ cd buff-config
$ bundle install
```

Bundler will install all gems and their dependencies required for testing and developing.

### Running unit (RSpec) tests

```sh
$ bundle exec guard start
```
