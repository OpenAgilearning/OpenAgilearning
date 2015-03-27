# To sync server status
# Abstract:
#   function:
#     * getDockerServerSettings
#     * syncDockerServerInfo
#     * syncDockerServerImages
#     * syncDockerServerContainer
#   setTimeInterval * 3

@syncDockerEnsureImages = ->
  ensureImages = db.dockerEnsureImages.find().fetch()

  for data in ensureImages
    imageTagData = db.dockerImageTags.findOne data.ensureImageTagId

    if imageTagData?.dockerHubId is "[DockerHub]OfficialDockerHub"
      dm = new Class.DockersManager data.serversQuery
      dm.ensureImage imageTagData.tag




syncDockerServerInfo = ->
  dockerServers = DockerServers.find().fetch()

  # console.log DockerServers.find({},{fields:{_id:1}}).fetch()

  for dockerServerData in dockerServers

    # console.log dockerServerData._id

    try
      docker = new Class.DockerServer(dockerServerData, UsefulCallbacks)
      resData = docker.info()

    catch e
      console.log "error = ", e

    # console.log "~~~~~~~~~~~~~~~~~~~~"
    # console.log "dockerServerData", dockerServerData
    # console.log "syncDockerServerInfo", resData


    # try
    #   resData = docker.info()
    # catch e
    #   console.log "error = ", e

syncDockerServerImageTags = ->
  dockerServers = DockerServers.find().fetch()

  for dockerServerData in dockerServers
    docker = new Class.DockerServer(dockerServerData, UsefulCallbacks)
    resData = docker.listImageTags()

    # try
    #   resData = docker.listImageTags()
    # catch e
    #   console.log "error = ", e


syncDockerServerContainer = ->
  dockerServers = DockerServers.find().fetch()

  for dockerServerData in dockerServers
    docker = new Class.DockerServer(dockerServerData, UsefulCallbacks)
    resData = docker.listContainers()

    # try
    #   resData = docker.listContainers()
    # catch e
    #   console.log "error = ", e

  # dockerServers = DockerServers.find().fetch()
  # Docker = Meteor.npmRequire "dockerode"

  # for dockerServerData in dockerServers
  #   dockerServerSettings = getDockerServerSettings dockerServerData

  #   docker = new Docker dockerServerSettings
  #   Future = Npm.require 'fibers/future'
  #   containersFuture = new Future
  #   lastUpdateAt = new Date

  #   docker.listContainers {all:1}, (err, data) ->
  #     if err
  #       console.log "err ="
  #       console.log err
  #     containersFuture.return data
  #   containers = containersFuture.wait()

  #   if containers.length > 0

  #     deleteNothingnessContainer(dockerServerSettings, containers)

  #     for containerData in containers
  #       containerObj = docker.getContainer containerData.Id

  #       containerInspectDataFuture = new Future
  #       containerObj.inspect (err,data) ->
  #         if err
  #           console.log "err ="
  #           console.log err
  #         containerInspectDataFuture.return data

  #       containerInspectData = containerInspectDataFuture.wait()

  #       queryData =
  #         Id:containerData.Id
  #         Image:containerData.Image
  #         serverId: dockerServerSettings.dockerServerId
  #         serverName: dockerServerSettings.dockerServerName

  #       setData =
  #         lastUpdateAt:lastUpdateAt
  #         serverId: dockerServerSettings.dockerServerId
  #         serverName: dockerServerSettings.dockerServerName
  #         inspectData: containerInspectData

  #       instanceQuery =
  #         serverName: dockerServerSettings.dockerServerName
  #         containerId: containerData.Id
  #       setInstanceData =
  #         "$set":
  #           status: setData.Status
  #           lastUpdateAt: lastUpdateAt

  #       setData = _.extend setData, containerData

  #       if DockerServerContainers.find(queryData).count() > 0
  #         re = /Exited/g
  #         if re.exec(DockerServerContainers.findOne(queryData).Status)
  #           deleteDockerServerContainer DockerServerContainers.findOne(queryData), "dockerServerMonitor"
  #         else
  #           DockerServerContainers.upsert queryData, {$set:setData}
  #           DockerInstances.update instanceQuery, setInstanceData
  #       else
  #         setData.firstMonitorAt = new Date
  #         DockerServerContainers.upsert queryData, {$set:setData}
  #         DockerInstances.update instanceQuery, setInstanceData

  #   else
  #     # SYNC DockerServerContainers, check container is surive ? false, remove it from mongo
  #     # TODO if container's status is exited, call method to remove it

  #     containerArr = DockerServerContainers.find({dockerServerId:dockerServerSettings.dockerServerId}).fetch()
  #     for con in containerArr
  #       con.removeAt = new Date
  #       con.removeBy = "dockerServerMonitor"
  #       DockerServerContainersLog.insert con
  #     DockerServerContainers.remove({dockerServerId:dockerServerSettings.dockerServerId})

  #     instanceArr = DockerInstances.find({"serverName":dockerServerSettings.dockerServerName}).fetch()
  #     for instance in instanceArr
  #       instance.removeBy = "dockerServerMonitor"
  #       instance.removeAt = new Date
  #       DockerInstancesLog.insert instance
  #       DockerInstances.remove({"serverName":instance.serverName, "containerId":instance.containerId, "imageTag":instance.imageTag})
  #     DockerInstances.remove({"serverName":dockerServerSettings.dockerServerName})

  #     console.log "serverName = "
  #     console.log dockerServerSettings.dockerServerName

  #     console.log "containers.length = "
  #     console.log containers.length

  #     console.log "containers = "
  #     console.log containers

