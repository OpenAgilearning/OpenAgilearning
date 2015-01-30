syncDockerServerContainer =->
  dockerServers = DockerServers.find().fetch()
  Docker = Meteor.npmRequire "dockerode"
  fs = Meteor.npmRequire 'fs'
  # Future = Npm.require 'fibers/future'

  for dockerServerData in dockerServers
    dockerServerSettings = {}
    _.extend dockerServerSettings, dockerServerData.connect
    ["ca","cert","key"].map (xx) ->
      dockerServerSettings[xx] = fs.readFileSync(dockerServerData.security[xx+"Path"])
    dockerServerSettings["dockerServerId"] = dockerServerData._id
    dockerServerSettings["dockerServerName"] = dockerServerData.name

    docker = new Docker dockerServerSettings
    Future = Npm.require 'fibers/future'
    containersFuture = new Future

    docker.listContainers {}, (err, data) ->
      if err
        console.log "err ="
        console.log err
      containersFuture.return data
    containers = containersFuture.wait()
    DockerServerContainers.remove({dockerServerId:dockerServerSettings.dockerServerId})

    for containerData in containers
      containerData.dockerServerId = dockerServerSettings.dockerServerId
      containerData.dockerServerName = dockerServerSettings.dockerServerName
      DockerServerContainers.insert containerData

    # syncDockerServerFuture = new Future
    # syncDockerServer()
    # syncDockerServerFuture.wait()
    # syncDockerServerFuture.return "syncDockerServer done"
syncDockerServerPort =->
  servers = DockerServers.find().fetch()
  for server in servers
    DockerServers.remove(_id:server._id)
    filterPorts = DockerServerContainers.find("dockerServerId":server._id).fetch().map (x)-> x.Ports[0].PublicPort
    server.PublicPort = filterPorts
    DockerServers.insert server

syncDockerServerImage = ->
  Docker = Meteor.npmRequire "dockerode"
  fs = Meteor.npmRequire 'fs'
  dockerServers = DockerServers.find().fetch()
  for dockerServerData in dockerServers
    dockerServerSettings = {}
    _.extend dockerServerSettings, dockerServerData.connect
    ["ca","cert","key"].map (xx) ->
      dockerServerSettings[xx] = fs.readFileSync(dockerServerData.security[xx+"Path"])
    dockerServerSettings["dockerServerId"] = dockerServerData._id
    dockerServerSettings["dockerServerName"] = dockerServerData.name

    docker = new Docker dockerServerSettings
    Future = Npm.require 'fibers/future'
    imagesFuture = new Future

    docker.listImages {}, (err, data) ->
      imagesFuture.return data

    images = imagesFuture.wait()
    DockerServerImages.remove({dockerServerId:dockerServerSettings.dockerServerId})
    for imageData in images
      imageData.dockerServerId = dockerServerSettings.dockerServerId
      imageData.dockerServerName = dockerServerSettings.dockerServerName
      DockerServerImages.insert imageData

Meteor.setInterval syncDockerServerContainer,20000
Meteor.setInterval syncDockerServerPort,10000
Meteor.setInterval syncDockerServerImage, 60000