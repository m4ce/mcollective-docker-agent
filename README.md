# MCollective Docker Agent

This agent manages Docker containers and images.

To use this agent you need:

  * MCollective 2.2.0 at least
  * [Docker Remote API](https://rubygems.org/gems/docker-api) gem installed

## Agent Installation

Follow the basic [plugin install guide](http://docs.puppetlabs.com/mcollective/deploy/plugins.html)

## Configuring the agent

By default the agent uses the unix socket */var/run/docker.sock* to communicate with Docker. You can optionally change it in the *server.cfg*:

    docker.url = unix:///var/run/docker.sock

## Usage

List containers:

    $ mco docker ps [-a]

List images:

    $ mco docker ps [-a]

Start, stop, restart, pause, unpause, diff a container

    $ mco docker <action> <container>

Kill a container:

    $ mco docker kill [--signal <SIGNAL>] <container>

Remove a container:

    $ mco docker rm [--force] <container>

Show the container logs:

    $ mco docker logs <container>

Show the container status:

    $ mco docker status <container>

Execute a command in the container:

    $ mco docker exec <container> <command>

Inspect a container:

    $ mco docker inspect --type container <container>

Show top processes running inside the container:

    $ mco docker top <container>

Inspect an image:

    $ mco docker inspect --type image <image>

Pull an image:

    $ mco docker pull <image>

Remove an image:

    $ mco docker rmi [--force] <image>

Tag an image:

    $ mco docker tag <name>[:tag] [<repo>/]<name>[:tag]

## Data plugin

The docker agent also supplies some data plugins. See the examples below:

Ping hosts where an image is present:

    $ mco rpc rpcutil ping -S "docker_image('<ID>').exists=true"

Ping hosts where a container is present:

    $ mco rpc rpcutil ping -S "docker_container('<ID>').exists=true"

Ping hosts where a container is running:

    $ mco rpc rpcutil ping -S "docker_container('<ID>').running=true"

Ping hosts where a container is restarting:

    $ mco rpc rpcutil ping -S "docker_container('<ID>').restarting=true"

Ping hosts where a container is paused:

    $ mco rpc rpcutil ping -S "docker_container('<ID>').paused=true"

Ping hosts where a container is dead:

    $ mco rpc rpcutil ping -S "docker_container('<ID>').dead=true"

Ping hosts where a container experienced OOM killing

    $ mco rpc rpcutil ping -S "docker_container('<ID>').oomkilled=true"

## TODO

  * Implement push action
  * Implement actions to manage docker networks
  * Implement actions to manage docker volumes
  * Implement rename action

## Author
Matteo Cerutti - <matteo.cerutti@hotmail.co.uk>
