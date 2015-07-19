# codewatch_streamers
Setup for streamers

## Spawn server

```
bundle exec cap streamer server:spawn
```

## Setup server

```
bundle exec cap streamer server:setup server_to_update=ec2-52-18-67-195.eu-west-1.compute.amazonaws.com
```

or all servers

```
bundle exec cap streamer server:setup
```

## Deploy to servers

```
bundle exec cap streamer deploy
```

or to a specific server

```
bundle exec cap streamer deploy server_to_update=ec2-52-18-67-195.eu-west-1.compute.amazonaws.com
```
