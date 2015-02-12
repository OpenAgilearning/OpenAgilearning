basePort = 8000
topPort = 9000

getFreePorts = (n, serverName) ->
  if not serverName
    serverName = "localhost"
  ports = [basePort..topPort].map String
  filterPorts = []
  DockerInstances.find({serverName:serverName}).fetch().map (x)->
    x.portDataArray.map (xx) ->
      filterPorts.push xx.hostPort

  DockerServerContainers.find({serverName:serverName}).fetch().map (x)->
    x.Ports.map (xx) ->
      filterPorts.push String xx.PublicPort

  filteredPorts = ports.filter (x) -> x not in filterPorts
  if filteredPorts.length >= n
    filteredPorts.slice(0,n)

getDockerServerConnectionSettings = (dockerServerName) ->

  dockerServerData = DockerServers.findOne name:dockerServerName

  fs = Meteor.npmRequire 'fs'

  dockerServerSettings = {}
  _.extend dockerServerSettings, dockerServerData.connect
  if not dockerServerSettings.socketPath
    if dockerServerData.connect.protocol is "https"
      ["ca","cert","key"].map (xx) ->
        dockerServerSettings[xx] = fs.readFileSync(dockerServerData.security[xx+"Path"])

  dockerServerSettings


getFreeDockerServerName = (imageTag) -> "d3-agilearning"
# getFreeDockerServerName = (imageTag) -> "localhost"

