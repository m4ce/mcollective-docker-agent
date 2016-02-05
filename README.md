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

## TODO

  * Implement push action
  * Implement data plugins for filtering
  * Implement actions to manage docker networks
  * Implement actions to manage docker volumes
  * Implement rename action

## Author
Matteo Cerutti - <matteo.cerutti@hotmail.co.uk>
