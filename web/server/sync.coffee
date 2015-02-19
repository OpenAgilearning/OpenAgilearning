# To sync server status
# Abstract:
#   function:
#     * getDockerServerSettings
#     * syncDockerServerInfo
#     * syncDockerServerImages
#     * syncDockerServerContainer
#   setTimeInterval * 3

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
    lastUpdateAt = new Date

    # console.log "dockerInfo = "
    # console.log dockerInfo

    if dockerInfo?
      updateData =
        active:true
        serverInfo:dockerInfo
        lastUpdateAt: lastUpdateAt

      DockerServers.update {_id:dockerServerData._id},{$set:updateData}
    else
      updateData =
        active:false
        lastUpdateAt: lastUpdateAt

      if DockerServersException.findOne({_id:dockerServerData._id})
        DockerServers.remove {_id:dockerServerData._id}
        throw new Meteor.Error 11000, "Duplicate data in dockerServers and DockerServersException"
      else
        DockerServersException.insert dockerServerData
        DockerServersException.update {_id:dockerServerData._id}, {$set:updateData}
        DockerServersException.update {_id:dockerServerData._id},{$unset:{serverInfo:""}}
        DockerServers.remove {_id:dockerServerData._id}
        DockerServerImages.remove {"serverName":dockerServerData.name}
        # DockerServerContainers.remove {"serverName":dockerServerData.name}


syncExceptionDockerServerInfo = ->
  exceptionDockerServers = DockerServersException.find().fetch()
  Docker = Meteor.npmRequire "dockerode"

  for dockerServerData in exceptionDockerServers
    dockerServerSettings = getDockerServerSettings dockerServerData

    docker = new Docker dockerServerSettings
    Future = Npm.require 'fibers/future'
    infoFuture = new Future

    docker.info (err, data) ->
      if err
        console.log "[sync server exception] err ="
        console.log err
      infoFuture.return data

    dockerInfo = infoFuture.wait()

    if dockerInfo? and not DockerServers.findOne({"_id":dockerServerData._id})?
      updateData =
        active:true
        serverInfo:dockerInfo
        lastUpdateAt: new Date

      DockerServers.insert dockerServerData
      DockerServers.update({_id:dockerServerData._id},{$set:updateData})
      DockerServersException.remove {_id:dockerServerData._id}
    else
      updateData =
        active:false
        lastUpdateAt: new Date
      DockerServersException.update({_id:dockerServerData._id},{$set:updateData})


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

    if images?

      lastUpdateAt = new Date

      deleteNothingnessImage dockerServerSettings, images

      for imageData in images
        # TODO: upsert new images
        re = /none/g
        if re.exec(imageData.RepoTags)

          setData =
            lastUpdateAt: lastUpdateAt
            tag:imageData.RepoTags
            serverName: dockerServerData.name
          DockerServerPullImageScratch.upsert imageData, {$set:setData}

        else

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
    else

      DockerServerImages.remove {"serverName":dockerServerName}
      # I think container sync let function *syncDockerServerContainer* to do such thing
      # DockerServerContainers.remove({"serverName":dockerServerData.name})
      throw new Meteor.Error 1104, "Docker server exception. can't find and docker images"


