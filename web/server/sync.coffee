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

    deleteUnusedContainer(dockerServerSettings, containers)

    # Check if there are containers running ?
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
          re = /Exited/g
          if re.exec(DockerServerContainers.findOne(queryData).Status)
            Meteor.call "deleteDockerServerContainer", DockerServerContainers.findOne(queryData), "dockerServerMonitor"
          else
            DockerServerContainers.upsert queryData, {$set:setData}
            instanceQuery =
              serverName: dockerServerSettings.dockerServerName
              containerId: containerData.Id

            setInstanceData =
              "$set":
                status: setData.Status
                lastUpdateAt: lastUpdateAt
            DockerInstances.update instanceQuery, setInstanceData
        else
          setData.firstMonitorAt = new Date
          DockerServerContainers.upsert queryData, {$set:setData}

          instanceQuery =
            serverName: dockerServerSettings.dockerServerName
            containerId: containerData.Id
          setInstanceData =
            "$set":
              status: setData.Status
              lastUpdateAt: lastUpdateAt
          DockerInstances.update instanceQuery, setInstanceData

    else
      # SYNC DockerServerContainers, check container is surive ? false, remove it from mongo
      # TODO if container's status is exited, call method to remove it
      containerArr = DockerServerContainers.find({dockerServerId:dockerServerSettings.dockerServerId}).fetch()
      for con in containerArr
        con.removeAt = new Date
        con.removeBy = "dockerServerMonitor"
        DockerServerContainersLog.insert con

      instanceArr = DockerInstances.find({"serverName":dockerServerSettings.dockerServerName}).fetch()
      for instance in instanceArr
        instance.removeBy = "dockerServerMonitor"
        instance.removeAt = new Date
        DockerInstancesLog.insert instance
        DockerInstances.remove({"serverName":instance.serverName, "containerId":instance.containerId, "imageTag":instance.imageTag})

      DockerInstances.remove({"serverName":dockerServerSettings.dockerServerName})
      DockerServerContainers.remove({dockerServerId:dockerServerSettings.dockerServerId})

      console.log "serverName = "
      console.log dockerServerSettings.dockerServerName

      console.log "containers.length = "
      console.log containers.length

      console.log "containers = "
      console.log containers

deleteUnusedContainer = (dockerServerSettings, containers) ->
    # mongo server
    filterContainers = []
    DockerServerContainers.find({serverName:dockerServerSettings["dockerServerName"]}).fetch().map (xx)->
      filterContainers.push xx.Id
    # console.log "filterContainers [mongo server]"
    # console.log filterContainers

    # docker server
    containerIdArr = []
    containers.map (xxx)->
      containerIdArr.push xxx.Id
    # console.log "containerIdArr [docker server]"
    # console.log containerIdArr

    filteredContainers = filterContainers.filter (xx) -> xx not in containerIdArr
    # console.log "filteredContainers = "
    # console.log filteredContainers

    filteredContainers.map (x) ->
      logData = DockerServerContainers.findOne({"Id":x})
      logData.removeAt = new Date
      logData.removeBy = "dockerServerMonitor"
      DockerServerContainersLog.insert logData
      DockerServerContainers.remove({"Id":x})


dockerPullImageWorker = ()->
  # MongoClient = Meteor.npmRequire("mongodb").MongoClient
  # Writable = Meteor.npmRequire('stream').Writable
  # util = Meteor.npmRequire 'util'
  
  # console.log "MongoClient = "
  # console.log MongoClient

  



  # StreamToMongo = (options) ->
  #   if !(@ instanceof StreamToMongo)
  #     new StreamToMongo(options)
  #   else
  #     Writable.call @, { objectMode: true }
  #     this.options = options


  # util.inherits(StreamToMongo, Writable)

  # StreamToMongo::_write = (obj, encoding, done)->
  #   self = @
  #   if !@db 
  #     MongoClient.connect @options.db, (err, db) ->
  #       if err 
  #         throw err
  #       else
  #         self.db = db
  #         console.log "self = "
  #         console.log self
  #         self.on 'finish', ->
  #           self.db.close()
      
  #       self.collection = db.collection @options.collection
  #       self.collection.insert(obj, { w: 1 }, done)
    
  #   else 
  #     self.collection.insert(obj, { w: 1 }, done)
  MONGO_URL = process.env.MONGO_URL
  # console.log "MONGO_URL = "
  # console.log MONGO_URL

  serverName = "localhost"
  dockerServerSettings = getDockerServerConnectionSettings "localhost"

  console.log "dockerServerSettings = "
  console.log dockerServerSettings

  Docker = Meteor.npmRequire "dockerode"
  docker = new Docker dockerServerSettings

  if MONGO_URL
    docker.pull "abcdeasfsafeqpostgres:9.3", (err, stream) ->
      Meteor.npmRequire "dockerode"

      JSONStream = Meteor.npmRequire('JSONStream')
      parser = JSONStream.parse()
      
      options = 
        db: MONGO_URL
        collection: 'dockerPullImageStream'

      streamToMongo = Meteor.npmRequire('stream-to-mongo')(options)

      # streamToMongo = StreamToMongo(options)
      # fs = require('fs')
      # writeStream = fs.createWriteStream("/home/c3h3/my_file.txt")


      if not err
        addServerName = (data) ->
          data["serverName"] = serverName
          data
        stream.pipe(parser).on("data",addServerName).pipe(streamToMongo)
      else
        console.log err






# Meteor.setInterval syncDockerServerInfo, 5000
# Meteor.setInterval syncDockerServerImages, 5000
# Meteor.setInterval syncDockerServerContainer, 10000

Meteor.setInterval dockerPullImageWorker, 5000
