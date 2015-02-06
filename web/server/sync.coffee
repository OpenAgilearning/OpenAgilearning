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
      DockerServers.update {_id:dockerServerData._id},{$unset:{serverInfo:""}}

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
          

        # TODO: modify disappear images
        
  

syncDockerServerContainer = ->
  dockerServers = DockerServers.find().fetch()
  Docker = Meteor.npmRequire "dockerode"
  
  for dockerServerData in dockerServers
    dockerServerSettings = getDockerServerSettings dockerServerData

    docker = new Docker dockerServerSettings
    Future = Npm.require 'fibers/future'
    containersFuture = new Future
    lastUpdateAt = new Date

    docker.listContainers {all:1}, (err, data) ->
      if err
        console.log "err ="
        console.log err
      containersFuture.return data
    containers = containersFuture.wait()
    # DockerServerContainers.remove({dockerServerId:dockerServerSettings.dockerServerId})

    if containers.length > 0
      
      for containerData in containers

        containerObj = docker.getContainer containerData.Id

        containerInspectDataFuture = new Future
        containerObj.inspect (err,data) ->
          if err
            console.log "err ="
            console.log err
          containerInspectDataFuture.return data

        containerInspectData = containerInspectDataFuture.wait()

        queryData =
          Id:containerData.Id
          Image:containerData.Image
          serverId: dockerServerSettings.dockerServerId
          serverName: dockerServerSettings.dockerServerName

        setData = 
          lastUpdateAt:lastUpdateAt
          serverId: dockerServerSettings.dockerServerId
          serverName: dockerServerSettings.dockerServerName
          inspectData: containerInspectData

        setData = _.extend setData, containerData

        if DockerServerContainers.find(queryData).count() > 0
          DockerServerContainers.upsert queryData, {$set:setData}

        else
          setData.firstMonitorAt = new Date
          DockerServerContainers.upsert queryData, {$set:setData}
      
    else
      console.log "serverName = "
      console.log dockerServerSettings.dockerServerName

      console.log "containers.length = "
      console.log containers.length

      console.log "containers = "
      console.log containers


Meteor.setInterval syncDockerServerInfo, 5000
Meteor.setInterval syncDockerServerImages, 5000
Meteor.setInterval syncDockerServerContainer, 10000