deleteNothingnessImage = (dockerServerSettings, images) ->
    # mongo server
    filterImages = []
    DockerServerImages.find({serverName:dockerServerSettings["dockerServerName"]}).fetch().map (xx)->
      filterImages.push xx.Id

    # docker server
    exitImageIdArr = []
    images.map (xxx)->
      exitImageIdArr.push xxx.Id

    filteredImages = filterImages .filter (xx) -> xx not in exitImageIdArr

    filteredImages.map (x) ->
      DockerServerImages.remove({"Id":x})
      # FIXME Should I add image log if the image was removed from docker server ??

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

    if containers.length > 0

      deleteNothingnessContainer(dockerServerSettings, containers)

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

        instanceQuery =
          serverName: dockerServerSettings.dockerServerName
          containerId: containerData.Id
        setInstanceData =
          "$set":
            status: setData.Status
            lastUpdateAt: lastUpdateAt

        setData = _.extend setData, containerData

        if DockerServerContainers.find(queryData).count() > 0
          re = /Exited/g
          if re.exec(DockerServerContainers.findOne(queryData).Status)
            deleteDockerServerContainer DockerServerContainers.findOne(queryData), "dockerServerMonitor"
          else
            DockerServerContainers.upsert queryData, {$set:setData}
            DockerInstances.update instanceQuery, setInstanceData
        else
          setData.firstMonitorAt = new Date
          DockerServerContainers.upsert queryData, {$set:setData}
          DockerInstances.update instanceQuery, setInstanceData

    else
      # SYNC DockerServerContainers, check container is surive ? false, remove it from mongo
      # TODO if container's status is exited, call method to remove it

      containerArr = DockerServerContainers.find({dockerServerId:dockerServerSettings.dockerServerId}).fetch()
      for con in containerArr
        con.removeAt = new Date
        con.removeBy = "dockerServerMonitor"
        DockerServerContainersLog.insert con
      DockerServerContainers.remove({dockerServerId:dockerServerSettings.dockerServerId})

      instanceArr = DockerInstances.find({"serverName":dockerServerSettings.dockerServerName}).fetch()
      for instance in instanceArr
        instance.removeBy = "dockerServerMonitor"
        instance.removeAt = new Date
        DockerInstancesLog.insert instance
        DockerInstances.remove({"serverName":instance.serverName, "containerId":instance.containerId, "imageTag":instance.imageTag})
      DockerInstances.remove({"serverName":dockerServerSettings.dockerServerName})

      console.log "serverName = "
      console.log dockerServerSettings.dockerServerName

      console.log "containers.length = "
      console.log containers.length

      console.log "containers = "
      console.log containers

deleteNothingnessContainer = (dockerServerSettings, containers) ->
    # mongo server
    filterContainers = []
    DockerServerContainers.find({serverName:dockerServerSettings["dockerServerName"]}).fetch().map (xx)->
      filterContainers.push xx.Id

    # docker server
    containerIdArr = []
    containers.map (xxx)->
      containerIdArr.push xxx.Id
    filteredContainers = filterContainers.filter (xx) -> xx not in containerIdArr

    filteredContainers.map (x) ->
      logData = DockerServerContainers.findOne({"Id":x})
      logData.removeAt = new Date
      logData.removeBy = "dockerServerMonitor"
      DockerServerContainersLog.insert logData
      DockerServerContainers.remove({"Id":x})

  # [WARRNING] this containerId is different bellow method removeDockerServerContainer's containerId
  # this containerId is the item-Id of DockerServerContainers. In another words, containerId
  # `docker rm containerId`
deleteDockerServerContainer = (containerData, orderBy)->
    # containerDoc = DockerServerContainers.findOne Id:containerData.Id
    Docker = Meteor.npmRequire "dockerode"
    dockerServerSettings = getDockerServerConnectionSettings(containerData.serverName)
    docker = new Docker dockerServerSettings

    Future = Meteor.npmRequire 'fibers/future'

    removeFuture = new Future
    container = docker.getContainer containerData.Id

    container.remove {}, (err,data)->
      if err
        console.log "[deleteDockerServerContainer] err ="
        console.log err
      removeFuture.return data

    data = removeFuture.wait()

    containerData.removeAt = new Date
    containerData.removeBy = orderBy

    DockerServerContainersLog.insert containerData
    DockerServerContainers.remove _id: containerData._id

    #TODO: modift DockerInstances data
    instanceQuery =
      serverName: containerData.serverName
      containerId: containerData.Id
          # console.log "DockerServerContainers.remove queryData is"
    dockerInstanceDoc = DockerInstances.findOne instanceQuery
    if dockerInstanceDoc
      DockerInstances.remove _id: dockerInstanceDoc._id

      dockerInstanceDoc.removeAt = new Date
      dockerInstanceDoc.removeBy = orderBy
      dockerInstanceDoc.removeByUid = user._id
      DockerInstancesLog.insert dockerInstanceDoc



# Meteor.setInterval syncDockerServerInfo, 5000
# Meteor.setInterval syncDockerServerImages, 5000
# Meteor.setInterval syncDockerServerContainer, 10000

# Meteor.setInterval dockerPull.ToDoJobHandler, 5000
# Meteor.setInterval dockerPull.DoingJobHandler, 60000
# Meteor.setInterval dockerPull.progressMonitor, 5000


# Meteor.setInterval syncExceptionDockerServerInfo, 20000
