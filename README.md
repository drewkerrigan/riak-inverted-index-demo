riak-inverted-index-demo
========================

###Prerequisites

Install Bundler

```
gem install bundler
```

Install gems required by this application

```
bundle install
```

###To start the mock server (html/css rendering only)

```
bundle exec ruby mock.rb
```

###To start the real server

#### Ensure Riak is running

The `hosts` file in this directory will determine where data is loaded. Confirm you have access to your local Riak cluster *or* change the `hosts` file to point to your remote environment.

```
$ $RIAK_APP/bin/riak ping
pong
```

####Load some Zombie data

```
ruby load_data.rb data.csv
```

####Starting the Server

```
bundle exec unicorn -c unicorn.rb -l 0.0.0.0:8080
```