Meteor.methods
  "removeDockerInstance": (instanceId)->
    #[TODOLIST: checking before running]
    #TODO: assert user logged in
    user = Meteor.user()
    if not user
      throw new Meteor.Error(401, "You need to login")

    #TODO: assert container exists
    instanceDoc = DockerInstances.findOne _id: instanceId

    console.log "instanceId = "
    console.log instanceId
    console.log instanceDoc

    if not instanceDoc
      throw new Meteor.Error(1001, "Docker Server Instance ID Error!")

    hasRemovePermission = instanceDoc.userId is user._id
    hasRemovePermission = hasRemovePermission or Roles.userIsInRole(user._id, "admin", "dockers")

    if hasRemovePermission
      dockerServerContainerId = instanceDoc.containerId
      containerDoc = DockerServerContainers.findOne Id: dockerServerContainerId

      containerId = containerDoc.Id

      Docker = Meteor.npmRequire "dockerode"
      dockerServerSettings = getDockerServerConnectionSettings(containerDoc.serverName)
      docker = new Docker dockerServerSettings

      Future = Meteor.npmRequire 'fibers/future'
      stopFuture = new Future
      container = docker.getContainer containerId

      container.stop {}, (err,data)->
        stopFuture.return data

      data = stopFuture.wait()

      removeFuture = new Future
      container = docker.getContainer containerId

      container.remove {}, (err,data)->
        removeFuture.return data

      data = removeFuture.wait()

      DockerServerContainers.remove _id: dockerServerContainerId

      containerDoc.removeAt = new Date
      containerDoc.removeBy = "user"
      containerDoc.removeByUid = user._id

      DockerServerContainersLog.insert containerDoc

      #TODO: modift DockerInstances data
      instanceQuery =
        serverName: containerDoc.serverName
        containerId: containerId

      dockerInstanceDoc = DockerInstances.findOne instanceQuery
      if dockerInstanceDoc
        DockerInstances.remove _id: dockerInstanceDoc._id

        dockerInstanceDoc.removeAt = new Date
        dockerInstanceDoc.removeBy = "user"
        dockerInstanceDoc.removeByUid = user._id
        DockerInstancesLog.insert dockerInstanceDoc



  "removeDockerServerContainer": (dockerServerContainerId)->
    #[TODOLIST: checking before running]
    #TODO: assert user logged in
    user = Meteor.user()
    if not user
      throw new Meteor.Error(401, "You need to login")

    #TODO: assert container exists
    containerDoc = DockerServerContainers.findOne _id: dockerServerContainerId

    if not containerDoc
      throw new Meteor.Error(1001, "Docker Server Container ID Error!")


    if Roles.userIsInRole user._id, "admin", "dockers"
      containerId = containerDoc.Id

      Docker = Meteor.npmRequire "dockerode"
      dockerServerSettings = getDockerServerConnectionSettings(containerDoc.serverName)
      docker = new Docker dockerServerSettings

      Future = Meteor.npmRequire 'fibers/future'
      stopFuture = new Future
      container = docker.getContainer containerId

      container.stop {}, (err,data)->
        stopFuture.return data

      data = stopFuture.wait()

      removeFuture = new Future
      container = docker.getContainer containerId

      container.remove {}, (err,data)->
        removeFuture.return data

      data = removeFuture.wait()

      DockerServerContainers.remove _id: dockerServerContainerId

      containerDoc.removeAt = new Date
      containerDoc.removeBy = "dockerAdmin"
      containerDoc.removeByUid = user._id

      DockerServerContainersLog.insert containerDoc

      #TODO: modift DockerInstances data
      instanceQuery =
        serverName: containerDoc.serverName
        containerId: containerId

      dockerInstanceDoc = DockerInstances.findOne instanceQuery
      if dockerInstanceDoc
        DockerInstances.remove _id: dockerInstanceDoc._id

        dockerInstanceDoc.removeAt = new Date
        dockerInstanceDoc.removeBy = "dockerAdmin"
        dockerInstanceDoc.removeByUid = user._id
        DockerInstancesLog.insert dockerInstanceDoc

  # [WARRNING] this containerId is different bellow method removeDockerServerContainer's containerId
  # this containerId is the item-Id of DockerServerContainers. In another words, containerId
  # `docker rm containerId`
  "deleteDockerServerContainer":  (containerData, orderBy)->
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

  "getClassroomDocker": (classroomId) ->
    user = Meteor.user()
    if not user
      throw new Meteor.Error(401, "You need to login")

    if Classrooms.find({_id:classroomId}).count() is 0
      throw new Meteor.Error(1201, "Classroom doesn't exist")

    classroomDoc = Classrooms.findOne _id:classroomId
    if classroomDoc
      courseData = Courses.findOne _id:classroomDoc.courseId

      if courseData
        imageId = courseData.dockerImage

        # imageType = DockerImages.findOne({_id:imageId}).type
        # if DockerTypeConfig.find({userId:user._id,typeId:imageType}).count() is 0
        #   #FIXME: write a checking function for env vars
        #   throw new Meteor.Error(1002, "MUST Setting Type Configurations before running!")

        Meteor.call "runDocker", imageId

  "runDocker": (imageTag)->

    if imageTag.split(":").length is 1
      fullImageTag = imageTag + ":latest"
    else
      fullImageTag = imageTag

    #[TODOLIST: checking before running]
    #TODO: assert user logged in
    user = Meteor.user()
    if not user
      throw new Meteor.Error(401, "You need to login")

    #TODO: assert imageTag exists
    if DockerImages.find({_id:imageTag}).count() is 0
      throw new Meteor.Error(1001, "Docker Image ID Error!")

    #[TODOLIST: building running containerData]
    #TODO: check user's config
    configTypeId = DockerImages.findOne({_id:imageTag}).type
    if EnvUserConfigs.find({userId:user._id,configTypeId:configTypeId}).count() is 0
      #FIXME: write a checking function for env vars
      throw new Meteor.Error(1002, "MUST Setting Type Configurations before running!")

    else
      configData = EnvUserConfigs.findOne({userId:user._id,configTypeId:configTypeId}).configData
      EnvsArray = configData.map (envData) -> envData["key"] + "=" + envData["value"]


    #TODO: (if has config) getEnvUserConfigs
    #TODO: checkingRunningCondition
    #TODO: (if can run) choosing Running Limit
      dockerLimit = DockerLimits.findOne _id:"defaultLimit"

    #TODO: use limit, EnvTypes' config => build containerData
      containerData = dockerLimit.limit
      containerData.Image = imageTag
      containerData.Env = EnvsArray

    #[TODOLIST: get free server & ports]
    #TODO: get free server has the image
      Docker = Meteor.npmRequire "dockerode"
      freeDockerServerName = getFreeDockerServerName(imageTag)
      dockerServerSettings = getDockerServerConnectionSettings(freeDockerServerName)
      docker = new Docker dockerServerSettings

    #TODO: (if has server) get free ports in that server (include multiports)

      servicePorts = EnvConfigTypes.findOne({_id:configTypeId}).configs.servicePorts
      fports = getFreePorts servicePorts.length, freeDockerServerName

      portDataArray = [0..fports.length-1].map (i)->
        portData =
          guestPort: servicePorts[i].port
          hostPort: fports[i]
          type: servicePorts[i].type

      containerData.HostConfig = {}
      containerData.HostConfig.PortBindings = {}

      for portData in portDataArray
        servicePort = portData.guestPort + "/tcp"
        containerData.HostConfig.PortBindings[servicePort] = [{"HostPort": portData.hostPort}]

    #FIXME: two server might acquire the same port

    #[TODOLIST: runServer and write data to db]
    #TODO: createContainer
    #TODO: getContainer
    #TODO: write status and logging data to dbs

    if DockerInstances.find({userId:user._id,imageTag:fullImageTag}).count() is 0

      # console.log "fullImageTag = "
      # console.log fullImageTag

      Future = Npm.require 'fibers/future'
      createFuture = new Future

      docker.createContainer containerData, (err, container) ->
        createFuture.return container

      container = createFuture.wait()

      startFuture = new Future

      startOpt = {}
      # startOpt.PortBindings = containerData.HostConfig.PortBindings

      cont = docker.getContainer container.id
      cont.start startOpt, (err, data) ->
        startFuture.return data

      data = startFuture.wait()

      serverIP = dockerServerSettings.host
      if not serverIP
        serverIP = "localhost"

      dockerData =
        userId: user._id
        imageTag: fullImageTag
        dockerLimitId: "defaultLimit"
        containerConfig: containerData
        containerId: container.id
        configTypeId:configTypeId
        portDataArray:portDataArray
        configTypeId:configTypeId
        ip:serverIP
        serverName: freeDockerServerName
        createAt: new Date

      DockerInstances.insert dockerData



    # TODO: different roles can access different images ...