# deleteNothingnessContainer = (dockerServerSettings, containers) ->
#     # mongo server
#     filterContainers = []
#     DockerServerContainers.find({serverName:dockerServerSettings["dockerServerName"]}).fetch().map (xx)->
#       filterContainers.push xx.Id

#     # docker server
#     containerIdArr = []
#     containers.map (xxx)->
#       containerIdArr.push xxx.Id
#     filteredContainers = filterContainers.filter (xx) -> xx not in containerIdArr

#     filteredContainers.map (x) ->
#       logData = DockerServerContainers.findOne({"Id":x})
#       logData.removeAt = new Date
#       logData.removeBy = "dockerServerMonitor"
#       DockerServerContainersLog.insert logData
#       DockerServerContainers.remove({"Id":x})

#   # [WARRNING] this containerId is different bellow method removeDockerServerContainer's containerId
#   # this containerId is the item-Id of DockerServerContainers. In another words, containerId
#   # `docker rm containerId`
# deleteDockerServerContainer = (containerData, orderBy)->
#     # containerDoc = DockerServerContainers.findOne Id:containerData.Id
#     Docker = Meteor.npmRequire "dockerode"
#     dockerServerSettings = getDockerServerConnectionSettings(containerData.serverName)
#     docker = new Docker dockerServerSettings

#     Future = Meteor.npmRequire 'fibers/future'

#     removeFuture = new Future
#     container = docker.getContainer containerData.Id

#     container.remove {}, (err,data)->
#       if err
#         console.log "[deleteDockerServerContainer] err ="
#         console.log err
#       removeFuture.return data

#     data = removeFuture.wait()

#     containerData.removeAt = new Date
#     containerData.removeBy = orderBy

#     DockerServerContainersLog.insert containerData
#     DockerServerContainers.remove _id: containerData._id

#     #TODO: modift DockerInstances data
#     instanceQuery =
#       serverName: containerData.serverName
#       containerId: containerData.Id
#           # console.log "DockerServerContainers.remove queryData is"
#     dockerInstanceDoc = DockerInstances.findOne instanceQuery
#     if dockerInstanceDoc
#       DockerInstances.remove _id: dockerInstanceDoc._id

#       dockerInstanceDoc.removeAt = new Date
#       dockerInstanceDoc.removeBy = orderBy
#       dockerInstanceDoc.removeByUid = user._id
#       DockerInstancesLog.insert dockerInstanceDoc



Meteor.setInterval syncDockerServerInfo, 10000
Meteor.setInterval syncDockerServerImageTags, 10000
Meteor.setInterval syncDockerServerContainer, 10000
Meteor.setInterval syncDockerEnsureImages, 300000

# Meteor.setInterval dockerPull.ToDoJobHandler, 5000
# Meteor.setInterval dockerPull.DoingJobHandler, 60000
# Meteor.setInterval dockerPull.progressMonitor, 5000


# Meteor.setInterval syncExceptionDockerServerInfo, 20000
