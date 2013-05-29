riak-inverted-index-demo
========================

#Prerequisites

Install Bundler

```
gem install bundler
```

Install gems required by this application

```
bundle install
```

#Load some Zombie data

```
ruby load_data.rb data.csv
```

#Starting the Server

```
bundle exec unicorn -c unicorn.rb -l 0.0.0.0:8080
```