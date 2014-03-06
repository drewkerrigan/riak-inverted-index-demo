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

####Load some Zombie data

```
ruby load_data.rb data.csv
```

####Starting the Server

```
bundle exec unicorn -c unicorn.rb -l 0.0.0.0:8080
```