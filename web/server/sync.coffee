getDockerServerSettings = (dockerServerData) ->
  fs = Meteor.npmRequire 'fs'
  dockerServerSettings = {}
  _.extend dockerServerSettings, dockerServerData.connect
  
  if not dockerServerSettings.socketPath
    if dockerServerData.connect.protocol is "https"
      ["ca","cert","key"].map (xx) ->
        dockerServerSettings[xx] = fs.readFileSync(dockerServerData.security[xx+"Path"])
    dockerServerSettings["dockerServerId"] = dockerServerData._id
    dockerServerSettings["dockerServerName"] = dockerServerData.name
  
  dockerServerSettings

syncDockerServerInfo = ->
  dockerServers = DockerServers.find().fetch()
  Docker = Meteor.npmRequire "dockerode"
  
  for dockerServerData in dockerServers
    dockerServerSettings = getDockerServerSettings dockerServerData

    docker = new Docker dockerServerSettings
    Future = Npm.require 'fibers/future'
    infoFuture = new Future

    docker.info (err, data) ->
      if err
        console.log "err ="
        console.log err
      infoFuture.return data
    
    dockerInfo = infoFuture.wait()
    
    # console.log "dockerInfo = "
    # console.log dockerInfo

    if dockerInfo
      updateData = 
        active:true
        serverInfo:dockerInfo
        lastUpdateAt: new Date

      DockerServers.update {_id:dockerServerData._id},{$set:updateData}
    else
      updateData = 
        active:false
        lastUpdateAt: new Date

      DockerServers.update {_id:dockerServerData._id},{$set:updateData}
      DockerServers.update {_id:dockerServerData._id},{$unset:serverInfo}

syncDockerServerImages = ->
  Docker = Meteor.npmRequire "dockerode"
  fs = Meteor.npmRequire 'fs'
  dockerServers = DockerServers.find().fetch()

  for dockerServerData in dockerServers
    dockerServerSettings = getDockerServerSettings dockerServerData

    docker = new Docker dockerServerSettings
    Future = Npm.require 'fibers/future'
    imagesFuture = new Future

    docker.listImages {}, (err, data) ->
      imagesFuture.return data

    images = imagesFuture.wait()
    
    if images
      lastUpdateAt = new Date

      for imageData in images
        # TODO: upsert new images
        imageData.dockerServerId = dockerServerData._id

        queryDataKeys = Object.keys imageData
        imageTags = imageData.RepoTags
        querytDataKeys = queryDataKeys.filter (key)-> key isnt "RepoTags"
        
        queryImageData = {}
        querytDataKeys.map (key) -> 
          queryImageData[key] = imageData[key]


        for tag in imageTags
          setData = 
            lastUpdateAt:lastUpdateAt
            tag:tag
            serverName: dockerServerData.name
            
          DockerServerImages.upsert queryImageData, {$set:setData}
          

        
        


        # TODO: remove disappear images
        
  

syncDockerServerContainer = ->
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
syncDockerServerPort = ->
  servers = DockerServers.find().fetch()
  for server in servers
    DockerServers.remove(_id:server._id)
    filterPorts = DockerServerContainers.find("dockerServerId":server._id).fetch().map (x)-> x.Ports[0].PublicPort
    server.PublicPort = filterPorts
    DockerServers.insert server


Meteor.setInterval syncDockerServerInfo, 5000
Meteor.setInterval syncDockerServerImages, 5000
# Meteor.setInterval syncDockerServerContainer, 5000
# Meteor.setInterval syncDockerServerPort, 5000
