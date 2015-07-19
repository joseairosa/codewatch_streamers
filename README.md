# codewatch_streamers
Setup for streamers

## Spawn server

```
bundle exec cap streamer server:spawn
``` 

## Spawn load balancer server

```
bundle exec cap load_balancer server:spawn
```

## Setup server

```
bundle exec cap streamer server:setup server_to_update=ec2-52-18-67-195.eu-west-1.compute.amazonaws.com
```

or all servers

```
bundle exec cap streamer server:setup
```  

## Setup load balancer server

```
bundle exec cap load_balancer server:setup server_to_update=ec2-52-18-67-195.eu-west-1.compute.amazonaws.com
```

or all servers

```
bundle exec cap load_balancer server:setup
```

## Deploy to servers

```
bundle exec cap streamer deploy
```

or to a specific server

```
bundle exec cap streamer deploy server_to_update=ec2-52-18-67-195.eu-west-1.compute.amazonaws.com
```

## Deploy to load balancer servers

```
bundle exec cap load_balancer deploy
```

or to a specific server

```
bundle exec cap load_balancer deploy server_to_update=ec2-52-18-67-195.eu-west-1.compute.amazonaws.com
```
